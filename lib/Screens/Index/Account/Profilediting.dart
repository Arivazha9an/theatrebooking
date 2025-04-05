import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ticket_booking/Screens/BottomNavigation.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userProfile;

  const EditProfileScreen(
      {super.key, required this.userId, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController genderController;
  late TextEditingController dobController;
  late TextEditingController maritalStatusController;
  File? profilePic;
  String? profilePicUrl; // Store the uploaded image URL

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userProfile["name"]);
    phoneController = TextEditingController(text: widget.userProfile["phone"]);
    emailController = TextEditingController(text: widget.userProfile["email"]);
    genderController =
        TextEditingController(text: widget.userProfile["gender"]);
    dobController = TextEditingController(text: widget.userProfile["dob"]);
    maritalStatusController =
        TextEditingController(text: widget.userProfile["marital_status"]);
    profilePicUrl = widget.userProfile["profile_picture"];
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    genderController.dispose();
    dobController.dispose();
    maritalStatusController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      if (profilePic != null) {
        // Upload the new profile picture and get the URL
        profilePicUrl = await _uploadImage(profilePic!);
      }

      final updatedProfile = {
        "name": nameController.text,
        "phone": phoneController.text,
        "email": emailController.text,
        "gender": genderController.text,
        "dob": dobController.text,
        "marital_status": maritalStatusController.text,
        "created_at": widget.userProfile["created_at"], // Keep unchanged
        "profile_picture": profilePicUrl, // Updated profile picture URL
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update(updatedProfile);

      // Return the updated data to the previous screen
       Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Bottomnavigation(districtname: widget.userProfile["district"], uname: widget.userProfile["name"],)),
        (route) => false, // Removes all previous screens
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error updating profile: $e");
      }
    }
  }

 Future<String> _uploadImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = "profile.jpg";
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("profile_pictures/$userId/$fileName");

      // Delete old profile picture if it exists
      if (profilePicUrl != null && profilePicUrl!.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(profilePicUrl!).delete();
          if (kDebugMode) {
            print("Old profile picture deleted successfully.");
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error deleting old profile picture: $e");
          }
        }
      }

      // Upload new image
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // Get new image URL
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      return widget.userProfile["profile_picture"] ??
          ""; // Return existing URL if upload fails
    }
  }


  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profilePic = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: profilePic != null
                    ? FileImage(profilePic!) // Show picked image
                    : (profilePicUrl != null && profilePicUrl!.isNotEmpty
                            ? NetworkImage(
                                profilePicUrl!) // Show existing profile image
                            : const AssetImage("assets/images/profile.png"))
                        as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("Name", nameController),
            _buildTextField("Phone", phoneController),
            _buildTextField("Email", emailController),
            _buildTextField("Gender", genderController),
            _buildTextField("Date of Birth", dobController),
            _buildTextField("Marital Status", maritalStatusController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
