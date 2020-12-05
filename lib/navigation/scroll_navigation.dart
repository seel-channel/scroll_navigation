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
    this.pages,
    this.navItems,
    this.pagesActionButtons,
    this.initialPage = 0,
    this.navigationOnTop = false,
    this.showIdentifier = true,
    this.identifierPhysics = true,
    this.identifierOnBottom = true,
    BorderRadiusGeometry identifierBorderRadius,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundBody,
    this.backgroundNav = Colors.white,
    this.verticalPadding = 18,
    this.elevation = 3.0,
  })  : assert(navItems != null && pages != null),
        assert(navItems.length == pages.length),
        this.identifierBorderRadius =
            identifierBorderRadius ?? identifierOnBottom
                ? BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0))
                : BorderRadius.only(
                    bottomRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0)),
        super(key: key);

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

  ///Change navigation position. Default is at the Bottom [false].
  final bool navigationOnTop;

  ///It's the color that will have icons that are not active.
  final Color desactiveColor;

  ///They are the list of elements that the menu will have.
  ///They must match the total number of pages.
  final List<ScrollNavigationItem> navItems;

  ///When active, the indicator will move along with the scroll of the pages.
  ///Of other way, it will only move when you change page.
  final bool identifierPhysics;

  ///It will show the identifier.
  ///If false, the argument [identifierPhysics] will be ignored
  final bool showIdentifier;

  ///Show a circular border radius else show a simple rectangle.
  final BorderRadiusGeometry identifierBorderRadius;

  ///If true, will show the identifier at the navBar bottom.
  ///Else, at the top of the navBar.
  final bool identifierOnBottom;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  ///It's the vertical padding that the navItem have.
  final double verticalPadding;

  ///Colooooors :D
  final Color backgroundNav, backgroundBody;

  @override
  ScrollNavigationState createState() => ScrollNavigationState();
}

class ScrollNavigationState extends State<ScrollNavigation> {
  double _navTopHeight = 0;
  int _bottomIndex = 0;
  int _maxItemsCache = 5;
  bool _identifierPhysics;
  bool _itemTapped = false;
  Orientation _orientation;
  PageController _pageController;
  GlobalKey _navigationKey = GlobalKey();
  Cubic _animationCurve = Curves.linearToEaseOut;
  List<int> _popUpCache = List();
  Map<String, double> _identifier = Map();
  List<Widget> _pagesActionButtons = List();
  List<Map<String, dynamic>> _itemProps = List();

  ///Go to a page :)
  void goToPage(int index) => _onBottomItemTapped(index);

  @override
  void initState() {
    _bottomIndex = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _identifierPhysics = widget.identifierPhysics;
    _pageController.addListener(_scrollListener);
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
    for (int i = 0; i < widget.navItems.length; i++) {
      _itemProps.add({"lerp": 0.0});
    }

    //SET HEIGHT FOR NAVIGATIONONTOP
    if (widget.navigationOnTop)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        double maxFontSize = 0;
        double maxIconSize = 0;
        int itemsWithTitle = 0;
        for (ScrollNavigationItem item in widget.navItems) {
          final Icon icon = item.icon;
          final TextStyle style = item.titleStyle;
          final double fontSize = style != null ? style.fontSize : 0.0;
          final double iconSize =
              icon != null ? icon.size ?? IconTheme.of(context).size : 0.0;
          if (item.title != null && item.title.isNotEmpty) itemsWithTitle += 1;
          if (fontSize > maxFontSize) maxFontSize = fontSize;
          if (iconSize > maxIconSize) maxIconSize = iconSize;
        }
        final double spaceBeetween = itemsWithTitle == 0 ? 0 : 5;
        final double titleHeight = itemsWithTitle == 0 ? 0 : maxFontSize;
        final double heightItem = (widget.verticalPadding * 2) +
            maxIconSize +
            titleHeight +
            spaceBeetween;
        setState(() => _navTopHeight = heightItem);
      });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    double page = _pageController.page;
    int currentPage = page.floor();
    setState(() {
      if (_identifierPhysics) {
        if (_itemTapped) _clearColorLerp();
        if (currentPage + 1 < widget.pages.length)
          _setColorLerp(currentPage + 1, (page - currentPage));
        _setColorLerp(currentPage, 1 - (page - currentPage));
        if (widget.showIdentifier)
          _identifier["position"] = _identifier["width"] * page;
      } else {
        _clearColorLerp();
        _setColorLerp(page.round(), 1.0);
        if (widget.showIdentifier)
          _identifier["position"] = _identifier["width"] * page.round();
      }
      _bottomIndex = page.round();
    });
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
    if (_bottomIndex != index) {
      setState(() {
        _itemTapped = true;
        _popUpCache.add(index);
      });
      await _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 500),
        curve: _animationCurve,
      );
      setState(() {
        _itemTapped = false;
        _clearColorLerp();
        _setColorLerp(_bottomIndex, 1.0);
      });
    }
  }

  //----------//
  //COLOR LERP//
  //----------//
  void _clearColorLerp() {
    for (int i = 0; i < widget.navItems.length; i++)
      _itemProps[i]["lerp"] = 0.0;
  }

  void _setColorLerp(int index, double result) {
    _itemProps[index]["lerp"] = result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPressBackButton,
      child: OrientationBuilder(
        builder: (_, Orientation orientation) {
          if (_orientation == null || _orientation != orientation) {
            double width = MediaQuery.of(context).size.width;
            width = width * (1 / widget.navItems.length);
            _orientation = orientation;
            _identifier["width"] = width;
            _identifier["position"] = width * _bottomIndex;
            _setColorLerp(_bottomIndex, 1.0);
          }

          return Scaffold(
            appBar: widget.navigationOnTop
                ? preferredSafeArea(
                    height: _navTopHeight,
                    elevation: widget.elevation,
                    backgroundColor: widget.backgroundNav,
                    child: _buildBottomNavigation(elevation: widget.elevation))
                : null,
            body: PageView(
              children: widget.pages,
              controller: _pageController,
              onPageChanged: (index) => setState(() {
                if (_popUpCache.length > _maxItemsCache)
                  _popUpCache.removeAt(0);
                if (!_itemTapped) _popUpCache.add(index);
              }),
            ),
            bottomNavigationBar: !widget.navigationOnTop
                ? _buildBottomNavigation(elevation: 1 - widget.elevation)
                : null,
            backgroundColor: widget.backgroundBody != null
                ? widget.backgroundBody
                : Colors.grey[100],
            floatingActionButton: _pagesActionButtons[_bottomIndex],
            resizeToAvoidBottomPadding: false,
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation({double elevation}) {
    return Stack(
      children: <Widget>[
        Container(
          key: _navigationKey,
          decoration: BoxDecoration(
            color: widget.backgroundNav,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: -3,
                blurRadius: 2,
                offset: Offset(0, elevation),
              ),
            ],
          ),
          child: Row(children: _buildNavIcon()),
        ),
        if (widget.showIdentifier) _buildIdentifier()
      ],
    );
  }

  Widget _buildIdentifier() {
    return AnimatedPositioned(
      height: 3.0,
      width: _identifier["width"],
      left: _identifier["position"],
      bottom: widget.identifierOnBottom ? 0 : null,
      duration: _identifierPhysics
          ? Duration(milliseconds: 0)
          : Duration(milliseconds: 200),
      curve: _animationCurve,
      child: Container(
        decoration: BoxDecoration(
          color: widget.activeColor,
          borderRadius: widget.identifierBorderRadius,
        ),
      ),
    );
  }

  List<Widget> _buildNavIcon() {
    return [
      ...widget.navItems.asMap().entries.map((item) {
        final int key = item.key;
        final double lerp = _itemProps[key]["lerp"];
        final ScrollNavigationItem value = item.value;

        Color colorLerp() {
          return Color.lerp(widget.desactiveColor, widget.activeColor, lerp);
        }

        Widget iconMerged() {
          return IconTheme.merge(
            key: ValueKey<int>(key),
            child: value.activeIcon == null
                ? value.icon
                : lerp > 0.6
                    ? value.activeIcon
                    : value.icon,
            data: IconThemeData(color: colorLerp()),
          );
        }

        Widget textMerged() {
          return Text(
            value.title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorLerp()).merge(value.titleStyle),
          );
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => _onBottomItemTapped(key),
            child: Container(
              color: widget.backgroundNav,
              padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.navigationOnTop
                      ? Expanded(child: iconMerged())
                      : iconMerged(),
                  if (value.title != null && value.title.isNotEmpty)
                    widget.navigationOnTop
                        ? Expanded(child: textMerged())
                        : textMerged(),
                ],
              ),
            ),
          ),
        );
      })
    ];
  }
}
