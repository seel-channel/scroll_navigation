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
  @override
  Widget build(BuildContext context) {
    return ScrollNavigation(
      initialPage: 4,
      pages: <Widget>[
        Screen(title: title("Camera"), body: Container(color: Colors.blue)),
        Screen(title: title("Messages"), body: Container(color: Colors.green)),
        Screen(title: title("Favorite"), body: Container(color: Colors.amber)),
        Screen(title: title("Activity"), body: Container(color: Colors.yellow)),
        Screen(title: title("Home"), body: Container(color: Colors.lightBlue)),
      ],
      navItems: bottomNavItems(),
      pagesActionButtons: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.receipt),
          backgroundColor: Colors.grey[600],
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Screen(
                returnButton: true, //IMPORTANT TO RETURN!
                title: title("New Page"),
                body: Container(color: Colors.amber),
                floatingButton: FloatingActionButton(
                  onPressed: () => print("Cool :)"),
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ),
        ),
        null,
        null,
        null,
        DoubleFloatingIcon(
          smallIcon: Icon(Icons.edit),
          bigIcon: Icon(Icons.search),
        ),
      ],
    );
  }

  List<BottomNavigationBarItem> bottomNavItems() {
    return [
      navItem(Icons.camera),
      navItem(Icons.chat),
      navItem(Icons.favorite),
      navItem(Icons.notifications),
      navItem(Icons.home),
    ];
  }

  BottomNavigationBarItem navItem(IconData icon) {
    return BottomNavigationBarItem(icon: Icon(icon), title: Text(""));
  }

  Widget title(String title) {
    return Center(
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 22,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          wordSpacing: 1.5,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
