import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticket_booking/Auth/VerifyPhone.dart';
import 'package:ticket_booking/Screens/BottomNavigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String district = ''; // Provide default values
  String name = '';
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          district = userDoc.get('district') ?? '';
          name = userDoc.get('name') ?? '';
          isLoading = false; // Data fetched, stop loading
        });
      }
    } else {
      setState(() {
        isLoading = false; // No user found, stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
          return Center(child: CircularProgressIndicator()); // Show loader
        } else if (snapshot.hasData) {
          return Bottomnavigation(
            districtname: district,
            uname: name,
          );
        } else {
          return PhoneVerificationScreen();
        }
      },
    );
  }
}
