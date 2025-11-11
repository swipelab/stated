import 'package:flutter/widgets.dart';

abstract class Dock {
  static Widget top({
    required Widget child,
    double? left = 0,
    double? right = 0,
    double? top = 0,
    double? bottom,
    double? height,
    double? width,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      width: width,
      height: height,
      child: child,
    );
  }

  static Widget bottom({
    required Widget child,
    double? left = 0,
    double? right = 0,
    double? top,
    double? bottom = 0,
    double? width,
    double? height,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  static Widget topRight({
    required Widget child,
    double? left,
    double? right = 0,
    double? top = 0,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  static Widget topLeft({
    required Widget child,
    double? left = 0,
    double? right,
    double? top = 0,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  static Widget fill({
    required Widget child,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned.fill(
      left: left,
      right: right,
      bottom: bottom,
      top: top,
      child: child,
    );
  }
}
