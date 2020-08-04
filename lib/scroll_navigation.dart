library scroll_navigation;

import 'package:flutter/material.dart';

/// It is a navigation that will allow you to scroll from right to left with gestures
/// and also when pressing an item in the Nav Item.
///
/// You need 2 elements: Pages and NavItems.
///
/// Pages and NavItems must have the same number of elements.
class ScrollNavigation extends StatefulWidget {
  ScrollNavigation({
    Key key,
    @required this.pages,
    @required this.navItems,
    this.initialPage = 0,
    this.showIdentifier = true,
    this.identifierPhysics = true,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
    this.backgroundColorAppBar = Colors.white,
    this.appBarBrightnessLight = false,
    this.appBar,
  }) : super(key: key);

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  /// It will show an AppBar or any other PreferredSizeWidget.
  /// Ignore the arguments: [backgroundColorNav] and [appBarBrightnessLight].
  final PreferredSizeWidget appBar;

  /// It is the color that the active icon and indicator will show.
  final Color activeColor;

  /// It is the color that will have icons that are not active.
  final Color desactiveColor;

  /// They are the list of elements that the menu will have.
  /// They must match the total number of pages.
  final List<BottomNavigationBarItem> navItems;

  /// When active, the indicator will move along with the scroll of the pages.
  /// Of other way, it will only move when you change page.
  final bool identifierPhysics;

  /// It will show the identifier.
  /// If false, the argument [identifierPhysics] will be ignored
  final bool showIdentifier;

  /// It is the color that the phone's status bar will have.
  /// It is recommended that the color contrast with the background color of the AppBar
  final bool appBarBrightnessLight;

  final Color backgroundColorNav, backgroundColorAppBar, backgroundColorBody;

  @override
  _ScrollNavigationState createState() => _ScrollNavigationState();
}

class _ScrollNavigationState extends State<ScrollNavigation> {
  int maxItemsCache = 24;
  int bottomSelectedIndex;
  List<int> popUpCache = List();
  PageController pageController;
  bool identifierPhysics, itemTapped = false;
  Cubic animationCurve = Curves.linearToEaseOut;
  Duration animationDuration = Duration(milliseconds: 400);
  Map<String, double> identifier = {"position": 0.0, "width": 1.0};
  Map<String, double> scroll = {"position": 0.0, "max": 0.0, "min": 1.0};

  @override
  void initState() {
    popUpCache.add(widget.initialPage);
    bottomSelectedIndex = widget.initialPage;
    identifierPhysics = widget.identifierPhysics;
    pageController =
        PageController(initialPage: widget.initialPage, keepPage: true);
    if (widget.identifierPhysics && widget.showIdentifier)
      pageController.addListener(scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    if (identifierPhysics && widget.showIdentifier)
      pageController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: widget.appBar != null
            ? widget.appBar
            : PreferredSize(
                preferredSize: Size.fromHeight(0.0),
                child: AppBar(
                  elevation: 0.0,
                  backgroundColor: widget.backgroundColorAppBar,
                  brightness: widget.appBarBrightnessLight
                      ? Brightness.dark
                      : Brightness.light,
                ),
              ),
        body: buildPageView(context),
        bottomNavigationBar: buildBottomNavigation(context),
        resizeToAvoidBottomPadding: false,
        backgroundColor: widget.backgroundColorBody != null
            ? widget.backgroundColorBody
            : Colors.grey[100],
      ),
    );
  }

  //FUNCIONES
  void changePageIndex(int index) {
    setState(() {
      bottomSelectedIndex = index;
      if (popUpCache.length > maxItemsCache) popUpCache.clear();
      if (!itemTapped) popUpCache.add(index);
    });
  }

  void bottomItemTapped(int index) async {
    if (bottomSelectedIndex != index) {
      setState(() {
        itemTapped = true;
        popUpCache.add(index);
      });
      await pageController.animateToPage(index,
          duration: animationDuration, curve: animationCurve);
      setState(() => itemTapped = false);
    }
  }

  void scrollListener() {
    setState(() {
      scroll["position"] = pageController.position.pixels;
      scroll["min"] = pageController.position.minScrollExtent;
      scroll["max"] = pageController.position.maxScrollExtent;
    });
  }

  Future<bool> onWillPop() async {
    if (popUpCache.length != 1) {
      popUpCache.removeLast();
      bottomItemTapped(popUpCache[popUpCache.length - 1]);
      popUpCache.removeLast();
      return false;
    } else
      return true;
  }

  //WIDGETS
  Widget buildPageView(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: (index) => changePageIndex(index),
      children: widget.pages,
    );
  }

  Widget buildBottomNavigation(BuildContext context) {
    if (widget.showIdentifier) {
      double navWidth = MediaQuery.of(context).size.width;
      double itemLenght = 1 / widget.navItems.length;
      double identifierWidth = navWidth * itemLenght;

      setState(() => identifier["width"] = identifierWidth);

      if (identifierPhysics) {
        double positionScale =
            scroll["position"] / scroll["max"] - scroll["min"];
        setState(() {
          identifier["position"] = (navWidth - identifierWidth) * positionScale;

          if (identifier["position"].isNaN)
            identifier["position"] = identifierWidth * bottomSelectedIndex;
        });
      } else {
        setState(() =>
            identifier["position"] = identifierWidth * bottomSelectedIndex);
      }
    }

    return Stack(
      children: <Widget>[
        BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: bottomSelectedIndex,
          selectedItemColor: widget.activeColor,
          unselectedItemColor: widget.desactiveColor,
          backgroundColor: widget.backgroundColorNav,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => bottomItemTapped(index),
          items: widget.navItems,
        ),
        if (widget.showIdentifier)
          AnimatedPositioned(
            bottom: 0,
            left: identifier["position"],
            duration: identifierPhysics
                ? Duration(milliseconds: 100)
                : animationDuration,
            curve: animationCurve,
            child: Container(
              height: 3.0,
              width: identifier["width"],
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0)),
              ),
            ),
          ),
      ],
    );
  }
}
