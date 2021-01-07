import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum NavigationPosition { top, bottom }

class ScrollNavigationItem {
  /// Creates an item that is used with [ScrollNavigation.items].
  /// The argument [icon] should not be null and the argument [title] if null or empty don't show it.
  const ScrollNavigationItem({
    this.icon,
    this.title,
    this.titleStyle,
    this.activeIcon,
  });

  ///The icon to display inside the button.
  ///
  /// {@tool snippet}
  ///
  ///The [Icon.color] will be ignored by the activeColor and desactiveColor of the ScrollNavigation.
  ///
  /// {@tool snippet}
  ///
  ///This property must not be null.
  ///See [Icon], [ImageIcon].
  final Widget icon;

  ///The [icon] will change to the [activeIcon] when the user is on that page.
  final Widget activeIcon;

  ///If the [title] is null or empty won't show it.
  final String title;

  ///The style for title, the [color] property will ignored.
  final TextStyle titleStyle;
}

class NavigationBarStyle {
  const NavigationBarStyle({
    this.elevation = 3.0,
    this.background = Colors.white,
    this.activeColor = Colors.blue,
    this.deactiveColor = Colors.black26,
    this.verticalPadding = 20.0,
    this.position = NavigationPosition.bottom,
  });

  ///Box shadow y-elevation
  final double elevation;

  ///Background color
  final Color background;

  /// It is the color that the active icon and indicator will show.
  final Color activeColor;

  ///It's the color that will have icons that are not active.
  final Color deactiveColor;

  ///It's the vertical padding that the navItem have.
  final double verticalPadding;

  ///Change navigation position. Default is at the Bottom.
  final NavigationPosition position;
}

class NavigationTitleBarStyle {
  const NavigationTitleBarStyle({
    this.style,
    this.padding = const EdgeInsets.all(20.0),
    this.elevation = 3.0,
    this.background = Colors.white,
    this.activeColor = Colors.blue,
    this.spaceBetween = 20.0,
    this.deactiveColor = Colors.black26,
  });

  /// It is Titles style
  final TextStyle style;

  /// It is the color that the active title will show.
  final Color activeColor;

  /// It is the color that the desactive title will show.
  final Color deactiveColor;

  ///Boxshadow Y-Offset. If 0 don't show the BoxShadow
  final double elevation;

  ///Colooooors :D
  final Color background;

  ///It is the padding between titles.
  final double spaceBetween;

  ///It's the padding will have the titles container
  final EdgeInsets padding;
}

class NavigationBodyStyle {
  const NavigationBodyStyle({
    this.background,
    this.borderRadius = BorderRadius.zero,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  ///Background color
  final Color background;

  ///ClipRRect border radius
  final BorderRadiusGeometry borderRadius;

  ///How the page view should respond to user input.
  ///For example, determines how the page view continues to animate after the user stops dragging the page view.
  ///The physics are modified to snap to page boundaries using [PageScrollPhysics] prior to being used.
  ///Defaults to matching platform conventions.
  final ScrollPhysics physics;

  ///[PageView] propierty
  final DragStartBehavior dragStartBehavior;
}

class NavigationIdentiferStyle {
  const NavigationIdentiferStyle({
    this.color = Colors.blue,
    this.position = NavigationPosition.bottom,
    BorderRadiusGeometry borderRadius,
  }) : this.borderRadius = borderRadius ?? position == NavigationPosition.bottom
            ? const BorderRadius.vertical(top: Radius.circular(10.0))
            : const BorderRadius.vertical(bottom: Radius.circular(10.0));

  //Identifier color
  final Color color;

  ///Will show the identifier at the navBar bottom or at the top of the navBar.
  final NavigationPosition position;

  ///Show a circular border radius else show a simple rectangle.
  final BorderRadiusGeometry borderRadius;
}
