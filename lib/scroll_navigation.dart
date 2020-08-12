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
    this.pagesActionButtons,
    this.initialPage = 0,
    this.showIdentifier = true,
    this.identifierPhysics = true,
    this.identifierOnBottom = true,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
  }) : super(key: key);

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  ///They are the floating action buttons or Widgets that the pages will have.
  ///To separate pages you can put: Widget, null, Widget
  final List<Widget> pagesActionButtons;

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

  ///Mostrará el identificador, en la parte inferior, si no en la parte superior
  ///de la barra de navegación
  final bool identifierOnBottom;

  final Color backgroundColorNav, backgroundColorBody;

  @override
  ScrollNavigationState createState() => ScrollNavigationState();
}

class ScrollNavigationState extends State<ScrollNavigation> {
  int _maxItemsCache = 5;
  int _bottomSelectedIndex;
  List<int> _popUpCache = List();
  List<Widget> _pagesActionButtons = List();
  PageController _pageController;
  bool _identifierPhysics, _itemTapped = false;
  Cubic _animationCurve = Curves.linearToEaseOut;
  Duration _animationDuration = Duration(milliseconds: 400);
  Map<String, double> _identifier = {"position": 0.0, "width": 1.0};
  Map<String, double> _scroll = {"position": 0.0, "max": 0.0, "min": 1.0};

  PageController get controller => _pageController;

  @override
  void initState() {
    _popUpCache.add(widget.initialPage);
    _bottomSelectedIndex = widget.initialPage;
    _identifierPhysics = widget.identifierPhysics;

    _pageController = PageController(initialPage: widget.initialPage);
    if (_identifierPhysics && widget.showIdentifier) {
      _pageController.addListener(_scrollListener);
    }

    if (widget.pagesActionButtons == null) {
      _pagesActionButtons = List.filled(widget.pages.length, null);
    } else {
      for (var i = 0; i < widget.pages.length + 1; i++) {
        i < widget.pagesActionButtons.length
            ? _pagesActionButtons.add(widget.pagesActionButtons[i])
            : _pagesActionButtons.add(null);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_identifierPhysics && widget.showIdentifier)
      _pageController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPressBackButton,
      child: Scaffold(
        body: PageView(
            children: widget.pages,
            controller: _pageController,
            onPageChanged: (index) => _onChangePageIndex(index)),
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: _buildBottomNavigation(context),
        floatingActionButton: _pagesActionButtons[_bottomSelectedIndex],
        backgroundColor: widget.backgroundColorBody != null
            ? widget.backgroundColorBody
            : Colors.grey[100],
      ),
    );
  }

  //FUNCIONES
  Future<bool> _onPressBackButton() async {
    if (_popUpCache.length != 1) {
      _popUpCache.removeLast();
      _onBottomItemTapped(_popUpCache[_popUpCache.length - 1]);
      _popUpCache.removeLast();
      return false;
    } else
      return true;
  }

  void _onChangePageIndex(int index) {
    setState(() {
      _bottomSelectedIndex = index;
      if (_popUpCache.length > _maxItemsCache) _popUpCache.removeAt(0);
      if (!_itemTapped) _popUpCache.add(index);
    });
  }

  void _onBottomItemTapped(int index) async {
    if (_bottomSelectedIndex != index) {
      setState(() {
        _itemTapped = true;
        _popUpCache.add(index);
      });
      await _pageController.animateToPage(
        index,
        duration: _animationDuration,
        curve: _animationCurve,
      );
      setState(() => _itemTapped = false);
    }
  }

  void _scrollListener() {
    setState(() {
      _scroll["position"] = _pageController.position.pixels;
      _scroll["min"] = _pageController.position.minScrollExtent;
      _scroll["max"] = _pageController.position.maxScrollExtent;
    });
  }

  //WIDGETS
  Widget _buildBottomNavigation(BuildContext context) {
    if (widget.showIdentifier) {
      double navWidth = MediaQuery.of(context).size.width;
      double itemLenght = 1 / widget.navItems.length;
      double identifierWidth = navWidth * itemLenght;

      setState(() => _identifier["width"] = identifierWidth);

      if (_identifierPhysics) {
        double positionScale =
            _scroll["position"] / _scroll["max"] - _scroll["min"];
        setState(() {
          _identifier["position"] =
              (navWidth - identifierWidth) * positionScale;

          if (_identifier["position"].isNaN)
            _identifier["position"] = identifierWidth * _bottomSelectedIndex;
        });
      } else {
        setState(() =>
            _identifier["position"] = identifierWidth * _bottomSelectedIndex);
      }
    }
    return Stack(
      children: <Widget>[
        BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _bottomSelectedIndex,
          selectedItemColor: widget.activeColor,
          unselectedItemColor: widget.desactiveColor,
          backgroundColor: widget.backgroundColorNav,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => _onBottomItemTapped(index),
          items: widget.navItems,
        ),
        if (widget.showIdentifier)
          AnimatedPositioned(
            bottom: widget.identifierOnBottom ? 0 : null,
            left: _identifier["position"],
            duration: _identifierPhysics
                ? Duration(milliseconds: 100)
                : _animationDuration,
            curve: _animationCurve,
            child: Container(
              height: 3.0,
              width: _identifier["width"],
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: widget.identifierOnBottom
                    ? BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0))
                    : BorderRadius.only(
                        bottomRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0)),
              ),
            ),
          ),
      ],
    );
  }
}
