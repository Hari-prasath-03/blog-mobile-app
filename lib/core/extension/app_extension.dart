import 'package:blog_app/core/extension/navigation_extension.dart';
import 'package:flutter/cupertino.dart';

extension AppExtensions on BuildContext {
  AppNavigation get nav => AppNavigation(this);
}
