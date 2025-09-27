import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shop/auth_gate.dart';
import 'package:shop/screens/homepage/cubit/homepage_cubit.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _textController;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن للصورة
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // إعداد الأنيميشن للنص
    _textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // تحديد اتجاه الحركة (من أسفل لأعلى)
    _imageSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.0), // يبدأ من أسفل
          end: Offset.zero, // ينتهي في المكان الطبيعي
        ).animate(
          CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
        );

    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.0), // يبدأ من أسفل
          end: Offset.zero, // ينتهي في المكان الطبيعي
        ).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
        );

    // بدء الأنيميشن
    _startAnimations();
  }

  void _startAnimations() async {
    // بدء أنيميشن الصورة أولاً
    _imageController.forward();

    // انتظار قليل ثم بدء أنيميشن النص
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // الانتقال للصفحة التالية بعد انتهاء الأنيميشن
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الصورة مع تأثير الحركة من أسفل لأعلى
            SlideTransition(
              position: _imageSlideAnimation,
              child: Container(
                width: 150.w,
                height: 150.h,
                child: Lottie.asset(
                  'assets/images/Shopping.json', // ضع مسار صورتك هنا
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            // النص مع تأثير الحركة من أسفل لأعلى
            SlideTransition(
              position: _textSlideAnimation,
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    ScaleAnimatedText(
                      'Carti',
                      textStyle: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
