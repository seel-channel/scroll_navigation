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
  bool _itemTapped = false;
  PageController _pageController;
  Cubic _animationCurve = Curves.linearToEaseOut;
  Duration _animationDuration = Duration(milliseconds: 400);
  Map<String, double> _identifier = {"position": 0.0, "width": 1.0};
  Map<String, double> _scroll = {"position": 0.0, "max": 0.0, "min": 1.0};
  Map<String, Map<String, dynamic>> _titlesProps = Map();

  @override
  void initState() {
    createLerp();
    setLerp(widget.initialPage, 1.0);
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    super.initState();
  }

  void createLerp() {
    for (var title in widget.titles) _titlesProps[title] = {"lerp": 0.0};
  }

  void clearLerp() {
    for (var title in widget.titles) _titlesProps[title]["lerp"] = 0.0;
  }

  void setLerp(int index, double result) {
    _titlesProps[widget.titles[index]]["lerp"] = result;
  }

  void _scrollListener() {
    int pageFloor = _pageController.page.floor();
    setState(() {
      _scroll["position"] = _pageController.position.pixels;
      _scroll["min"] = _pageController.position.minScrollExtent;
      _scroll["max"] = _pageController.position.maxScrollExtent;
      clearLerp();
      setLerp(pageFloor + 1, _pageController.page - pageFloor);
      setLerp(pageFloor, 1 - (_pageController.page - pageFloor));
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
      child: minRow([
        ...widget.titles.map((title) {
          return minRow([
            Text(
              title,
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
    );
  }

  Row minRow(List<Widget> children) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
