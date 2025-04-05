import 'package:flutter/material.dart';
import 'package:ticket_booking/Auth/VerifyPhone.dart';
import 'package:ticket_booking/Screens/BottomNavigation.dart';
import 'package:ticket_booking/Widgets/GradientButton.dart';
import 'package:ticket_booking/const/colors.dart';

class IntroScreen extends StatefulWidget {
  final String districtname;
  final String uname;
  const IntroScreen({super.key, required this.districtname, required this.uname});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int currentIndex = 0;

  final List<String> texts = [
    "Choose among a wide range Of Cinema Theater",
    "Enjoy seamless ticket booking experience",
    "Get ready for your next movie adventure!"
  ];

  void nextPage() {
    if (currentIndex < 2) {
      setState(() {
        currentIndex++;
      });
    } else {
     Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Bottomnavigation(
              districtname: widget.districtname,
              uname: widget.uname,
            ),
          ));
    }
  }

  void previousPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Image.asset("assets/logo.png", height: 150),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            color: amber,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    texts[currentIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  text: "Get Started",
                  onPressed: nextPage,
                ),
                const SizedBox(height: 20),

                // Buttons Row
                Row(
                  children: [
                    if (currentIndex > 0)
                      TextButton(
                        onPressed: previousPage,
                        child: const Text("Back",
                            style: TextStyle(color:  black)),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: nextPage,
                      child: const Text("Next",
                          style: TextStyle(color:  black)),
                    ),
                  ],
                ),

                // Mini Progress Bar
                const SizedBox(height: 20),
                SizedBox(
                  width: 80, // Fixed width for mini progress bar
                  height: 5,
                  child: Stack(
                    children: [
                      // Background Bar
                      Container(
                        width: 100,
                        height: 5,
                        decoration: BoxDecoration(
                          color:  white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      // Moving Indicator
                      AnimatedAlign(
                        alignment: currentIndex == 0
                            ? Alignment.centerLeft
                            : currentIndex == 1
                                ? Alignment.center
                                : Alignment.centerRight,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 33,  
                          height: 5,
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


