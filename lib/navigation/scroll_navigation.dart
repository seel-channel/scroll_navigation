import 'package:helpers/helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scroll_navigation/misc/navigation_helpers.dart';

class ScrollNavigation extends StatefulWidget {
  /// It is a navigation that will allow you to scroll from right to left with gestures
  /// and also when pressing an item in the Nav Item.
  ///
  /// You need 2 elements: Pages and items.
  ///
  /// Pages and items must have the same number of elements.
  ScrollNavigation({
    Key key,
    this.pages,
    this.items,
    this.pagesActionButtons,
    this.initialPage = 0,
    this.showIdentifier = true,
    this.physics = true,
    this.maxWillPopLocations = 5,
    NavigationBarStyle barStyle,
    NavigationBodyStyle bodyStyle,
    NavigationIdentiferStyle identiferStyle,
  })  : assert(items != null && pages != null),
        assert(items.length == pages.length),
        this.barStyle = barStyle ?? NavigationBarStyle(),
        this.bodyStyle = bodyStyle ?? NavigationBodyStyle(),
        this.identiferStyle = identiferStyle ?? NavigationIdentiferStyle(),
        super(key: key);

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  ///They are the floating action buttons or Widgets that the pages will have.
  ///To separate pages you can put: Widget, null, Widget
  final List<Widget> pagesActionButtons;

  ///They are the list of elements that the menu will have.
  ///They must match the total number of pages.
  final List<ScrollNavigationItem> items;

  ///It will show the identifier.
  ///If false, the argument [physics] will be ignored
  final bool showIdentifier;

  ///When active, the indicator will move along with the scroll of the pages.
  ///Of other way, it will only move when you change page.
  final bool physics;

  ///Navigation bar style
  final NavigationBarStyle barStyle;

  ///PageView and Scaffold style
  final NavigationBodyStyle bodyStyle;

  ///Identifier style
  final NavigationIdentiferStyle identiferStyle;

  ///It is the maximum number of locations that will be stored before willPop is executed
  final int maxWillPopLocations;

  @override
  ScrollNavigationState createState() => ScrollNavigationState();
}

class ScrollNavigationState extends State<ScrollNavigation> {
  final ValueNotifier<double> _identifierPosition = ValueNotifier<double>(0.0);

  int _maxItemsCache;
  int _currentIndex = 0;
  bool _itemTapped = false;
  double _identifierWidth = 0.0;

  List<int> _popUpCache = [];
  List<Widget> _navIcons = [];
  List<Widget> _navTexts = [];
  List<Widget> _pagesActionButtons = [];

  Orientation _orientation;
  PageController _controller;
  NavigationBarStyle _barStyle;
  NavigationBodyStyle _bodyStyle;
  NavigationIdentiferStyle _identifierStyle;

  ///Go to a page :)
  void goToPage(int index) => _onBottomItemTapped(index);

  @override
  void initState() {
    _barStyle = widget.barStyle;
    _bodyStyle = widget.bodyStyle;
    _currentIndex = widget.initialPage;
    _maxItemsCache = widget.maxWillPopLocations ?? 5;
    _identifierStyle = widget.identiferStyle;

    _controller = PageController(initialPage: widget.initialPage);
    _controller.addListener(_scrollListener);
    _popUpCache.add(widget.initialPage);

    //FILL FLOATING ACTION BUTTONS ON _pagesActionButtons
    if (widget.pagesActionButtons == null)
      _pagesActionButtons = List.filled(widget.pages.length, null);
    else {
      for (var i = 0; i < widget.pages.length + 1; i++) {
        i < widget.pagesActionButtons.length
            ? _pagesActionButtons.add(widget.pagesActionButtons[i])
            : _pagesActionButtons.add(null);
      }
    }

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      _navIcons.add(item.icon);
      _navTexts.add(item.title != null && item.title.isNotEmpty
          ? Text(
              item.title,
              overflow: TextOverflow.ellipsis,
              style: item.titleStyle,
            )
          : SizedBox());
      _setItemLerp(i, 0.0);
    }

    _setItemLerp(_currentIndex, 1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final double page = _controller.page;
    final int currentPage = page.floor();

    if (widget.physics) {
      if (_itemTapped) _clearItemLerp();
      if (currentPage + 1 < widget.pages.length)
        _setItemLerp(currentPage + 1, (page - currentPage));
      _setItemLerp(currentPage, 1 - (page - currentPage));
      if (widget.showIdentifier)
        _identifierPosition.value = _identifierWidth * page;
    }
  }

  //---------//
  //CALLBACKS//
  //---------//
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
    if (_currentIndex != index) {
      setState(() {
        _itemTapped = true;
        _popUpCache.add(index);
      });
      await _controller.animateToPage(
        index,
        curve: Curves.linearToEaseOut,
        duration: Duration(milliseconds: 500),
      );
      setState(() {
        _itemTapped = false;
        _clearItemLerp();
        _setItemLerp(_currentIndex, 1.0);
      });
    }
  }

  void _onPageChanged(index) {
    setState(() {
      if (!widget.physics) {
        _clearItemLerp();
        _setItemLerp(index, 1.0);
        if (widget.showIdentifier)
          _identifierPosition.value = _identifierWidth * index;
      }
      if (_popUpCache.length > _maxItemsCache) _popUpCache.removeAt(0);
      if (!_itemTapped) _popUpCache.add(index);
      _currentIndex = index;
    });
  }

  //----------//
  //ITEMS LERP//
  //----------//
  void _setItemLerp(int index, double lerp) {
    final item = widget.items[index];
    final color = Color.lerp(
      _barStyle.deactiveColor,
      _barStyle.activeColor,
      lerp,
    );
    _navIcons[index] = IconTheme.merge(
      data: IconThemeData(color: color),
      child: item.activeIcon == null
          ? item.icon
          : lerp > 0.5
              ? item.activeIcon
              : item.icon,
    );
    if (item.title != null && item.title.isNotEmpty)
      _navTexts[index] = Text(
        item.title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color).merge(item.titleStyle),
      );
  }

  void _clearItemLerp() {
    for (int i = 0; i < widget.items.length; i++) _setItemLerp(i, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPressBackButton,
      child: OrientationBuilder(
        builder: (_, Orientation orientation) {
          if (_orientation == null || _orientation != orientation) {
            double width = GetMedia(context).width * (1 / widget.items.length);
            _orientation = orientation;
            _identifierWidth = width;
            _identifierPosition.value = width * _currentIndex;
            _setItemLerp(_currentIndex, 1.0);
          }

          return Scaffold(
            body: Column(children: [
              if (_barStyle.position == NavigationPosition.top)
                SafeAreaColor(
                  color: _barStyle.background,
                  child: _buildBottomNavigation(elevation: _barStyle.elevation),
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: _bodyStyle.borderRadius,
                  child: PageView(
                    physics: _bodyStyle.physics,
                    children: widget.pages,
                    controller: _controller,
                    onPageChanged: _onPageChanged,
                    scrollDirection: _bodyStyle.scrollDirection,
                    dragStartBehavior: _bodyStyle.dragStartBehavior,
                  ),
                ),
              ),
            ]),
            bottomNavigationBar: _barStyle.position == NavigationPosition.bottom
                ? _buildBottomNavigation(elevation: 1 - _barStyle.elevation)
                : null,
            floatingActionButton: _pagesActionButtons[_currentIndex],
            resizeToAvoidBottomPadding: false,
            backgroundColor: _bodyStyle.background,
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation({double elevation}) {
    return Stack(children: [
      //NAVIGATION BAR
      Container(
        decoration: BoxDecoration(
          color: _barStyle.background,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: -3,
              blurRadius: 2,
              offset: Offset(0, elevation),
            ),
          ],
        ),

        ///ICONS
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Row(children: [
            for (int i = 0; i < widget.items.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => _onBottomItemTapped(i),
                  child: Container(
                    color: _barStyle.background,
                    padding: EdgeInsets.symmetric(
                        vertical: _barStyle.verticalPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [_navIcons[i], _navTexts[i]],
                    ),
                  ),
                ),
              )
          ]),
        ),
      ),

      //IDENTIFIER
      if (widget.showIdentifier)
        ValueListenableBuilder<double>(
          valueListenable: _identifierPosition,
          builder: (_, double value, ___) => Positioned(
            left: value,
            width: _identifierWidth,
            height: 3.0,
            bottom: _identifierStyle.position == NavigationPosition.bottom
                ? 0
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: _identifierStyle.color,
                borderRadius: _identifierStyle.borderRadius,
              ),
            ),
          ),
        ),
    ]);
  }
}
