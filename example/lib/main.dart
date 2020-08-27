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
      pages: [
        Screen(title: title("Camera")),
        Screen(title: title("Messages"), backgroundColor: Colors.red[50]),
        Screen(
          title: title("Favor"),
          body: Container(color: Colors.cyan[50]),
          showAppBar: false,
        ),
        Screen(title: title("Activity"), backgroundColor: Colors.yellow[50]),
        Screen(
          title: title("Home"),
          leftWidget: Icon(Icons.menu, color: Colors.grey),
          rightWidget: Icon(Icons.favorite, color: Colors.grey),
        )
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
            context,
            MaterialPageRoute(
              builder: (context) => Screen(
                centerTitle: false,
                heightMultiplicator: 1,
                leftWidget: ScreenReturnButton(), //IMPORTANT TO RETURN!
                title: title("New Home"),
                floatingButton: FloatingActionButton(
                    onPressed: () => null, child: Icon(Icons.add)),
              ),
            ),
          ),
        ),
        null,
        FloatingActionButton(
          onPressed: () => print("Cooler Daniel xd"),
          child: Icon(Icons.sync),
        ),
        null,
        FloatingActionButton(
          onPressed: () => print("Cool :)"),
          child: Icon(Icons.add),
        ),
      ],
    );
  }

  BottomNavigationBarItem navItem(IconData icon) {
    return BottomNavigationBarItem(icon: Icon(icon), title: Text(""));
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
