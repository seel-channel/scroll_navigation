import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_navigation/misc/screen.dart';
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
    this.titleStyle,
    TitleScrollPadding padding,
    this.elevation = 3.0,
    BorderRadiusGeometry identifierBorderRadius,
    this.identifierColor = Colors.blue,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    Color backgroundColorBody,
    this.backgroundColorNav = Colors.white,
  })  : assert(titles != null && pages != null),
        assert(titles.length == pages.length),
        this.padding = padding ?? TitleScrollPadding(),
        this.backgroundColorBody = backgroundColorBody ?? Colors.grey[100],
        this.identifierBorderRadius = identifierBorderRadius ??
            BorderRadius.only(
                topRight: Radius.circular(10.0),
                topLeft: Radius.circular(10.0)),
        super(key: key);

  final List<String> titles;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  ///It's the padding will have the titles container and the padding between titles.
  final TitleScrollPadding padding;

  ///If true, the identifier will have rounded corner; else, will show a rectangle.
  final BorderRadiusGeometry identifierBorderRadius;

  ///It's the style than the titles will have.
  final TextStyle titleStyle;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  /// It is the color that the active title will show.
  final Color activeColor;

  /// It is the color that the desactive title will show.
  final Color desactiveColor;

  /// It is the color that the identifier will show.
  final Color identifierColor;

  ///Colooooors :D
  final Color backgroundColorNav, backgroundColorBody;

  @override
  _TitleScrollNavigationState createState() => _TitleScrollNavigationState();
}

class _TitleScrollNavigationState extends State<TitleScrollNavigation> {
  Map<String, Map<String, dynamic>> _titlesProps = Map();
  Map<String, double> _identifier = Map();
  List<String> _titles = List();
  PageController _pageController;
  TitleScrollPadding _padding;

  int _currentPage = 0;
  bool _itemTapped = false;
  double _initialPosition = 0.0;

  ///Go to a page :)
  void goToPage(int index) => _titleTapped(index);

  @override
  void initState() {
    _createTitleProps();
    _setColorLerp(widget.initialPage, 1.0);
    _padding = widget.padding;
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setTitlesWidth());
    super.initState();
  }

  void _createTitleProps() {
    for (int i = 0; i < widget.titles.length; i++) {
      String title = "${widget.titles[i]}$i";
      _titlesProps[title] = {"lerp": 0.0, "key": GlobalKey(), "width": 0.0};
      _titles.add(title);
    }
  }

  void _setTitlesWidth() {
    setState(() {
      for (String title in _titles) {
        final GlobalKey key = _titlesProps[title]["key"];
        final double width = key.currentContext.size.width;
        _titlesProps[title]["width"] = width;
      }
      _identifier["width"] = _getProp(widget.initialPage, "width");
      _identifier["position"] = _padding.left;
    });
  }

  void _scrollListener() {
    final double page = _pageController.page;
    final int current = page.floor();
    final double decimal = page - current;

    setState(() {
      if (_itemTapped) _clearColorLerp();
      if (current + 1 < widget.pages.length) {
        _identifier["width"] = _getIdentifierWidth(current, decimal);
        _identifier["position"] = _getIdentifierPosition(current, decimal);
        _setColorLerp(current + 1, decimal);
      }
      _setColorLerp(current, 1 - decimal);
      if (current != _currentPage) _currentPage = current;
    });
  }

  double _getProp(int index, String prop) {
    return _titlesProps[_titles[index]][prop];
  }

  //----------//
  //IDENTIFIER//
  //----------//
  double _getIdentifierWidth(int page, double decimal) {
    double floorWidth({int sum = 0}) => _getProp(page + sum, "width");
    final double width = floorWidth();
    final double nextWidth = floorWidth(sum: 1);
    return width + ((nextWidth - width) * decimal);
  }

  double _getIdentifierPosition(int page, double decimal) {
    double position = 0;
    double widthPadding(i) => _getProp(i, "width") + _padding.betweenTitles;
    if (page != _currentPage) {
      for (var i = 0; i < page; i++) position += widthPadding(i);
      _initialPosition = position;
    } else {
      position = _initialPosition;
    }
    return position + _padding.left + (widthPadding(page) * decimal);
  }

  //----------//
  //COLOR LERP//
  //----------//
  void _clearColorLerp() {
    for (var title in _titles) _titlesProps[title]["lerp"] = 0.0;
  }

  void _setColorLerp(int index, double result) {
    _titlesProps[_titles[index]]["lerp"] = result;
  }

  void _titleTapped(int index) async {
    setState(() => _itemTapped = true);
    await _pageController.animateToPage(
      index,
      curve: Curves.ease,
      duration: Duration(milliseconds: 400),
    );
    setState(() {
      _itemTapped = false;
      _clearColorLerp();
      _setColorLerp(_pageController.page.round(), 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: preferredSafeArea(
          backgroundColor: widget.backgroundColorNav,
          elevation: widget.elevation,
          child: _buildScrollTitles()),
      body: PageView(controller: _pageController, children: widget.pages),
      backgroundColor: widget.backgroundColorBody,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildScrollTitles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: _padding.left,
                top: _padding.top,
                right: _padding.right,
                bottom: _padding.bottom),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ..._titles.asMap().entries.map((title) {
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: () => _titleTapped(title.key),
                    child: Text(
                      widget.titles[title.key],
                      key: _titlesProps[title.value]["key"],
                      maxLines: 1,
                      style: TextStyle(
                        color: Color.lerp(
                            widget.desactiveColor,
                            widget.activeColor,
                            _titlesProps[title.value]["lerp"]),
                      ).merge(widget.titleStyle),
                    ),
                  ),
                  if (_titles.last != title.value)
                    SizedBox(width: _padding.betweenTitles),
                ]);
              })
            ]),
          ),
          AnimatedPositioned(
            bottom: 0,
            height: 3.0,
            width: _identifier["width"],
            left: _identifier["position"],
            duration: Duration(milliseconds: 0),
            child: Container(
              decoration: BoxDecoration(
                color: widget.identifierColor,
                borderRadius: widget.identifierBorderRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
