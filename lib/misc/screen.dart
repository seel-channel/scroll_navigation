import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScreenReturnButton extends StatelessWidget {
  ///It's a simple icon that serves as a return button,
  ///It's function is to close the context.
  const ScreenReturnButton({Key key, this.size = 24, this.color = Colors.grey})
      : super(key: key);

  ///The size of the icon in logical pixels.
  final double size;

  ///The color to use when drawing the icon.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Icon(Icons.arrow_back, color: color, size: size),
    );
  }
}

class Screen extends StatefulWidget {
  // It is a Widget very similar to a Scaffold, in a way, it uses the
  ///Scaffold core, but fixes some problems the Scaffold has with the
  ///ScrollNavigation.
  Screen({
    Key key,
    this.body,
    this.floatingButton,
    this.leftWidget,
    this.title,
    this.rightWidget,
    this.showAppBar = true,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.controllerToHideAppBar,
    this.offsetToHideAppBar = 80.0,
    this.height = 84,
    this.elevation = 3.0,
  }) : super(key: key);

  ///It is the body of the Scaffold, you can place any Widget.
  final Widget body;

  ///It is recommended to use the [pages ActionButtons] property of the Scroll Navigation.
  ///Otherwise, it works like the [floatingActionButton] of the Scaffold
  final Widget floatingButton;

  ///Appears to the left of the Appbar in the same position as the [returnButton].
  ///If the returnButton is active, this Widget will be ignored.
  final Widget leftWidget;

  ///It is the central widget of the Appbar, it is recommended to use for titles.
  final Widget title;

  ///Appears to the right of the Appbar. You can put a [Row],
  ///but the [MainAxisSize.min] property must be activated
  final Widget rightWidget;

  ///Center the Title Widgets.
  final bool centerTitle;

  ///If active, it shows the appbar; otherwise it will not.
  ///Ignoring the left widget, right widget, and title widget
  final bool showAppBar;

  ///Color that customizes the AppBar.
  final Color backgroundColor;

  ///It is used to give the AppBar height.
  final double height;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  ///This parameter is used to hide the appbar when scrolling vertically
  ///a listview or some other scrolling widget that accepts a ScrollController.
  final ScrollController controllerToHideAppBar;

  ///It's the number of pixels that scrolling will need to hide or
  ///show the appbar. The smaller the number of pixels, the faster
  ///the application bar will hide when scrolling; otherwise,
  ///it will take longer to hide.
  final double offsetToHideAppBar;

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final ValueNotifier _height = ValueNotifier<double>(0.0);
  ScrollController _controller;
  double _heightRef = 0, _offsetRef = 0;
  bool _subiendo = false;

  @override
  void initState() {
    _height.value = widget.height;
    _heightRef = _height.value;
    if (widget.controllerToHideAppBar != null) {
      _controller = widget.controllerToHideAppBar;
      _controller.addListener(changeAppBarHeight);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controllerToHideAppBar != null)
      _controller.removeListener(changeAppBarHeight);
    super.dispose();
  }

  void changeAppBarHeight() {
    ScrollDirection direction = _controller.position.userScrollDirection;
    AxisDirection axisDirection = _controller.position.axisDirection;

    if (axisDirection == AxisDirection.up ||
        axisDirection == AxisDirection.down) {
      //Subiendo
      if (direction == ScrollDirection.forward) {
        if (!_subiendo) setRefs();
        setHeight(widget.height);
      }
      //Bajando
      if (direction == ScrollDirection.reverse) {
        if (_subiendo) setRefs();
        setHeight(0);
      }
    }
  }

  void setRefs() {
    setState(() {
      _subiendo = !_subiendo;
      _heightRef = _height.value;
      _offsetRef = _controller.offset;
    });
  }

  void setHeight(double toValue) {
    double lerp = (_offsetRef - _controller.offset) / widget.offsetToHideAppBar;
    lerp = lerp.abs();
    if (lerp <= 1.0) _height.value = lerpDouble(_heightRef, toValue, lerp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? appBar(context) : null,
      body: widget.body,
      floatingActionButton: widget.floatingButton,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget appBar(BuildContext context) {
    double paddingConst = MediaQuery.of(context).size.width * 0.05;
    return AnimatedBuilder(
        animation: _height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingConst),
          child: widget.centerTitle
              ? Stack(alignment: AlignmentDirectional.centerStart, children: [
                  Center(child: widget.title),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: widget.leftWidget,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Container(child: widget.rightWidget)],
                  ),
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: widget.leftWidget == null
                        ? null
                        : Padding(
                            padding: EdgeInsets.only(right: paddingConst),
                            child: widget.leftWidget),
                  ),
                  Expanded(flex: 70, child: widget.title),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: widget.rightWidget == null
                        ? null
                        : Padding(
                            padding: EdgeInsets.only(left: paddingConst),
                            child: widget.rightWidget),
                  ),
                ]),
        ),
        builder: (_, child) {
          return _preferredSafeArea(
            elevation: widget.elevation,
            backgroundColor: widget.backgroundColor,
            height: _height.value,
            child: Opacity(
              opacity: Interval(
                0.2,
                1.0,
                curve: Curves.ease,
              ).transform(_height.value / widget.height),
              child: child,
            ),
          );
        });
  }

  PreferredSize _preferredSafeArea({
    Widget child,
    Color backgroundColor = Colors.white,
    double height = 84,
    double elevation = 3,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: -3,
              blurRadius: 2,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
