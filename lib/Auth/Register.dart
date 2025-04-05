import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ticket_booking/Intro/IntroScreen.dart';
import 'package:ticket_booking/Screens/BottomNavigation.dart';
import 'package:ticket_booking/Widgets/GradientButton.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;
  final String selectedDistrict;

  const RegisterScreen({super.key, required this.phoneNumber, required this.selectedDistrict});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedGender;
  String? selectedDob;
  String? selectedMaritalStatus;
  String anniversaryDate =
      DateTime.now().toString().split(' ')[0]; // Store current date

  File? _imageFile;
  String? _profileImageUrl;
  bool isLoading = false;

  final List<String> genderOptions = ["Male", "Female", "Other"];
  final List<String> maritalStatusOptions = [
    "Single",
    "Married",
    "Divorced",
    "Widowed"
  ];

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

 Future<String> uploadProfilePicture(File image) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName =
          "profile.jpg"; // Fixed name or use `DateTime.now().toString()`

      Reference ref = FirebaseStorage.instance
          .ref()
          .child("profile_pictures/$userId/$fileName");

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading: $e");
      }
      throw Exception("Image upload failed: $e");
    }
  }


 Future<void> registerUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        selectedGender == null ||
        selectedDob == null ||
        selectedMaritalStatus == null ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Please fill all fields and select a profile picture")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        var now = DateTime.now();
        var date = DateFormat('MMMM d, y').format(now);
        if (kDebugMode) {
          print("Uploading image...");
        }
        _profileImageUrl = await uploadProfilePicture(_imageFile!);
        if (kDebugMode) {
          print("Image uploaded successfully: $_profileImageUrl");
        }

        if (kDebugMode) {
          print("Saving user data to Firestore...");
        }
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'phone': widget.phoneNumber,
          'email': emailController.text.trim(),
          'gender': selectedGender,
          'dob': selectedDob!,
          'marital_status': selectedMaritalStatus,
          'anniversary': anniversaryDate,
          'profile_picture': _profileImageUrl,
          'created_at': date,
          'district': widget.selectedDistrict,
        });
        print("User registered successfully!");

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>   IntroScreen(districtname: widget.selectedDistrict ,uname: nameController.text.trim() ,),
            ));
      } else {
        if (kDebugMode) {
          print("User is NULL. Something went wrong with Firebase Auth.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

Future<void> _pickDate(
      BuildContext context, Function(String) onDateSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      String formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      onDateSelected(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt,
                            size: 40, color: Colors.grey[700])
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genderOptions.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => selectedGender = value),
                decoration: InputDecoration(labelText: "Gender"),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickDate(
                    context, (date) => setState(() => selectedDob = date)),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: selectedDob == null
                          ? "Date of Birth"
                          : "DOB: ${selectedDob!}",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedMaritalStatus,
                items: maritalStatusOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedMaritalStatus = value),
                decoration: InputDecoration(labelText: "Marital Status"),
              ),
              SizedBox(height: 20),
              Text("Anniversary Date (Account Created): $anniversaryDate",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              Center(
                child: GradientButton(
                  onPressed: isLoading ? () {} : () => registerUser(),
                  text: isLoading ? "Registering..." : "Register",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
