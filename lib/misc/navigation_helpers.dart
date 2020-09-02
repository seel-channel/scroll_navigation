import 'package:flutter/material.dart';

class ScrollNavigationItem {
  /// Creates an item that is used with [ScrollNavigation.navItems].
  /// The argument [icon] should not be null and the argument [title] if null or empty don't show it.
  ScrollNavigationItem({@required this.icon, this.title, this.titleStyle});
  final Widget icon;
  final String title;
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

TextStyle lerpTitleStyle({Color color, TextStyle style}) {
  style = style == null ? TextStyle() : style;

  return TextStyle(
    color: color,
    inherit: style.inherit,
    backgroundColor: style.backgroundColor,
    fontSize: style.fontSize,
    fontWeight: style.fontWeight,
    fontStyle: style.fontStyle,
    letterSpacing: style.letterSpacing,
    wordSpacing: style.wordSpacing,
    textBaseline: style.textBaseline,
    height: style.height,
    locale: style.locale,
    foreground: style.foreground,
    background: style.background,
    shadows: style.shadows,
    fontFeatures: style.fontFeatures,
    decoration: style.decoration,
    decorationColor: style.decorationColor,
    decorationStyle: style.decorationStyle,
    decorationThickness: style.decorationThickness,
    debugLabel: style.debugLabel,
    fontFamily: style.fontFamily,
    fontFamilyFallback: style.fontFamilyFallback,
  );
}
