import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/Profilediting.dart';
import 'package:ticket_booking/const/colors.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userProfile = {
    "name": "Arun",
    "phone": "8543224078",
    "email": "arun20j@gmail.com",
    "gender": "Male",
    "dob": "20/08/1994",
    "maritalStatus": "Unmarried",
    "anniversary": "",
    "profilePic": null, // Default is null (will show placeholder)
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              final updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfileScreen(userProfile: userProfile),
                ),
              );

              if (updatedProfile != null) {
                setState(() {
                  userProfile = updatedProfile;
                });
              }
            },
          ),
        ],
      ),
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile["name"]!,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        userProfile["phone"]!,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: userProfile["profilePic"] != null
                        ? FileImage(
                            userProfile["profilePic"]) // Show selected image
                        : const NetworkImage("https://i.pravatar.cc/300")
                            as ImageProvider,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildProfileField("Email", userProfile["email"]!),
            _divider(),
            _buildProfileField("Gender", userProfile["gender"]!),
            _divider(),
            _buildProfileField("Date of Birth", userProfile["dob"]!),
            _divider(),
            _buildProfileField("Marital Status", userProfile["maritalStatus"]!),
            _divider(),
            _buildProfileField(
                "Anniversary", userProfile["anniversary"]!), // Not editable
            _divider(),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(height: 5, color: Colors.amber.withOpacity(0.5));

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                value.isNotEmpty ? value : "-",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
