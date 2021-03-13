import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scroll Navigation Demo',
      home: AdvancedNavigation(),
    );
  }
}

//-------------//
//EASY EXAMPLES//
//-------------//
class EasyHorizontalNavigation extends StatelessWidget {
  const EasyHorizontalNavigation({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollNavigation(
      bodyStyle: NavigationBodyStyle(
        background: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      barStyle: NavigationBarStyle(
        background: Colors.white,
        elevation: 0.0,
      ),
      pages: [
        Container(color: Colors.blue[100]),
        Container(color: Colors.green[100]),
        Container(color: Colors.purple[100]),
        Container(color: Colors.amber[100]),
        Container(color: Colors.deepOrange[100])
      ],
      items: const [
        ScrollNavigationItem(icon: Icon(Icons.camera)),
        ScrollNavigationItem(icon: Icon(Icons.chat)),
        ScrollNavigationItem(icon: Icon(Icons.favorite)),
        ScrollNavigationItem(icon: Icon(Icons.notifications)),
        ScrollNavigationItem(icon: Icon(Icons.home))
      ],
    );
  }
}

class EasyVerticalNavigation extends StatelessWidget {
  const EasyVerticalNavigation({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollNavigation(
      bodyStyle: NavigationBodyStyle(
        background: Colors.white,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
        scrollDirection: Axis.vertical,
      ),
      barStyle: NavigationBarStyle(
        position: NavigationPosition.left,
        elevation: 0.0,
        background: Colors.white,
      ),
      pages: [
        Container(color: Colors.blue[100]),
        Container(color: Colors.green[100]),
        Container(color: Colors.purple[100]),
        Container(color: Colors.amber[100]),
        Container(color: Colors.deepOrange[100])
      ],
      items: const [
        ScrollNavigationItem(icon: Icon(Icons.camera)),
        ScrollNavigationItem(icon: Icon(Icons.chat)),
        ScrollNavigationItem(icon: Icon(Icons.favorite)),
        ScrollNavigationItem(icon: Icon(Icons.notifications)),
        ScrollNavigationItem(icon: Icon(Icons.home))
      ],
    );
  }
}

//----------------//
//ADVANCED EXAMPLE//
//----------------//
class AdvancedNavigation extends StatefulWidget {
  @override
  _AdvancedNavigationState createState() => _AdvancedNavigationState();
}

class _AdvancedNavigationState extends State<AdvancedNavigation> {
  final navigationKey = GlobalKey<ScrollNavigationState>();

  @override
  Widget build(BuildContext context) {
    return ScrollNavigation(
      key: navigationKey,
      pages: [
        Screen(
          appBar: AppBarTitle(title: "Camera"),
        ),
        Screen(
          appBar: AppBarTitle(title: "Messages"),
        ),
        Screen(
          appBar: AppBarTitle(title: "Favor"),
          body: Container(color: Colors.cyan[50]),
        ),
        Screen(
          appBar: AppBarTitle(title: "Activity"),
        ),
        Screen(appBar: AppBarTitle(title: "Home"))
      ],
      items: const [
        ScrollNavigationItem(icon: Icon(Icons.camera)),
        ScrollNavigationItem(icon: Icon(Icons.chat)),
        ScrollNavigationItem(icon: Icon(Icons.favorite)),
        ScrollNavigationItem(icon: Icon(Icons.notifications)),
        ScrollNavigationItem(
          icon: Icon(Icons.home),
          activeIcon: Icon(Icons.verified_user),
        )
      ],
      pagesActionButtons: [
        FloatingActionButton(
          child: Icon(Icons.receipt),
          backgroundColor: Colors.red,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewHome()),
          ),
        ),
        null,
        FloatingActionButton(
          onPressed: () => navigationKey.currentState.goToPage(4),
          child: Icon(Icons.arrow_right),
        ),
        null,
        FloatingActionButton(
          onPressed: () => navigationKey.currentState.goToPage(2),
          child: Icon(Icons.arrow_left),
        ),
      ],
    );
  }
}

class NewHome extends StatelessWidget {
  const NewHome({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();

    return Screen(
      appBar: AppBarTitle(title: "Title Scroll"),
      controllerToHideAppBar: controller,
      body: TitleScrollNavigation(
        barStyle: TitleNavigationBarStyle(
          style: TextStyle(fontWeight: FontWeight.bold),
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          spaceBetween: 40,
        ),
        titles: [
          "Main Page",
          "Personal Information",
          "Personalization",
          "Security",
          "Payment Methods",
        ],
        pages: [
          ListView.builder(
            itemCount: 15,
            controller: controller,
            padding: EdgeInsets.zero,
            itemBuilder: (_, __) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 50,
                  color: Colors.blue[50],
                ),
              );
            },
          ),
          Container(color: Colors.red[50]),
          Container(color: Colors.green[50]),
          Container(color: Colors.purple[50]),
          Container(color: Colors.yellow[50]),
        ],
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: -3,
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              wordSpacing: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ]),
      ),
    );
  }
}
