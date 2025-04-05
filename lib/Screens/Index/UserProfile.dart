import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_booking/Auth/AuthWrapper.dart';
import 'package:ticket_booking/Screens/Index/Account/MyBookings.dart';
import 'package:ticket_booking/Screens/Index/Account/ProfileEdit.dart';
import 'package:ticket_booking/const/colors.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = '';
  String number = '';
  String profileUrl = '';
  String email = '';
  String gender = '';
  String dob = '';
  String maritalstatus = '';
  String anniversary = '';

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        name = userDoc.get('name') ?? '';
        number = userDoc.get('phone') ?? '';
        profileUrl = userDoc.get('profile_picture') ?? '';
        email = userDoc.get('email') ?? '';
        gender = userDoc.get('gender') ?? '';
        dob = userDoc.get('dob') ?? '';
        maritalstatus = userDoc.get('marital_status') ?? '';
        anniversary = userDoc.get('created_at') ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: blue,
        title: const Text("Logout",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: const Text("Are you sure you want to log out?",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white)),
        actionsPadding: const EdgeInsets.only(bottom: 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true); // Confirm logout
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AuthWrapper()), // Replace with your login screen
        (route) => false,
      );
    }
  }

  String formatDate(String date) {
    List<String> parts = date.split(' '); // Split by space
    return "${parts[0]} ${parts[2]}"; // Keep Month and Year
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Account",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          )),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileUrl), // Dummy image
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        Text(
                          "Since of ${formatDate(anniversary)}",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.black, size: 30),
                ],
              ),
            ),
          ),

          // Divider
          const Divider(
            color: Colors.grey,
            thickness: 2,
          ),
          // Menu Items
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: amber,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  buildMenuItem(Icons.receipt_long, "My Bookings", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Divider(
                      color: white.withOpacity(0.5),
                    ),
                  ),
                  buildMenuItem(Icons.local_offer, "Offers", () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyBookings()),
                    // );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Divider(
                      color: white.withOpacity(0.5),
                    ),
                  ),
                  buildMenuItem(Icons.card_giftcard, "Rewards", () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyBookings()),
                    // );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Divider(
                      color: white.withOpacity(0.5),
                    ),
                  ),
                  buildMenuItem(Icons.notifications, "Notifications", () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyBookings()),
                    // );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Divider(
                      color: white.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text("T&C Privacy",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ListTile(
                          title: const Text("Contact Us",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {},
                        ),
                        ListTile(
                          title: const Text("Log Out",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          onTap: () {
                            _logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, VoidCallback ontap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 30, color: Colors.black),
      onTap: ontap,
    );
  }
}
