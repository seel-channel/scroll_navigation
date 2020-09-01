import 'package:flutter/material.dart';
import 'package:scroll_navigation/misc/screen.dart';

class TitleScrollNavigation extends StatefulWidget {
  TitleScrollNavigation({
    Key key,
    @required this.titles,
    @required this.pages,
    this.initialPage = 0,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
  }) : super(key: key);

  final List<String> titles;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

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

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    super.initState();
  }

  void _onChangePageIndex(int index) {
    setState(() => _bottomSelectedIndex = index);
  }

  void _scrollListener() {
    setState(() {
      _scroll["position"] = _pageController.position.pixels;
      _scroll["min"] = _pageController.position.minScrollExtent;
      _scroll["max"] = _pageController.position.maxScrollExtent;
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
        for (String title in widget.titles)
          minRow([
            Text(title),
            SizedBox(width: 10),
          ]),
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
