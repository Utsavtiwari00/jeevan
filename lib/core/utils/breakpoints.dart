import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  static const double compactLimit = 600;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactLimit;
  }

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compactLimit && width < 900;
  }

  static T value<T>(BuildContext context, {required T compact, T? medium}) {
    if (isCompact(context)) return compact;
    if (isMedium(context) && medium != null) return medium;
    return medium ?? compact; // Add large when needed, default to medium/compact
  }
}
