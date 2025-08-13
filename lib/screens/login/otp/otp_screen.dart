import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/widgets/glass_button.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp-screen';

  const OtpScreen({super.key});
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  int _seconds = 60;
  bool _isRunning = false;
  bool is_clicked = false;
  Timer? _timer;

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
  }

  void _verifyOtp() {
    print(_otpController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CODE'),
                _isRunning
                    ? Text(
                        'Resend in ${_seconds.toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
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
            buildPinPut(context),
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

Widget buildPinPut(context) {
  return Pinput(
    autofocus: true,
    defaultPinTheme: defaultPinTheme,
    focusedPinTheme: focusedPinTheme,
    submittedPinTheme: submittedPinTheme,
    validator: (s) {
      if (s == '2222') {
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      }
      return null;
    },
    errorTextStyle: const TextStyle(color: Colors.red),
    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
    showCursor: true,
    onCompleted: (pin) => print(pin),
  );
}
