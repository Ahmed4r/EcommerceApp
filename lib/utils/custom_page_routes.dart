import 'package:flutter/material.dart';
import 'package:shop/screens/homepage/details.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  SmoothPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    required ProductDetailsPage Function(dynamic context) builder,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Slide transition from right
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;

           var slideTween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));

           // Fade transition
           var fadeTween = Tween<double>(
             begin: 0.0,
             end: 1.0,
           ).chain(CurveTween(curve: curve));

           // Scale transition for a subtle zoom effect
           var scaleTween = Tween<double>(
             begin: 0.95,
             end: 1.0,
           ).chain(CurveTween(curve: curve));

           return FadeTransition(
             opacity: animation.drive(fadeTween),
             child: SlideTransition(
               position: animation.drive(slideTween),
               child: ScaleTransition(
                 scale: animation.drive(scaleTween),
                 child: child,
               ),
             ),
           );
         },
       );
}

// Custom page route for hero animations with enhanced transitions
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  HeroPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Create a custom transition that works well with Hero animations
           var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
             ),
           );

           var slideAnimation =
               Tween<Offset>(
                 begin: const Offset(0.0, 0.1),
                 end: Offset.zero,
               ).animate(
                 CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
               );

           return FadeTransition(
             opacity: fadeAnimation,
             child: SlideTransition(position: slideAnimation, child: child),
           );
         },
       );
}
