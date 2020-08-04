import 'package:flutter/material.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      pages: <Widget>[
        Screen(title: "Camera", body: Container(color: Colors.blue)),
        Screen(title: "Messages", body: Container(color: Colors.green)),
        Screen(
          title: "Favorite",
          body: Container(color: Colors.amber),
          floatingButton: FloatingActionButton(
            onPressed: () => print("Cool :)"),
            child: Icon(Icons.add),
          ),
        ),
        Screen(title: "Notifications", body: Container(color: Colors.yellow)),
        Screen(title: "Home", body: Container(color: Colors.lightBlue)),
      ],
      navItems: <BottomNavigationBarItem>[
        navItem(Icons.camera),
        navItem(Icons.chat),
        navItem(Icons.favorite),
        navItem(Icons.notifications),
        navItem(Icons.home),
      ],
    );
  }

  BottomNavigationBarItem navItem(IconData icon) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      title: Text(""),
    );
  }
}

//SCAFFOLD WITH CUSTOM APPBAR
class Screen extends StatelessWidget {
  final String title;
  final Widget body, floatingButton;
  Screen({Key key, this.title, this.body, this.floatingButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight * 1.5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: -3,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Center(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  wordSpacing: 1.5,
                  letterSpacing: 0.5),
            ),
          ),
        ),
      ),
      body: body,
      floatingActionButton: floatingButton,
    );
  }
}
