# scroll_navigation

## DEMO

![](assets/readme/demo.gif)

<br><br>

---

## Features

- Scrolling pages by gestures.
- Page movement when tapping an icon.
- Indicator that follows the scroll.
- Works with the back button.
- Fancy animations on Floating Buttons.
- Customizable colors.
- Easy and powerful implementation! :)

---

<br>

## Implementation

```dart
return ScrollNavigation(
  //DEFAULT VALUES
  //initialPage = 0,
  //showIdentifier = true,
  //identifierPhysics = true,
  //identifierOnBottom = true,
  //activeColor = Colors.blue,
  //desactiveColor = Colors.grey,
  //backgroundColorNav = Colors.white,
  //backgroundColorBody = Colors.grey[100],
  pages: <Widget>[
    Screen(title: title("Camera")),
    Screen(title: title("Messages"), backgroundColor: Colors.red[50]),
    Container(color: Colors.cyan[50]),
    Screen(title: title("Activity"), backgroundColor: Colors.yellow[50]),
    Screen(title: title("Home")),
  ],
  navItems: <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.camera), title: Text(""));
    BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text(""));
    BottomNavigationBarItem(icon: Icon(Icons.favorite), title: Text(""));
    BottomNavigationBarItem(icon: Icon(Icons.notifications), title: Text(""));
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text(""));
  ],
  pagesActionButtons: [
    FloatingActionButton( //PAGE 1
      child: Icon(Icons.receipt),onPressed: () => null
    ),
    null,
    FloatingActionButton( //PAGE 3
      child: Icon(Icons.sync), onPressed: () => null,
    ),
    null,
    FloatingActionButton( //PAGE 5
      child: Icon(Icons.add), onPressed: () => print("Cool :)"),
    ),
  ],
);
```

<br><br>

---

<br><br>

## Identifier Details

#### Demo

|           identifierPhysics = True            |           identifierPhysics = False            |
| :-------------------------------------------: | :--------------------------------------------: |
| ![](assets/readme/indentifierPhysicsTrue.gif) | ![](assets/readme/indentifierPhysicsFalse.gif) |

#### Code

```dart
return ScrollNavigation(
    identifierPhysics = false, //Default is true
    pages: <Widget>[],
    navItems: <BottomNavigationBarItem>[],
);
```

<br><br>

#### showIdentifier = False

![](assets/readme/showIdentifierFalse.gif)

#### Code

```dart
return ScrollNavigation(
    showIdentifier = false, //Default is true
    pages: <Widget>[],
    navItems: <BottomNavigationBarItem>[],
);
```

<br><br>

---

<br><br>

## Screen Details

#### Screen fixes some problems the Scaffold has with the ScrollNavigation.

|               Without Widgets               |               With Widgets               |
| :-----------------------------------------: | :--------------------------------------: |
| ![](assets/readme/screenWithoutWidgets.jpg) | ![](assets/readme/screenWithWidgets.jpg) |

#### Without Widgets Code

```dart
return ScrollNavigation(
    pages: <Widget>[
      Screen(), // <--
    ],
    navItems: <BottomNavigationBarItem>[],
);
```

#### Without Code

```dart
return ScrollNavigation(
    pages: <Widget>[
      Screen(
        title: title("Home"), //Function in the Example
        leftWidget: Icon(Icons.menu, color: Colors.grey),
        rightWidget: Icon(Icons.favorite, color: Colors.grey),
      )
    ],
    navItems: <BottomNavigationBarItem>[],
);
```
