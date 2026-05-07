import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  const Responsive(this.context);

  double get width => MediaQuery.sizeOf(context).width;
  double get height => MediaQuery.sizeOf(context).height;
  double get shortestSide => MediaQuery.sizeOf(context).shortestSide;

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1100;
  bool get isDesktop => width >= 1100;

  /// Generic scaling for paddings/margins.
  /// Example: padding = r.s(16)
  double s(double value) {
    final scale = isDesktop
        ? 1.25
        : isTablet
        ? 1.15
        : 1.0;
    return value * scale;
  }

  /// Scale font size using textScaleFactor as well as width breakpoint.
  double fs(double value) {
    final t = MediaQuery.textScalerOf(context).scale(1.0);
    final base = isDesktop
        ? 1.1
        : isTablet
        ? 1.05
        : 1.0;
    return value * base * t;
  }

  /// Grid cross-axis count for product tiles.
  int gridCrossAxisCount() {
    if (isDesktop) return 3;
    if (isTablet) return 2;
    return 2;
  }

  /// Banner height based on device size.
  double bannerHeight() {
    if (isDesktop) return 260;
    if (isTablet) return 230;
    return 200;
  }

  /// Bottom navigation bar height.
  double bottomNavHeight() {
    if (isDesktop) return 80;
    if (isTablet) return 78;
    return 85;
  }

  /// Sticky search header height.
  double stickyHeaderHeight() {
    if (isDesktop) return 76;
    return 80;
  }
}
