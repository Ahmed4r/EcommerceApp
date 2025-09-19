// import 'dart:async';
// import 'dart:developer';
// import 'package:animated_snack_bar/animated_snack_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shop/app_colors.dart';
// import 'package:shop/screens/login/login.dart';

// class OtpScreen extends StatefulWidget {
//   static const routeName = '/otp-screen';

//   const OtpScreen({super.key});
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   int _seconds = 60;
//   bool _isRunning = false;
//   Timer? _timer;
//   late String email;

//   bool _isInit = true;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (_isInit) {
//       final args =
//           ModalRoute.of(context)!.settings.arguments as Map<String, String>;
//       email = args['email']!;
//       _setupAuthListener();
//       _sendMagicLink();
//       _startTimer();
//       _isInit = false;
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _startTimer() {
//     setState(() {
//       _isRunning = true;
//       _seconds = 60;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_seconds > 0) {
//         if (mounted) setState(() => _seconds--);
//       } else {
//         if (mounted) setState(() => _isRunning = false);
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> _sendMagicLink() async {
//     try {
//       await Supabase.instance.client.auth.signInWithOtp(
//         email: email,
//         emailRedirectTo: 'shop://auth/callback',
//       );
//       if (mounted) {
//         AnimatedSnackBar.rectangle(
//           'Magic Link Sent',
//           'Check your email and click the verification link',
//           type: AnimatedSnackBarType.success,
//           duration: const Duration(seconds: 3),
//         ).show(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         log(e.toString());
//         AnimatedSnackBar.rectangle(
//           'Error',
//           'Failed to send magic link: $e',
//           type: AnimatedSnackBarType.error,
//           duration: const Duration(seconds: 2),
//         ).show(context);
//       }
//     }
//   }

//   // Set up auth state listener to detect when user clicks magic link
//   void _setupAuthListener() {
//     Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//       if (data.event == AuthChangeEvent.signedIn && mounted) {
//         Navigator.pushReplacementNamed(context, LoginPage.routeName);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBar(
//         forceMaterialTransparency: true,
//         backgroundColor: AppColors.primary,
//         centerTitle: true,
//         title: RichText(
//           text: TextSpan(
//             text: 'Verification',
//             style: GoogleFonts.sen(
//               fontSize: 30.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back_ios),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             SizedBox(height: 10.h),
//             Text(
//               'We have sent a verification link to your email',
//               style: GoogleFonts.sen(fontSize: 16.sp, color: Colors.black),
//             ),
//             Text(
//               email,
//               style: GoogleFonts.sen(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('MAGIC LINK'),
//                 _isRunning
//                     ? Text(
//                         'Resend in $_seconds',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       )
//                     : InkWell(
//                         onTap: () {
//                           _sendMagicLink();
//                           _startTimer();
//                         },
//                         child: const Text(
//                           'Resend',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(20.w),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Column(
//                 children: [
//                   Icon(Icons.email_outlined, size: 48.r, color: Colors.blue),
//                   SizedBox(height: 12.h),
//                   Text(
//                     'Check Your Email',
//                     style: GoogleFonts.sen(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     'Click the verification link in your email to complete the sign-in process.',
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.sen(
//                       fontSize: 14.sp,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
