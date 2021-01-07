import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_navigation/misc/navigation_helpers.dart';

class TitleScrollNavigation extends StatefulWidget {
  ///It is a navigation that will only show texts [titles].
  ///You can move with gestures or pressing any title.
  ///
  ///Also, the identifier will be adjusted to the text width
  ///and will have a color interpolation between titles.
  TitleScrollNavigation({
    Key key,
    this.titles,
    this.pages,
    this.initialPage = 0,
    this.showIdentifier = true,
    NavigationBodyStyle bodyStyle,
    TitleNavigationBarStyle barStyle,
    NavigationIdentiferStyle identiferStyle,
  })  : assert(titles != null && pages != null),
        assert(titles.length == pages.length),
        this.barStyle = barStyle ?? TitleNavigationBarStyle(),
        this.bodyStyle = bodyStyle ?? NavigationBodyStyle(),
        this.identiferStyle = identiferStyle ?? NavigationIdentiferStyle(),
        super(key: key);

  /// Are the titles than show it
  final List<String> titles;

  /// Are the pages that the PageView will have
  final List<Widget> pages;

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  ///It will show the identifier.
  final bool showIdentifier;

  ///Title Navigation bar style
  final TitleNavigationBarStyle barStyle;

  ///PageView and Scaffold style
  final NavigationBodyStyle bodyStyle;

  ///Identifier style
  final NavigationIdentiferStyle identiferStyle;

  @override
  _TitleScrollNavigationState createState() => _TitleScrollNavigationState();
}

class _TitleScrollNavigationState extends State<TitleScrollNavigation> {
  final ScrollController _titlesController = ScrollController();
  PageController _controller;

  int _currentPage = 0;
  bool _itemTapped = false;
  double _halfWidth = 0.0;
  double _maxScroll = 0.0;
  double _paddingLeft = 0.0;
  double _initialPosition = 0.0;

  List<Widget> _navTitles = [];
  Map<String, double> _identifier = {};
  List<Map<String, dynamic>> _titlesProps = [];

  ///Go to a page :)
  void goToPage(int index) => _titleTapped(index);

  @override
  void initState() {
    _currentPage = widget.initialPage;
    _paddingLeft = widget.barStyle.padding.left;
    _controller = PageController(initialPage: widget.initialPage);
    _controller.addListener(_scrollListener);

    for (int i = 0; i < widget.titles.length; i++) {
      _titlesProps.add({"key": GlobalKey(), "width": 0.0});
      _navTitles.add(_createTextLerp(i, 0.0));
    }

    _setTitleLerp(_currentPage, 1.0);
    Misc.onLayoutRendered(_setTitlesWidth);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double page = _controller.page;
    final int current = page.floor();
    final double decimal = page - current;

    if (_itemTapped) _clearTitleLerp();
    if (current + 1 < widget.pages.length) {
      _identifier["width"] = _getIdentifierWidth(current, decimal);
      _identifier["position"] = _getIdentifierPosition(current, decimal);
      _setTitleLerp(current + 1, decimal);
      _setTitleLerp(current, 1 - decimal);
    }

    double jumpTo =
        _identifier["position"] - _halfWidth + (_identifier["width"] / 2);

    if (jumpTo > _maxScroll)
      jumpTo = _maxScroll;
    else if (jumpTo < 0) jumpTo = 0;

    _titlesController.jumpTo(jumpTo);

    if (current != _currentPage) _currentPage = current;
  }

  //---------//
  //CALLBACKS//
  //---------//
  void _setTitlesWidth() {
    setState(() {
      for (int i = 0; i < _titlesProps.length; i++)
        _titlesProps[i]["width"] = GetKey(_titlesProps[i]["key"]).width;

      _identifier["width"] = _getTitleWidth(widget.initialPage);
      _identifier["position"] = _paddingLeft;

      _halfWidth = GetMedia(context).width / 2;
      _maxScroll = _titlesController.position.maxScrollExtent;
    });
  }

  void _titleTapped(int index) async {
    setState(() => _itemTapped = true);
    await _controller.animateToPage(
      index,
      curve: Curves.ease,
      duration: Duration(milliseconds: 400),
    );
    setState(() {
      _itemTapped = false;
      _clearTitleLerp();
      _setTitleLerp(_controller.page.round(), 1.0);
    });
  }

  //----------//
  //IDENTIFIER//
  //----------//
  double _getTitleWidth(int index) => _titlesProps[index]["width"];

  double _getIdentifierWidth(int page, double decimal) {
    double floorWidth({int next = 0}) => _getTitleWidth(page + next);
    final double width = floorWidth();
    final double nextWidth = floorWidth(next: 1);
    return width + ((nextWidth - width) * decimal);
  }

  double _getIdentifierPosition(int page, double decimal) {
    double widthPadding(i) => _getTitleWidth(i) + widget.barStyle.spaceBetween;
    double position = 0;

    if (page != _currentPage) {
      for (var i = 0; i < page; i++) position += widthPadding(i);
      _initialPosition = position;
    } else {
      position = _initialPosition;
    }

    return position + _paddingLeft + (widthPadding(page) * decimal);
  }

  //----------//
  //COLOR LERP//
  //----------//
  void _clearTitleLerp() {
    for (int i = 0; i < _titlesProps.length; i++) _setTitleLerp(i, 0.0);
  }

  void _setTitleLerp(int index, double lerp) {
    _navTitles[index] = _createTextLerp(index, lerp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: widget.barStyle.background,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: -3,
                blurRadius: 2,
                offset: Offset(0, widget.barStyle.elevation),
              ),
            ],
          ),
          child: SafeArea(child: _buildScrollTitles()),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: widget.bodyStyle.borderRadius,
            child: PageView(
              physics: widget.bodyStyle.physics,
              children: widget.pages,
              controller: _controller,
              dragStartBehavior: widget.bodyStyle.dragStartBehavior,
            ),
          ),
        ),
      ]),
      backgroundColor: widget.bodyStyle.background,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildScrollTitles() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => SingleChildScrollView(
        controller: _titlesController,
        scrollDirection: Axis.horizontal,
        child: Stack(children: [
          Padding(
            padding: widget.barStyle.padding,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (int i = 0; i < _titlesProps.length; i++) ...[
                GestureDetector(
                  onTap: () => _titleTapped(i),
                  child: _navTitles[i],
                ),
                if (i != _titlesProps.length - 1)
                  SizedBox(width: widget.barStyle.spaceBetween),
              ]
            ]),
          ),
          if (widget.showIdentifier)
            AnimatedPositioned(
              bottom: 0,
              height: 3.0,
              width: _identifier["width"],
              left: _identifier["position"],
              duration: Duration(milliseconds: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.identiferStyle.color,
                  borderRadius: widget.identiferStyle.borderRadius,
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Text _createTextLerp(int index, double lerp) {
    return Text(
      widget.titles[index],
      key: _titlesProps[index]["key"],
      maxLines: 1,
      style: TextStyle(
        color: Color.lerp(
          widget.barStyle.deactiveColor,
          widget.barStyle.activeColor,
          lerp,
        ),
      ).merge(widget.barStyle.style),
    );
  }
}
