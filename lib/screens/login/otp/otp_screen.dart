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
  @override
  void _startTimer() {
    _isRunning = true;
    _seconds = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        if (mounted) {
          setState(() {
            _seconds--;
          });
        }
      } else {
        _isRunning = false;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    otpController.dispose();
  }

  void _verifyOtp() {
    if (otpController.text.isNotEmpty &&
        otpController.text.length == 4 &&
        otpController.text == '1234') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } else {
      if (!mounted) return;
      setState(() {});

      AnimatedSnackBar.rectangle(
        duration: Duration(milliseconds: 1500),
        'Incorrect OTP',
        'Please enter a correct OTP',
        type: AnimatedSnackBarType.error,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final email = args['email'];
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: 'verification',
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
            RichText(
              text: TextSpan(
                text: 'we have sent a code to your email',
                style: GoogleFonts.sen(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: email,
                style: GoogleFonts.sen(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CODE'),
                _isRunning
                    ? Text(
                        'Resend in ${_seconds.toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : InkWell(
                        onTap: () => _startTimer(),
                        child: Text(
                          'Resend',
                          style: const TextStyle(
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
    validator: (s) {},
    hapticFeedbackType: HapticFeedbackType.lightImpact,
    controller: controller,
    errorTextStyle: const TextStyle(color: Colors.red),
    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
    showCursor: true,

    onCompleted: (pin) => log(pin.toString()),
  );
}
