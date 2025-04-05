import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:ticket_booking/Screens/BottomNavigation.dart';
import 'package:ticket_booking/Screens/SelectCity.dart';
import 'package:ticket_booking/Widgets/GradientButton.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  @override
  // ignore: library_private_types_in_public_api
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isVerifying = false;
  String? verificationId;
  int _resendTimeout = 30;
  Timer? _timer;
  bool canResendOtp = false;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    _startResendTimer();
  }

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

  Future<void> verifyOtp() async {
    setState(() => isVerifying = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // User exists → Navigate to BottomNavigation
          String district = userDoc.get('district');
          String name = userDoc.get('name');
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Bottomnavigation(
                  districtname: district,
                  uname: name,
                ),
              ));
        } else {
          // New user → Navigate to RegisterScreen
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SelectCity(phone: widget.phoneNumber),
              ));
        }
      }
    } catch (e) {
      setState(() => isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP, please try again!")),
      );
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp) return;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
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
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Resend OTP error: $e");
      }
    }
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
            Center(child: Image.asset('assets/others/otp.png', height: 100)),
            const SizedBox(height: 20),
            const Text("Enter OTP Code",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            Center(
              child: GradientButton(
                onPressed: isVerifying
                    ? () {}
                    : () {
                        verifyOtp();
                      },
                text: isVerifying ? "Verifying..." : "Continue",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
