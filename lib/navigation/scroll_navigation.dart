import 'package:flutter/material.dart';
import 'package:scroll_navigation/misc/screen.dart';

class ScrollNavigation extends StatefulWidget {
  /// It is a navigation that will allow you to scroll from right to left with gestures
  /// and also when pressing an item in the Nav Item.
  ///
  /// You need 2 elements: Pages and NavItems.
  ///
  /// Pages and NavItems must have the same number of elements.
  ScrollNavigation({
    Key key,
    @required this.pages,
    @required this.navItems,
    this.pagesActionButtons,
    this.initialPage = 0,
    this.navigationOnTop = false,
    this.showNavItemsTitle = false,
    this.showIdentifier = true,
    this.identifierPhysics = true,
    this.identifierOnBottom = true,
    this.identifierWithBorder = true,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
    this.elevation = 3.0,
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

  ///Change navigation position
  final bool navigationOnTop;

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

  ///It will show the title of the navigation elements.
  final bool showNavItemsTitle;

  ///If true show a circular border radius else show a simple rectangle.
  final bool identifierWithBorder;

  ///Mostrará el identificador, en la parte inferior, si no en la parte superior
  ///de la barra de navegación
  final bool identifierOnBottom;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  final Color backgroundColorNav, backgroundColorBody;

  @override
  ScrollNavigationState createState() => ScrollNavigationState();
}

class ScrollNavigationState extends State<ScrollNavigation> {
  int _bottomIndex = 0;
  int _maxItemsCache = 5;
  List<int> _popUpCache = List();
  List<Widget> _pagesActionButtons = List();
  PageController _pageController;
  GlobalKey navigationKey = GlobalKey();
  bool _identifierPhysics, _itemTapped = false;
  Cubic _animationCurve = Curves.linearToEaseOut;
  Duration _animationDuration = Duration(milliseconds: 400);
  Map<String, double> _identifier = Map();

  set goToPage(int index) => _onBottomItemTapped(index);

  @override
  void initState() {
    _popUpCache.add(widget.initialPage);
    _bottomIndex = widget.initialPage;
    _identifierPhysics = widget.identifierPhysics;
    _pageController = PageController(initialPage: widget.initialPage);
    if (widget.showIdentifier) _pageController.addListener(_scrollListener);
    if (widget.pagesActionButtons == null)
      _pagesActionButtons = List.filled(widget.pages.length, null);
    else {
      for (var i = 0; i < widget.pages.length + 1; i++) {
        i < widget.pagesActionButtons.length
            ? _pagesActionButtons.add(widget.pagesActionButtons[i])
            : _pagesActionButtons.add(null);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double navWidth = navigationKey.currentContext.size.width;
      double itemLenght = 1 / widget.navItems.length;
      double width = navWidth * itemLenght;
      setState(() {
        _identifier["width"] = width;
        _identifier["navWidth"] = navWidth;
        _identifier["position"] = width * _bottomIndex;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_identifierPhysics && widget.showIdentifier)
      _pageController.removeListener(_scrollListener);
    super.dispose();
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
      if (_popUpCache.length > _maxItemsCache) _popUpCache.removeAt(0);
      if (!_itemTapped) _popUpCache.add(index);
    });
  }

  void _onBottomItemTapped(int index) async {
    if (_bottomIndex != index) {
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
    double page = _pageController.page;
    setState(() {
      if (page != page.round()) _bottomIndex = page.round();
      if (_identifierPhysics) {
        _identifier["position"] = _identifier["width"] * page;
      } else
        _identifier["position"] = _identifier["width"] * page.floor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPressBackButton,
      child: Scaffold(
        appBar: widget.navigationOnTop
            ? preferredSafeArea(
                elevation: widget.elevation,
                backgroundColor: widget.backgroundColorNav,
                child: _buildBottomNavigation(elevation: 0))
            : null,
        body: PageView(
            children: widget.pages,
            controller: _pageController,
            onPageChanged: (index) => _onChangePageIndex(index)),
        backgroundColor: widget.backgroundColorBody != null
            ? widget.backgroundColorBody
            : Colors.grey[100],
        bottomNavigationBar: !widget.navigationOnTop
            ? _buildBottomNavigation(elevation: widget.elevation * 4)
            : null,
        floatingActionButton: _pagesActionButtons[_bottomIndex],
        resizeToAvoidBottomPadding: false,
      ),
    );
  }

  //WIDGETS
  Widget _buildBottomNavigation({double elevation = 14}) {
    return Stack(
      children: <Widget>[
        BottomNavigationBar(
          key: navigationKey,
          elevation: elevation,
          selectedFontSize: 12.0,
          currentIndex: _bottomIndex,
          showSelectedLabels: widget.showNavItemsTitle,
          showUnselectedLabels: widget.showNavItemsTitle,
          selectedItemColor: widget.activeColor,
          unselectedItemColor: widget.desactiveColor,
          backgroundColor: widget.backgroundColorNav,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => _onBottomItemTapped(index),
          items: widget.navItems,
        ),
        if (widget.showIdentifier)
          AnimatedPositioned(
            height: 3.0,
            width: _identifier["width"],
            left: _identifier["position"],
            bottom: widget.identifierOnBottom ? 0 : null,
            duration: _identifierPhysics
                ? Duration(milliseconds: 100)
                : _animationDuration,
            curve: _animationCurve,
            child: Container(
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: widget.identifierWithBorder
                    ? widget.identifierOnBottom
                        ? BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0))
                        : BorderRadius.only(
                            bottomRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0))
                    : BoxShape.rectangle,
              ),
            ),
          ),
      ],
    );
  }
}
