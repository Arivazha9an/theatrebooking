import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

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
        TextEditingController(text: widget.userProfile["maritalStatus"]);
    profilePic = widget.userProfile["profilePic"];
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

  void _saveChanges() {
    Navigator.pop(context, {
      "name": nameController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "gender": genderController.text,
      "dob": dobController.text,
      "maritalStatus": maritalStatusController.text,
      "anniversary": widget.userProfile["anniversary"], // Keep unchanged
      "profilePic": profilePic, // New profile picture
    });
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
                    ? FileImage(profilePic!) // Selected image
                    : const NetworkImage("https://i.pravatar.cc/300")
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
