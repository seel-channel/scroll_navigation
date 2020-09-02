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
    this.titleBold = true,
    this.padding,
    this.elevation = 3.0,
    this.identifierWithBorder = false,
    this.identifierColor = Colors.blue,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
  }) : super(key: key);

  final List<String> titles;

  /// Are the pages that the Scroll Page will have
  final List<Widget> pages;

  /// It is the initial page that will show. The value must match
  /// with the existing indexes and the total number of Nav Items
  final int initialPage;

  final TitleScrollPadding padding;

  final bool identifierWithBorder;

  final bool titleBold;

  final double titleSize;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  final Color activeColor;
  final Color desactiveColor;
  final Color identifierColor;
  final Color backgroundColorNav, backgroundColorBody;

  @override
  _TitleScrollNavigationState createState() => _TitleScrollNavigationState();
}

class _TitleScrollNavigationState extends State<TitleScrollNavigation> {
  List<String> _titles = List();
  TitleScrollPadding _padding;
  PageController _pageController;
  Map<String, double> _identifier = Map();
  Map<String, Map<String, dynamic>> _titlesProps = Map();

  @override
  void initState() {
    _createTitleProps();
    _setColorLerp(widget.initialPage, 1.0);
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(_scrollListener);
    widget.padding == null
        ? _padding = TitleScrollPadding()
        : _padding = widget.padding;
    WidgetsBinding.instance.addPostFrameCallback((_) => _setTitleWidth());
    super.initState();
  }

  void _createTitleProps() {
    for (var i = 0; i < widget.titles.length - 1; i++) {
      String title = "${widget.titles[i]}$i";
      _titlesProps[title] = {"lerp": 0.0, "key": GlobalKey()};
      _titles.add(title);
    }
  }

  void _clearLerp() {
    for (var title in _titles) _titlesProps[title]["lerp"] = 0.0;
  }

  void _setColorLerp(int index, double result) {
    _titlesProps[_titles[index]]["lerp"] = result;
  }

  void _setTitleWidth() {
    setState(() {
      for (var title in _titles) {
        double width = _titlesProps[title]["key"].currentContext.size.width;
        _titlesProps[title]["width"] = width;
      }
      _identifier["width"] = _getProps(widget.initialPage, "width");
      _identifier["position"] = _padding.left;
    });
  }

  double _getProps(int index, String prop) {
    return _titlesProps[_titles[index]][prop];
  }

  double _getIdentifierWidth(double index) {
    double indexDiff = index - index.floor();
    double floorWidth({int sum = 0}) => _getProps(index.floor() + sum, "width");
    return floorWidth() + (floorWidth(sum: 1) - floorWidth()) * indexDiff;
  }

  double _getIdentifierPosition(double index) {
    double position = 0;
    double indexDiff = index - index.floor();
    double widthPadding(i) => _getProps(i, "width") + _padding.betweenTitles;
    for (var i = 0; i < index.floor(); i++) position += widthPadding(i);
    return position + widthPadding(index.floor()) * indexDiff + _padding.left;
  }

  void _scrollListener() {
    int pageFloor = _pageController.page.floor();
    double pageDecimal = _pageController.page - pageFloor;

    setState(() {
      _identifier["width"] = _getIdentifierWidth(_pageController.page);
      _identifier["position"] = _getIdentifierPosition(_pageController.page);
      _clearLerp();
      _setColorLerp(pageFloor + 1, pageDecimal);
      _setColorLerp(pageFloor, 1 - pageDecimal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: preferredSafeArea(
          elevation: widget.elevation,
          backgroundColor: widget.backgroundColorNav,
          child: _buildScrollTitles()),
      resizeToAvoidBottomPadding: false,
      body: PageView(controller: _pageController, children: widget.pages),
      backgroundColor: widget.backgroundColorBody != null
          ? widget.backgroundColorBody
          : Colors.grey[100],
    );
  }

  Widget _buildScrollTitles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: _padding.left,
                top: _padding.top,
                right: _padding.right,
                bottom: _padding.bottom),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ..._titles.asMap().entries.map((title) {
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: () async {
                      await _pageController.animateToPage(
                        title.key,
                        curve: Curves.linearToEaseOut,
                        duration: Duration(milliseconds: 400),
                      );
                    },
                    child: Text(
                      widget.titles[title.key],
                      key: _titlesProps[title.value]["key"],
                      maxLines: 1,
                      style: TextStyle(
                        color: Color.lerp(
                            widget.desactiveColor,
                            widget.activeColor,
                            _titlesProps[title.value]["lerp"]),
                        fontWeight: widget.titleBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: widget.titleSize,
                      ),
                    ),
                  ),
                  if (_titles.last != title.value)
                    SizedBox(width: _padding.betweenTitles),
                ]);
              })
            ]),
          ),
          AnimatedPositioned(
            bottom: 0,
            height: 3.0,
            width: _identifier["width"],
            left: _identifier["position"],
            duration: Duration(milliseconds: 50),
            child: Container(
              decoration: BoxDecoration(
                color: widget.identifierColor,
                borderRadius: widget.identifierWithBorder
                    ? BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0))
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TitleScrollPadding {
  /// Creates insets with only the given values non-zero.
  ///
  /// {@tool snippet}
  ///
  /// Left margin indent of 40 pixels:
  ///
  /// ```dart
  /// const TitleScrollPadding(left: 40.0)
  /// ```
  /// {@end-tool}
  TitleScrollPadding({
    this.left = 10.0,
    this.top = 10.0,
    this.right = 10.0,
    this.bottom = 10.0,
    this.betweenTitles = 20,
  });

  /// Creates insets where all the offsets are `value`.
  ///
  /// {@tool snippet}
  ///
  /// Typical eight-pixel margin on all sides:
  ///
  /// ```dart
  /// const TitleScrollPadding.all(8.0)
  /// ```
  /// {@end-tool}
  TitleScrollPadding.all(double amount, {this.betweenTitles = 20}) {
    left = amount;
    right = amount;
    top = amount;
    bottom = amount;
  }

  final double betweenTitles;
  double left, right, top, bottom;
}
