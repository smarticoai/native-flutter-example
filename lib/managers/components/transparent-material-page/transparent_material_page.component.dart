import 'package:flutter/material.dart';

class TransparentMaterialPage<T> extends Page<T> {
  final Widget child;

  const TransparentMaterialPage({required this.child, super.name, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.5),
      settings: this,
    );
  }
}
