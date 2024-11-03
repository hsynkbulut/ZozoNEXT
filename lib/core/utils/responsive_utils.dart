import 'package:flutter/material.dart';

class ResponsiveUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late bool isTablet;
  static late bool isPhone;
  static late bool isDesktop;
  static late Orientation orientation;

  static const double phoneBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double maxContentWidth = 1400;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    isPhone = screenWidth < phoneBreakpoint;
    isTablet = screenWidth >= phoneBreakpoint && screenWidth < tabletBreakpoint;
    isDesktop = screenWidth >= tabletBreakpoint;
  }

  static double getFontSize(double baseSize) {
    if (isDesktop) return baseSize * 1.2;
    if (isTablet) return baseSize * 1.1;
    return baseSize;
  }

  static double getSpacing(double size) {
    return blockSizeHorizontal * size;
  }

  static double getHeight(double percentage) {
    return blockSizeVertical * percentage;
  }

  static double getWidth(double percentage) {
    return blockSizeHorizontal * percentage;
  }

  static EdgeInsets getPadding(double size) {
    return EdgeInsets.all(blockSizeHorizontal * size);
  }

  static EdgeInsets getHorizontalPadding(double size) {
    return EdgeInsets.symmetric(horizontal: blockSizeHorizontal * size);
  }

  static EdgeInsets getVerticalPadding(double size) {
    return EdgeInsets.symmetric(vertical: blockSizeVertical * size);
  }

  static EdgeInsets getResponsivePadding({
    double small = 8,
    double medium = 16,
    double large = 24,
  }) {
    final size = isPhone ? small : (isTablet ? medium : large);
    return EdgeInsets.all(size);
  }

  static double getResponsiveValue({
    required double small,
    required double medium,
    required double large,
  }) {
    if (isDesktop) return large;
    if (isTablet) return medium;
    return small;
  }

  static double getContentMaxWidth() {
    return isDesktop ? maxContentWidth : screenWidth;
  }

  static int getGridCrossAxisCount() {
    if (isDesktop) return 4;
    if (isTablet) return orientation == Orientation.landscape ? 3 : 2;
    return orientation == Orientation.landscape ? 2 : 1;
  }

  static double getGridAspectRatio() {
    if (isDesktop) return 1.5;
    if (isTablet) return 1.3;
    return orientation == Orientation.landscape ? 1.5 : 1.2;
  }

  static Widget wrapWithMaxWidth(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: getContentMaxWidth()),
        child: child,
      ),
    );
  }

  static ScreenBreakpoint getBreakpoint() {
    if (isDesktop) return ScreenBreakpoint.desktop;
    if (isTablet) return ScreenBreakpoint.tablet;
    return ScreenBreakpoint.mobile;
  }
}

enum ScreenBreakpoint {
  mobile,
  tablet,
  desktop;

  bool get isMobile => this == ScreenBreakpoint.mobile;
  bool get isTablet => this == ScreenBreakpoint.tablet;
  bool get isDesktop => this == ScreenBreakpoint.desktop;
}
