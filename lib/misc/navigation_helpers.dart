import 'package:flutter/material.dart';

class ScrollNavigationItem {
  /// Creates an item that is used with [ScrollNavigation.navItems].
  /// The argument [icon] should not be null and the argument [title] if null or empty don't show it.
  ScrollNavigationItem({@required this.icon, this.title, this.titleStyle});

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

  ///If the [title] is null or empty won't show it.
  final String title;

  ///The style for title, the [color] property will ignored.
  final TextStyle titleStyle;
}

class TitleScrollPadding {
  /// Creates insets with only the given values non-zero.
  ///
  /// {@tool snippet}
  ///
  /// Left margin indent of 40 pixels:
  ///
  /// ```dart
  /// const TitleScrollPadding(left: 40.0)
  /// ```
  /// {@end-tool}
  TitleScrollPadding({
    this.left = 10.0,
    this.top = 10.0,
    this.right = 10.0,
    this.bottom = 10.0,
    this.betweenTitles = 20,
  });

  /// Creates insets where all the offsets are `value`.
  ///
  /// {@tool snippet}
  ///
  /// Typical eight-pixel margin on all sides:
  ///
  /// ```dart
  /// const TitleScrollPadding.all(8.0)
  /// ```
  /// {@end-tool}
  TitleScrollPadding.all(double amount, {this.betweenTitles = 20}) {
    left = amount;
    right = amount;
    top = amount;
    bottom = amount;
  }

  final double betweenTitles;
  double left, right, top, bottom;
}
