import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/ProfileEdit.dart';
import 'package:ticket_booking/const/colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage("https://i.pravatar.cc/300"), // Dummy image
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Arun",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        Text(
                          "Since of Jun 2023",
                          style: TextStyle(
                              fontSize: 12, color: Colors.black.withOpacity(0.7)), 
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
          SizedBox(height: 30),
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
                padding: const EdgeInsets.all(20),
                children: [
                  buildMenuItem(Icons.receipt_long, "My Bookings", () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyBookings()),
                    // );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
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
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
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
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
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
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Divider(
                      color: white.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        SizedBox(
                          height: 15,
                        ),
                        ListTile(
                          title: const Text("Log Out",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          onTap: () {},
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 35, color: Colors.black),
      onTap: ontap,
    );
  }
}
