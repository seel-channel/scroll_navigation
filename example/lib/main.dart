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
    return MaterialApp(title: 'Scroll Navigation Demo', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final navigationKey = GlobalKey<ScrollNavigationState>();

  @override
  Widget build(BuildContext context) {
    return ScrollNavigation(
      key: navigationKey,
      initialPage: 4,
      pages: [
        Screen(title: title("Camera")),
        Screen(title: title("Messages"), backgroundColor: Colors.red[50]),
        Screen(title: title("Favor"), body: Container(color: Colors.cyan[50])),
        Screen(title: title("Activity"), backgroundColor: Colors.yellow[50]),
        Screen(title: title("Home"))
      ],
      navItems: [
        navItem(Icons.camera),
        navItem(Icons.chat),
        navItem(Icons.favorite),
        navItem(Icons.notifications),
        navItem(Icons.home),
      ],
      pagesActionButtons: [
        FloatingActionButton(
          child: Icon(Icons.receipt),
          backgroundColor: Colors.red,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => newHome())),
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

  ScrollNavigationItem navItem(IconData icon) {
    return ScrollNavigationItem(icon: Icon(icon));
  }

  Widget newHome() {
    return Screen(
      elevation: 0,
      centerTitle: false,
      heightMultiplicator: 1,
      title: title("New Home"),
      leftWidget: ScreenReturnButton(), //IMPORTANT TO RETURN!
      body: TitleScrollNavigation(
        elevation: 0,
        titles: [
          "Page 1",
          "New page 1",
          "Old page 1",
          "Page 2",
          "New page 2",
          "Old page 2",
        ],
        pages: [
          Container(color: Colors.blue[50]),
          Container(color: Colors.red[50]),
          Container(color: Colors.yellow[50]),
          Container(color: Colors.green[50]),
          Container(color: Colors.orange[50]),
          Container(color: Colors.grey[50]),
        ],
      ),
    );
  }

  Widget title(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 22,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        wordSpacing: 1.5,
        letterSpacing: 0.5,
      ),
    );
  }
}
