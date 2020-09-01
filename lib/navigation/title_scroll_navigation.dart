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

  final Color activeColor;
  final Color desactiveColor;
  final double paddingBetween;
  final Color identifierColor;

  final double titleSize;
  final bool titleBold;

  final Color backgroundColorNav, backgroundColorBody;

  @override
  _TitleScrollNavigationState createState() => _TitleScrollNavigationState();
}

class _TitleScrollNavigationState extends State<TitleScrollNavigation> {
  bool _itemTapped = false;
  int _bottomSelectedIndex;
  PageController _pageController;
  Cubic _animationCurve = Curves.linearToEaseOut;
  Duration _animationDuration = Duration(milliseconds: 400);
  Map<String, double> _identifier = {"position": 0.0, "width": 1.0};
  Map<String, double> _scroll = {"position": 0.0, "max": 0.0, "min": 1.0};
  Map<String, Map<String, dynamic>> _titlesProps = Map();

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    for (var title in widget.titles) {
      _titlesProps[title] = {"lerp": 0.0, "width": 0.0};
    }
    super.initState();
  }

  void _onChangePageIndex(int index) {
    setState(() => _bottomSelectedIndex = index);
  }

  void _scrollListener() {
    ScrollDirection direction = _pageController.position.userScrollDirection;
    double _scrollScale = _scroll["max"] / (widget.pages.length - 1);
    double scaled =
        (_scroll["position"] - (_scrollScale * _bottomSelectedIndex + 1)) /
            _scrollScale;

    void setLerp(int index, double result) {
      _titlesProps[widget.titles[_bottomSelectedIndex + index]]["lerp"] =
          result;
    }

    setState(() {
      _scroll["position"] = _pageController.position.pixels;
      _scroll["min"] = _pageController.position.minScrollExtent;
      _scroll["max"] = _pageController.position.maxScrollExtent;

      if (direction == ScrollDirection.reverse) {
        if (scaled > 0) {
          setLerp(0, scaled);
          setLerp(-1, 1 - scaled);
        } else {
          setLerp(1, scaled + 1);
          setLerp(0, 1 - scaled);
        }
      } else {
        if (scaled > 0) {
          setLerp(-1, scaled);
          setLerp(0, 1 - scaled);
        } else {
          setLerp(0, scaled - 1);
          setLerp(-1, 1 - scaled);
        }
      }
      print(_titlesProps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: preferredSafeArea(
          backgroundColor: widget.backgroundColorNav,
          child: _buildScrollTitles()),
      body: PageView(
          children: widget.pages,
          controller: _pageController,
          onPageChanged: (index) => _onChangePageIndex(index)),
      backgroundColor: widget.backgroundColorBody != null
          ? widget.backgroundColorBody
          : Colors.grey[100],
      resizeToAvoidBottomPadding: false,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
