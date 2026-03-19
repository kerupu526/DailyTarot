import 'package:flutter/cupertino.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
    : super(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0), // 살짝 오른쪽에서
                end: Offset.zero, // 제자리로
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
              child: child,
            ),
          );
        },
      );
}
