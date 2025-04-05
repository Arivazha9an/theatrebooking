import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ticket_booking/Auth/OtpScreen.dart';
import 'package:ticket_booking/const/colors.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String phoneNumber = '';

  void verifyPhoneNumber() async {
    phoneNumber = "+91${phoneController.text.trim()}";

    if (phoneController.text.length < 10 ||
        phoneController.text.isEmpty ||
        phoneController.text.length > 10) {
      CherryToast.error(
        title: const Text("Please enter a valid phone number"),
        autoDismiss: true,
        animationDuration: const Duration(milliseconds: 300),
        toastPosition: Position.bottom,
      ).show(context);
      return;
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          CherryToast.success(
            title: Text("✅ Auto sign-in successful"),
            autoDismiss: true,
            animationDuration: const Duration(milliseconds: 300),
            toastPosition: Position.bottom,
          ).show(context);
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print("🚨 Verification failed: ${e.message}");
          }
          CherryToast.error(
            title: Text("Error: ${e.message}"),
            autoDismiss: true,
            animationDuration: const Duration(milliseconds: 300),
            toastPosition: Position.bottom,
          ).show(context);
        },
        codeSent: (String verificationId, int? resendToken) {
          CherryToast.success(
            title: Text("📩 OTP Sent Successfully to $phoneNumber"),
            autoDismiss: true,
            animationDuration: const Duration(milliseconds: 300),
            toastPosition: Position.bottom,
          ).show(context);
          if (kDebugMode) {
            print("📩 OTP Sent. Verification ID: $verificationId");
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print("⏳ Code auto-retrieval timed out");
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: amber,
      body: Column(
        children: [
          const SizedBox(height: 100),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: white,
              child: Image.asset("assets/logo.png", height: 60),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verify Phone Number",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "To continue, enter your phone number",
                    style: TextStyle(fontSize: 16, color: grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone number",
                      prefixText: "+91 ",
                      suffixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        verifyPhoneNumber();
                        print("Phone number: ${phoneNumber}");
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [purple, deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18, color: white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
