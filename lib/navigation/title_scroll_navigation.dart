import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_navigation/misc/screen.dart';

class TitleScrollNavigation extends StatefulWidget {
  TitleScrollNavigation({
    Key key,
    @required this.titles,
    @required this.pages,
    this.initialPage = 0,
    this.titleSize = 16.0,
    this.paddingBetween = 10.0,
    this.titleBold = true,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.identifierColor = Colors.blue,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
  }) : super(key: key);

  final List<String> titles;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  final double titleSize;
  final double paddingBetween;
  final bool titleBold;

  final Color activeColor;
  final Color desactiveColor;
  final Color identifierColor;
  final Color backgroundColorNav, backgroundColorBody;

  @override
  _TitleScrollNavigationState createState() => _TitleScrollNavigationState();
}

class _TitleScrollNavigationState extends State<TitleScrollNavigation> {
  PageController _pageController;
  Map<String, double> _identifier = {"position": 0.0, "width": 1.0};
  Map<String, Map<String, dynamic>> _titlesProps = Map();

  @override
  void initState() {
    _createTitleProps();
    _setLerp(widget.initialPage, 1.0);
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setTitleWidth());
    super.initState();
  }

  void _createTitleProps() {
    for (var title in widget.titles)
      _titlesProps[title] = {"lerp": 0.0, "key": GlobalKey()};
  }

  void _clearLerp() {
    for (var title in widget.titles) _titlesProps[title]["lerp"] = 0.0;
  }

  void _setLerp(int index, double result) {
    _titlesProps[widget.titles[index]]["lerp"] = result;
  }

  void _setTitleWidth() {
    setState(() {
      for (var title in widget.titles) {
        double width = _titlesProps[title]["key"].currentContext.size.width;
        _titlesProps[title]["width"] = width;
      }
      _identifier["width"] = _getProps(widget.initialPage, "width");
    });
  }

  double _getProps(int index, String prop) {
    return _titlesProps[widget.titles[index]][prop];
  }

  double _getIdentifierWidth(double index) {
    double indexDiff = index - index.floor();
    double floorWidth({int sum = 0}) => _getProps(index.floor() + sum, "width");
    return floorWidth() + (floorWidth(sum: 1) - floorWidth()) * indexDiff;
  }

  double _getIdentifierPosition(double index) {
    double position = 0;
    double widthPadding(int i) => _getProps(i, "width") + widget.paddingBetween;
    for (var i = 0; i < index.floor(); i++) position += widthPadding(i);
    return position + widthPadding(index.floor()) * (index - index.floor());
  }

  void _scrollListener() {
    int pageFloor = _pageController.page.floor();
    double pageDecimal = _pageController.page - pageFloor;

    setState(() {
      _identifier["width"] = _getIdentifierWidth(_pageController.page);
      _identifier["position"] = _getIdentifierPosition(_pageController.page);
      _clearLerp();
      _setLerp(pageFloor + 1, pageDecimal);
      _setLerp(pageFloor, 1 - pageDecimal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: preferredSafeArea(
          backgroundColor: widget.backgroundColorNav,
          child: _buildScrollTitles()),
      resizeToAvoidBottomPadding: false,
      body: PageView(controller: _pageController, children: widget.pages),
      backgroundColor: widget.backgroundColorBody != null
          ? widget.backgroundColorBody
          : Colors.grey[100],
    );
  }

  SingleChildScrollView _buildScrollTitles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Stack(children: [
        minRow([
          ...widget.titles.map((title) {
            return minRow([
              Text(
                title,
                key: _titlesProps[title]["key"],
                maxLines: 1,
                style: TextStyle(
                  color: Color.lerp(widget.desactiveColor, widget.activeColor,
                      _titlesProps[title]["lerp"]),
                  fontWeight:
                      widget.titleBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: widget.titleSize,
                ),
              ),
              SizedBox(width: widget.paddingBetween),
            ]);
          })
        ]),
        AnimatedPositioned(
          bottom: 0,
          height: 3.0,
          width: _identifier["width"],
          left: _identifier["position"],
          duration: Duration(milliseconds: 50),
          child: Container(color: widget.identifierColor),
        ),
      ]),
    );
  }

  Row minRow(List<Widget> children) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
