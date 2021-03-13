import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScreenReturnButton extends StatelessWidget {
  ///It's a simple icon that serves as a return button,
  ///It's function is to close the context.
  const ScreenReturnButton({Key? key, this.size = 24, this.color = Colors.grey})
      : super(key: key);

  ///The size of the icon in logical pixels.
  final double size;

  ///The color to use when drawing the icon.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.goBack,
      child: Icon(Icons.arrow_back, color: color, size: size),
    );
  }
}

class Screen extends StatefulWidget {
  // It is a Widget very similar to a Scaffold, in a way, it uses the
  ///Scaffold core, but fixes some problems the Scaffold has with the
  ///ScrollNavigation.
  Screen({
    Key? key,
    this.appBar,
    this.body,
    this.floatingButton,
    this.controllerToHideAppBar,
    this.offsetToHideAppBar = 80.0,
  }) : super(key: key);

  final Widget? appBar;

  ///It is the body of the Scaffold, you can place any Widget.
  final Widget? body;

  ///It is recommended to use the [pages ActionButtons] property of the Scroll Navigation.
  ///Otherwise, it works like the [floatingActionButton] of the Scaffold
  final Widget? floatingButton;

  ///This parameter is used to hide the appbar when scrolling vertically
  ///a listview or some other scrolling widget that accepts a ScrollController.
  final ScrollController? controllerToHideAppBar;

  ///It's the number of pixels that scrolling will need to hide or
  ///show the appbar. The smaller the number of pixels, the faster
  ///the application bar will hide when scrolling; otherwise,
  ///it will take longer to hide.
  final double offsetToHideAppBar;

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final ValueNotifier<double> _height = ValueNotifier<double>(0.0);
  late double _appBarHeight = 1.0;
  final GlobalKey _appBarKey = GlobalKey();

  ScrollController? _controller;
  double? _heightRef = 0, _offsetRef = 0;
  bool _upping = false;

  @override
  void initState() {
    if (widget.controllerToHideAppBar != null) {
      _heightRef = _height.value;
      _controller = widget.controllerToHideAppBar;
      _controller!.addListener(_controllerListener);
      Misc.onLayoutRendered(
        () => setState(() {
          final height = _appBarKey.height;
          print(height);
          _height.value = height;
          _appBarHeight = height;
        }),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controllerToHideAppBar != null)
      _controller!.removeListener(_controllerListener);
    _height.dispose();
    super.dispose();
  }

  void _controllerListener() {
    ScrollDirection direction = _controller!.position.userScrollDirection;
    AxisDirection axisDirection = _controller!.position.axisDirection;

    if (axisDirection == AxisDirection.up ||
        axisDirection == AxisDirection.down) {
      //Subiendo
      if (direction == ScrollDirection.forward) {
        if (!_upping) setRefs();
        _updateHeight(_appBarHeight);
      }
      //Bajando
      if (direction == ScrollDirection.reverse) {
        if (_upping) setRefs();
        _updateHeight(0);
      }
    }
  }

  void setRefs() {
    setState(() {
      _upping = !_upping;
      _heightRef = _height.value;
      _offsetRef = _controller!.offset;
    });
  }

  void _updateHeight(double toValue) {
    double lerp =
        (_offsetRef! - _controller!.offset) / widget.offsetToHideAppBar;
    lerp = lerp.abs();
    if (lerp <= 1.0)
      _height.value = lerpDouble(_heightRef, toValue, lerp) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        widget.controllerToHideAppBar != null
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                ValueListenableBuilder(
                  valueListenable: _height,
                  builder: (_, double value, __) {
                    return ClipRRect(
                      child: Transform.translate(
                        offset: Offset(0.0, (_appBarHeight - value) * -1),
                        child: Container(
                          key: _appBarKey,
                          child: widget.appBar ?? SizedBox(),
                        ),
                      ),
                    );
                  },
                ),
              ])
            : widget.appBar ?? SizedBox(),
        Expanded(child: widget.body ?? Container()),
      ]),
      floatingActionButton: widget.floatingButton,
      resizeToAvoidBottomInset: false,
    );
  }
}
