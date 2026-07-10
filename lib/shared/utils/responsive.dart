import 'package:flutter/widgets.dart';

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600.0;
  static const double sidebarBreakpoint = 800.0;
  static const double tabletBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= sidebarBreakpoint;

  /// Returns grid column count for general dashboard stats (e.g. 6 items)
  static int getStatsGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletBreakpoint) return 6;
    if (width >= sidebarBreakpoint) return 3;
    if (width >= mobileBreakpoint) return 3;
    return 2;
  }

  /// Returns grid column count for 2x2 summaries or other standard grid items
  static int getSummaryGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= sidebarBreakpoint) return 4;
    return 2;
  }
}
