import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ticket_booking/Widgets/GradientButton.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber; // Added to resend OTP

  const OtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isVerifying = false;
  String? verificationId;
  int _resendTimeout = 30; // Resend timer
  Timer? _timer;
  bool canResendOtp = false;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    _startResendTimer();
  }

  /// 🎯 Start Resend Timer (30 seconds)
  void _startResendTimer() {
    setState(() {
      _resendTimeout = 30;
      canResendOtp = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout == 0) {
        setState(() => canResendOtp = true);
        timer.cancel();
      } else {
        setState(() => _resendTimeout--);
      }
    });
  }

  /// 📌 Function to verify OTP
  Future<void> verifyOtp() async {
    setState(() => isVerifying = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      // ✅ If successful, show success bottom sheet
      _showOtpVerifiedBottomSheet();
    } catch (e) {
      setState(() => isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP, please try again!")),
      );
    }
  }

  /// 🔄 Resend OTP Function
  Future<void> resendOtp() async {
    if (!canResendOtp) return;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          print("Auto sign-in successful");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.message}")),
          );
        },
        codeSent: (String newVerificationId, int? resendToken) {
          setState(() {
            verificationId = newVerificationId;
          });
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP Resent Successfully")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print("Resend OTP error: $e");
    }
  }

  /// 🎉 Bottom Sheet for Success
  void _showOtpVerifiedBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(
              context, '/HomeScreen'); // Change to your home screen
        });

        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 10),
              const Text("OTP Verified",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/envelope.png', // Replace with your asset image
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Enter OTP Code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("We've sent a code to ${widget.phoneNumber}"),
            const SizedBox(height: 20),
            PinCodeTextField(
              length: 6,
              appContext: context,
              controller: otpController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),

            /// 📌 Resend OTP Button
            GestureDetector(
              onTap: canResendOtp ? resendOtp : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    canResendOtp
                        ? "Resend OTP"
                        : "Resend OTP in $_resendTimeout sec",
                    style: TextStyle(
                      color: canResendOtp ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_right,
                      color: canResendOtp ? Colors.blue : Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 📌 Continue Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: GradientButton(
                    onPressed: () {
                      isVerifying
                          ? null
                          : () {
                              verifyOtp(); // Calling the async function correctly
                            };
                    },
                    text: isVerifying ? "Verifying..." : "Continue",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
