import 'dart:ui';

import 'package:flutter/material.dart';

///Returns a Preferred Size widget for an AppBar,
///allowing to display content below the statusbar of the device
PreferredSize preferredSafeArea({
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
    this.hideAppBarController,
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

  final ScrollController hideAppBarController;

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  double _height = 0.0;
  double _lerpOpacity = 1;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    _height = widget.height;
    if (widget.hideAppBarController != null) {
      _controller = widget.hideAppBarController;
      _controller.addListener(changeAppBarHeight);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.hideAppBarController != null) {
      _controller.removeListener(changeAppBarHeight);
    }
    super.dispose();
  }

  void changeAppBarHeight() {
    double maxOffset = 80;
    double offset = _controller.offset;
    AxisDirection direction = _controller.position.axisDirection;

    setState(() {
      if (direction == AxisDirection.up || direction == AxisDirection.down) {
        if (offset < maxOffset) {
          _height = lerpDouble(widget.height, 0, offset / maxOffset);
          _lerpOpacity = 1 - (offset / maxOffset).abs();
          print(_lerpOpacity);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? appBar(context) : null,
      body: widget.body,
      floatingActionButton: widget.floatingButton,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget appBar(BuildContext context) {
    double paddingConst = MediaQuery.of(context).size.width * 0.05;
    return preferredSafeArea(
        elevation: widget.elevation,
        backgroundColor: widget.backgroundColor,
        height: _height,
        child: Opacity(
          opacity: Interval(
            0.2,
            1.0,
            curve: Curves.ease,
          ).transform(_lerpOpacity),
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
        ));
  }
}
