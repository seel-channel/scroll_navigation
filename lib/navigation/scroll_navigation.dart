import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scroll_navigation/misc/screen.dart';
import 'package:scroll_navigation/misc/navigation_helpers.dart';

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
    this.showIdentifier = true,
    this.identifierPhysics = true,
    this.identifierOnBottom = true,
    this.identifierWithBorder = true,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
    this.verticalPadding = 20,
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
  final List<ScrollNavigationItem> navItems;

  /// When active, the indicator will move along with the scroll of the pages.
  /// Of other way, it will only move when you change page.
  final bool identifierPhysics;

  /// It will show the identifier.
  /// If false, the argument [identifierPhysics] will be ignored
  final bool showIdentifier;

  ///If true show a circular border radius else show a simple rectangle.
  final bool identifierWithBorder;

  ///Mostrará el identificador, en la parte inferior, si no en la parte superior
  ///de la barra de navegación
  final bool identifierOnBottom;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  ///It's the vertical padding that the navItem have.
  final double verticalPadding;

  final Color backgroundColorNav, backgroundColorBody;

  @override
  ScrollNavigationState createState() => ScrollNavigationState();
}

class ScrollNavigationState extends State<ScrollNavigation> {
  int _bottomIndex = 0;
  int _maxItemsCache = 5;
  bool _identifierPhysics;
  bool _itemTapped = false;
  Orientation _orientation;
  PageController _pageController;
  GlobalKey navigationKey = GlobalKey();
  Cubic _animationCurve = Curves.linearToEaseOut;
  Duration _animationDuration = Duration(milliseconds: 400);
  List<int> _popUpCache = List();
  Map<String, double> _identifier = Map();
  List<Widget> _pagesActionButtons = List();
  List<Map<String, dynamic>> _itemProps = List();

  ///Go to a custom page :)
  void goToPage(int index) => _onBottomItemTapped(index);

  @override
  void initState() {
    _bottomIndex = widget.initialPage;
    _popUpCache.add(widget.initialPage);
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
    for (int i = 0; i < widget.navItems.length; i++)
      _itemProps.add({"lerp": 0.0});
    super.initState();
  }

  @override
  void dispose() {
    if (widget.showIdentifier) _pageController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<bool> _onPressBackButton() async {
    if (_popUpCache.length != 1) {
      _popUpCache.removeLast();
      _onBottomItemTapped(_popUpCache[_popUpCache.length - 1]);
      _popUpCache.removeLast();
      return false;
    } else
      return true;
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

  void _clearColorLerp() {
    for (int i = 0; i < widget.navItems.length; i++)
      _itemProps[i]["lerp"] = 0.0;
  }

  void _setColorLerp(int index, double result) {
    _itemProps[index]["lerp"] = result;
  }

  void _scrollListener() {
    double page = _pageController.page;
    setState(() {
      if (page != page.round()) _bottomIndex = page.round();
      if (_identifierPhysics) {
        _identifier["position"] = _identifier["width"] * page;
        if (_itemTapped) _clearColorLerp();
        _setColorLerp(page.floor(), 1 - (page - page.floor()));
        if (page.floor() + 1 < widget.pages.length)
          _setColorLerp(page.floor() + 1, page - page.floor());
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
            onPageChanged: (index) {
              setState(() {
                if (_popUpCache.length > _maxItemsCache)
                  _popUpCache.removeAt(0);
                if (!_itemTapped) _popUpCache.add(index);
              });
            }),
        backgroundColor: widget.backgroundColorBody != null
            ? widget.backgroundColorBody
            : Colors.grey[100],
        bottomNavigationBar: !widget.navigationOnTop
            ? _buildBottomNavigation(elevation: 1 - widget.elevation)
            : null,
        floatingActionButton: _pagesActionButtons[_bottomIndex],
        resizeToAvoidBottomPadding: false,
      ),
    );
  }

  //WIDGETS
  Widget _buildBottomNavigation({double elevation}) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_orientation == null || _orientation != orientation) {
          double navWidth = MediaQuery.of(context).size.width;
          double itemLenght = 1 / widget.navItems.length;
          double width = navWidth * itemLenght;

          _orientation = orientation;
          _identifier["width"] = width;
          _identifier["navWidth"] = navWidth;
          _identifier["position"] = width * _bottomIndex;
          _setColorLerp(widget.initialPage, 1.0);
        }
        return Stack(
          children: <Widget>[
            Container(
              key: navigationKey,
              padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
              decoration: BoxDecoration(
                color: widget.backgroundColorNav,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: -3,
                    blurRadius: 2,
                    offset: Offset(0, elevation),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ...widget.navItems.asMap().entries.map((item) {
                    return Expanded(
                      child: InkWell(
                        onTap: () => _onBottomItemTapped(item.key),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconTheme.merge(
                              data: IconThemeData(
                                color: Color.lerp(
                                    widget.desactiveColor,
                                    widget.activeColor,
                                    _itemProps[item.key]["lerp"]),
                              ),
                              child: item.value.icon,
                            ),
                            if (item.value.title != null &&
                                item.value.title.isNotEmpty)
                              Text(
                                item.value.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color.lerp(
                                      widget.desactiveColor,
                                      widget.activeColor,
                                      _itemProps[item.key]["lerp"]),
                                ).merge(widget.navItems[item.key].titleStyle),
                              ),
                          ],
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
            if (widget.showIdentifier)
              AnimatedPositioned(
                height: 3.0,
                width: _identifier["width"],
                left: _identifier["position"],
                bottom: widget.identifierOnBottom ? 0 : null,
                duration: _identifierPhysics
                    ? Duration(milliseconds: 0)
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
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
