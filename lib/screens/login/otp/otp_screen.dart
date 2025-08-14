import 'dart:async';
import 'dart:developer';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/widgets/glass_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp-screen';

  const OtpScreen({super.key});
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int _seconds = 60;
  bool _isRunning = false;
  Timer? _timer;
  TextEditingController otpController = TextEditingController();
  late String email;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      email = args['email']!;
      _sendOtp();
      _startTimer();
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _seconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        if (mounted) setState(() => _seconds--);
      } else {
        if (mounted) setState(() => _isRunning = false);
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    try {
      final res = await Supabase.instance.client.auth.signInWithOtp(
        email: email,
      );
      if (mounted) {
        AnimatedSnackBar.rectangle(
          'OTP Sent',
          'Check your email for the OTP link',
          type: AnimatedSnackBarType.success,
          duration: const Duration(seconds: 2),
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        log(e.toString());
        AnimatedSnackBar.rectangle(
          'Error',
          'Failed to send OTP: $e',
          type: AnimatedSnackBarType.error,
          duration: const Duration(seconds: 2),
        ).show(context);
      }
    }
  }

  Future<void> _verifyOtp() async {
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otpController.text,
        type: OtpType.sms,
      );

      if (res.user != null && mounted) {
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackBar.rectangle(
          'Incorrect OTP',
          'Please enter the correct OTP',
          type: AnimatedSnackBarType.error,
          duration: const Duration(seconds: 2),
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: 'Verification',
            style: GoogleFonts.sen(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Text(
              'We have sent a code to your email',
              style: GoogleFonts.sen(fontSize: 16.sp, color: Colors.black),
            ),
            Text(
              email,
              style: GoogleFonts.sen(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CODE'),
                _isRunning
                    ? Text(
                        'Resend in $_seconds',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          _sendOtp();
                          _startTimer();
                        },
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 20),
            buildPinPut(context, otpController),
            const SizedBox(height: 20),
            GlassButton(title: "Verify", onPressed: _verifyOtp),
          ],
        ),
      ),
    );
  }
}

// Pinput Themes
final defaultPinTheme = PinTheme(
  width: 300.w,
  height: 56.h,
  textStyle: const TextStyle(
    fontSize: 20,
    color: Color.fromRGBO(30, 60, 87, 1),
    fontWeight: FontWeight.w600,
  ),
  decoration: BoxDecoration(
    border: Border.all(color: const Color.fromARGB(255, 154, 160, 166)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: const Color(0xffF0F5FA)),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration!.copyWith(
    color: const Color.fromRGBO(196, 204, 210, 1),
  ),
);

Widget buildPinPut(context, controller) {
  return Pinput(
    autofocus: true,
    defaultPinTheme: defaultPinTheme,
    focusedPinTheme: focusedPinTheme,
    submittedPinTheme: submittedPinTheme,
    validator: (s) {
      return null;
    },
    hapticFeedbackType: HapticFeedbackType.lightImpact,
    controller: controller,
    errorTextStyle: const TextStyle(color: Colors.red),
    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
    showCursor: true,
    onCompleted: (pin) => log(pin.toString()),
  );
}
