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
  ScrollController controller = ScrollController();
  final navigationKey = GlobalKey<ScrollNavigationState>();

  @override
  Widget build(BuildContext context) {
    return ScrollNavigation(
      key: navigationKey,
      initialPage: 4,
      pages: [
        Screen(title: title("Camera")),
        Screen(title: title("Messages"), backgroundColor: Colors.yellow[50]),
        Screen(title: title("Favor"), body: Container(color: Colors.cyan[50])),
        Screen(title: title("Activity"), backgroundColor: Colors.yellow[50]),
        Screen(title: title("Home"))
      ],
      navItems: [
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

  Widget newHome() {
    return Screen(
      height: 56.0,
      elevation: 0,
      centerTitle: false,
      hideAppBarController: controller,
      title: title("Title Scroll"),
      leftWidget: ScreenReturnButton(), //IMPORTANT TO RETURN!
      body: TitleScrollNavigation(
        titles: ["Page 1", "New page", "Second new page"],
        pages: [
          ListView.builder(
            itemCount: 15,
            controller: controller,
            itemBuilder: (context, key) {
              return Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  color: Colors.blue[50],
                ),
              );
            },
          ),
          Container(color: Colors.red[50]),
          Container(color: Colors.yellow[50]),
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
