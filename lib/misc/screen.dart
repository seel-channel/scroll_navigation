import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  final GlobalKey _appBarKey = GlobalKey();
  late double _appBarHeight = 0.0;

  ScrollController? _controller;
  double _heightRef = 0, _offsetRef = 0;
  bool _upping = false;

  @override
  void initState() {
    if (widget.controllerToHideAppBar != null) {
      _heightRef = _height.value;
      _controller = widget.controllerToHideAppBar;
      _controller!.addListener(_controllerListener);
      Misc.onLayoutRendered(() {
        final height = _appBarKey.height;
        if (height != null)
          setState(() {
            _height.value = height;
            _appBarHeight = height;
            _heightRef = height;
          });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controllerToHideAppBar != null) {
      _controller!.removeListener(_controllerListener);
      _controller!.dispose();
    }
    _height.dispose();
    super.dispose();
  }

  void _controllerListener() {
    final ScrollDirection direction = _controller!.position.userScrollDirection;
    final AxisDirection axisDirection = _controller!.position.axisDirection;

    if (axisDirection == AxisDirection.up ||
        axisDirection == AxisDirection.down) {
      //UPPING
      if (direction == ScrollDirection.forward) {
        if (!_upping) setRefs();
        _updateHeight(_appBarHeight);
      }
      //DOWNING
      if (direction == ScrollDirection.reverse) {
        if (_upping) setRefs();
        _updateHeight(0.0);
      }
    }
  }

  void setRefs() {
    _upping = !_upping;
    _heightRef = _height.value;
    _offsetRef = _controller!.offset;
  }

  void _updateHeight(double toValue) {
    final double lerp =
        ((_offsetRef - _controller!.offset) / widget.offsetToHideAppBar).abs();
    _height.value =
        lerpDouble(_heightRef, toValue, lerp <= 1.0 ? lerp : 1.0) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(children: [
          if (widget.controllerToHideAppBar != null)
            ValueListenableBuilder(
              valueListenable: _height,
              builder: (_, double value, __) => SizedBox(height: value),
            ),
          Expanded(child: widget.body ?? Container()),
        ]),
        widget.controllerToHideAppBar != null
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                ClipRRect(
                  child: ValueListenableBuilder(
                    valueListenable: _height,
                    child: Container(
                      key: _appBarKey,
                      child: widget.appBar ?? SizedBox(),
                    ),
                    builder: (_, double value, child) {
                      final offset = (_appBarHeight - value) * -1;
                      return Transform.translate(
                        offset: Offset(
                          0.0,
                          value == 0.0 ? offset - 5 : offset,
                        ),
                        child: child,
                      );
                    },
                  ),
                ),
              ])
            : widget.appBar ?? SizedBox(),
      ]),
      floatingActionButton: widget.floatingButton,
      resizeToAvoidBottomInset: false,
    );
  }
}
