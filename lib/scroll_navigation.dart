library scroll_navigation;

import 'package:flutter/material.dart';

///Es una navegación que permitirá desplazarte de derecha a izquierda con gestos
///y también al presionar un elemento del Nav Item.
///
///Necesita 2 elementos: Pages y NavItems.
///
///Las páginas y NavItems deben de tener la misma cantidad de elementos.
class ScrollNavigation extends StatefulWidget {
  ScrollNavigation({
    Key key,
    @required this.pages,
    @required this.navItems,
    this.initialPage = 0,
    this.showIdentifier = true,
    this.identifierPhysics = true,
    this.activeColor = Colors.blue,
    this.desactiveColor = Colors.grey,
    this.backgroundColorBody,
    this.backgroundColorNav = Colors.white,
    this.backgroundColorAppBar = Colors.white,
    this.appBarBrightnessLight = false,
    this.appBar,
  }) : super(key: key);

  ///Es la página incial que mostrará. El valor tiene que coincidir
  ///con los índices existentes y el número total de Nav Items
  final int initialPage;

  ///Son las páginas que tendrá el Scroll
  final List<Widget> pages;

  ///Mostrará un AppBar o cualquier otro Widget.
  ///Ignorará los argumentos: [backgroundColorNav] y [appBarBrightnessLight].
  final PreferredSizeWidget appBar;

  ///Es el color que mostrará el icono activo y el indicador.
  final Color activeColor;

  ///Es el color que tendrán iconos que no estan activos.
  final Color desactiveColor;

  ///Son el listo de elementos que tendrá el menú. Deben de coindicir con
  ///el número total de páginas.
  final List<BottomNavigationBarItem> navItems;

  ///Al estar activo, este se moverá a la par que se desplaza el scroll, de
  ///otra manera, solo se moverá cuando se cambie de página.
  final bool identifierPhysics;

  ///Mostrará el identificador. Al ser falso, se ignorará el argumento
  ///[identifierPhysics]
  final bool showIdentifier;

  ///Es el color que tendrá la barra de estado del teléfono. Se recomienda
  ///que el color contraste con el color del fondo del AppBar
  final bool appBarBrightnessLight;

  final Color backgroundColorNav, backgroundColorAppBar, backgroundColorBody;

  PageController pageController;
  PageController get controller => pageController;

  @override
  _ScrollNavigationState createState() => _ScrollNavigationState();
}

class _ScrollNavigationState extends State<ScrollNavigation> {
  int maxItemsCache = 24;
  int bottomSelectedIndex;
  List<int> popUpCache = List();
  PageController pageController;
  bool identifierPhysics, itemTapped = false;
  Cubic animationCurve = Curves.linearToEaseOut;
  Duration animationDuration = Duration(milliseconds: 400);
  Map<String, double> identifier = {"position": 0.0, "width": 1.0};
  Map<String, double> scroll = {"position": 0.0, "max": 0.0, "min": 1.0};

  @override
  void initState() {
    popUpCache.add(widget.initialPage);
    bottomSelectedIndex = widget.initialPage;
    identifierPhysics = widget.identifierPhysics;
    pageController =
        PageController(initialPage: widget.initialPage, keepPage: true);
    if (widget.identifierPhysics && widget.showIdentifier)
      pageController.addListener(scrollListener);
    widget.pageController = pageController;
    super.initState();
  }

  @override
  void dispose() {
    if (identifierPhysics && widget.showIdentifier)
      pageController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: widget.appBar != null
            ? widget.appBar
            : PreferredSize(
                preferredSize: Size.fromHeight(0.0),
                child: AppBar(
                  elevation: 0.0,
                  backgroundColor: widget.backgroundColorAppBar,
                  brightness: widget.appBarBrightnessLight
                      ? Brightness.dark
                      : Brightness.light,
                ),
              ),
        body: buildPageView(context),
        bottomNavigationBar: buildBottomNavigation(context),
        resizeToAvoidBottomPadding: false,
        backgroundColor: widget.backgroundColorBody != null
            ? widget.backgroundColorBody
            : Colors.grey[100],
      ),
    );
  }

  //FUNCIONES
  void changePageIndex(int index) {
    setState(() {
      bottomSelectedIndex = index;
      if (popUpCache.length > maxItemsCache) popUpCache.clear();
      if (!itemTapped) popUpCache.add(index);
    });
  }

  void bottomItemTapped(int index) async {
    if (bottomSelectedIndex != index) {
      setState(() {
        itemTapped = true;
        popUpCache.add(index);
      });
      await pageController.animateToPage(index,
          duration: animationDuration, curve: animationCurve);
      setState(() => itemTapped = false);
    }
  }

  void scrollListener() {
    setState(() {
      scroll["position"] = pageController.position.pixels;
      scroll["min"] = pageController.position.minScrollExtent;
      scroll["max"] = pageController.position.maxScrollExtent;
    });
  }

  Future<bool> onWillPop() async {
    if (popUpCache.length != 1) {
      popUpCache.removeLast();
      bottomItemTapped(popUpCache[popUpCache.length - 1]);
      popUpCache.removeLast();
      return false;
    } else
      return true;
  }

  //WIDGETS
  Widget buildPageView(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: (index) => changePageIndex(index),
      children: widget.pages,
    );
  }

  Widget buildBottomNavigation(BuildContext context) {
    if (widget.showIdentifier) {
      double navWidth = MediaQuery.of(context).size.width;
      double itemLenght = 1 / widget.navItems.length;
      double identifierWidth = navWidth * itemLenght;

      setState(() => identifier["width"] = identifierWidth);

      if (identifierPhysics) {
        double positionScale =
            scroll["position"] / scroll["max"] - scroll["min"];
        setState(() {
          identifier["position"] = (navWidth - identifierWidth) * positionScale;

          if (identifier["position"].isNaN)
            identifier["position"] = identifierWidth * bottomSelectedIndex;
        });
      } else {
        setState(() =>
            identifier["position"] = identifierWidth * bottomSelectedIndex);
      }
    }

    return Stack(
      children: <Widget>[
        BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: bottomSelectedIndex,
          selectedItemColor: widget.activeColor,
          unselectedItemColor: widget.desactiveColor,
          backgroundColor: widget.backgroundColorNav,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => bottomItemTapped(index),
          items: widget.navItems,
        ),
        if (widget.showIdentifier)
          AnimatedPositioned(
            bottom: 0,
            left: identifier["position"],
            duration: identifierPhysics
                ? Duration(milliseconds: 100)
                : animationDuration,
            curve: animationCurve,
            child: Container(
              height: 3.0,
              width: identifier["width"],
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0)),
              ),
            ),
          ),
      ],
    );
  }
}
