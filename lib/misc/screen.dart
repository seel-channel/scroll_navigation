import 'package:flutter/material.dart';

///Returns a Preferred Size widget for an AppBar,
///allowing to display content below the statusbar of the device
PreferredSize preferredSafeArea({
  Widget child,
  Color backgroundColor = Colors.white,
  double heightMultiplicator = 1,
  double elevation = 3,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(kToolbarHeight * heightMultiplicator),
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

class Screen extends StatelessWidget {
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
    this.heightMultiplicator = 1.5,
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

  ///It is used to give more space, padding or separation to the AppBar.
  final double heightMultiplicator;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? appBar(context) : null,
      body: body,
      floatingActionButton: floatingButton,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget appBar(BuildContext context) {
    double paddingConst =
        MediaQuery.of(context).size.width * 0.05 * heightMultiplicator;
    return preferredSafeArea(
      elevation: elevation,
      backgroundColor: backgroundColor,
      heightMultiplicator: heightMultiplicator,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingConst),
        child: centerTitle
            ? Stack(alignment: AlignmentDirectional.centerStart, children: [
                Center(child: title),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: leftWidget,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Container(child: rightWidget)],
                ),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: leftWidget == null
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(right: paddingConst),
                          child: leftWidget),
                ),
                Expanded(flex: 70, child: title),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: rightWidget == null
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(left: paddingConst),
                          child: rightWidget),
                ),
              ]),
      ),
    );
  }
}
