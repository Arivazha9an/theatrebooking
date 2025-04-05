import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticket_booking/Screens/Index/Account/Profilediting.dart';
import 'package:ticket_booking/const/colors.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userProfile = {};

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserProfile(); // Ensures latest data loads when screen is revisited
  }

  Future<void> _fetchUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userProfile = userDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user profile: $e");
      }
    }
  }

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
                  builder: (context) => EditProfileScreen(
                    userId: widget.userId,
                    userProfile: userProfile,
                  ),
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
      body: userProfile.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                              userProfile["name"] ?? "-",
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              userProfile["phone"] ?? "-",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: userProfile["profile_picture"] !=
                                  null
                              ? NetworkImage(userProfile["profile_picture"])
                              : const AssetImage("assets/images/profile.png")
                                  as ImageProvider,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileField("Email", userProfile["email"] ?? "-"),
                  _divider(),
                  _buildProfileField("Gender", userProfile["gender"] ?? "-"),
                  _divider(),
                  _buildProfileField(
                      "Date of Birth", userProfile["dob"] ?? "-"),
                  _divider(),
                  _buildProfileField(
                      "Marital Status", userProfile["marital_status"] ?? "-"),
                  _divider(),
                  _buildProfileField(
                      "Anniversary", userProfile["anniversary"] ?? "-"),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
