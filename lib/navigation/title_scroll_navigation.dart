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
    createLerp();
    setLerp(widget.initialPage, 1.0);
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => setTitleWidth());
    super.initState();
  }

  void createLerp() {
    for (var title in widget.titles)
      _titlesProps[title] = {"lerp": 0.0, "key": GlobalKey()};
  }

  void clearLerp() {
    for (var title in widget.titles) _titlesProps[title]["lerp"] = 0.0;
  }

  double getProps(int index, String prop) {
    return _titlesProps[widget.titles[index]][prop];
  }

  void setLerp(int index, double result) {
    _titlesProps[widget.titles[index]]["lerp"] = result;
  }

  void setTitleWidth() {
    setState(() {
      for (var title in widget.titles) {
        double width = _titlesProps[title]["key"].currentContext.size.width;
        _titlesProps[title]["width"] = width;
      }
      _identifier["width"] = getProps(widget.initialPage, "width");
    });
  }

  double setIdentifierWidth(double index) {
    return getProps(index.floor(), "width") +
        (getProps(index.round(), "width") - getProps(index.floor(), "width")) *
            (index - index.floor());
  }

  double setIdentifierPosition(double index) {
    double position = 0;
    double widthPadding(int i) => getProps(i, "width") + widget.paddingBetween;
    for (var i = 0; i < index.floor(); i++) {
      position += widthPadding(i);
    }
    return position + widthPadding(index.floor()) * (index - index.floor());
  }

  void _scrollListener() {
    int pageFloor = _pageController.page.floor();
    double pageDecimal = _pageController.page - pageFloor;

    setState(() {
      _identifier["width"] = setIdentifierWidth(_pageController.page);
      _identifier["position"] = setIdentifierPosition(_pageController.page);
      clearLerp();
      setLerp(pageFloor + 1, pageDecimal);
      setLerp(pageFloor, 1 - pageDecimal);
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
