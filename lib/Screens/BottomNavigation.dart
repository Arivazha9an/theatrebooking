import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/Index/ComingSoon.dart';
import 'package:ticket_booking/Screens/Index/HomeScreen.dart';
import 'package:ticket_booking/Screens/Index/TheatreScreen.dart';
import 'package:ticket_booking/const/colors.dart';
import 'Index/UserProfile.dart';

class Bottomnavigation extends StatefulWidget {
  final String districtname;
  final String uname;

  const Bottomnavigation(
      {super.key, required this.districtname, required this.uname});

  @override
  State<Bottomnavigation> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Bottomnavigation> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);
  int _currentIndex = 0; // Store selected index
  final int maxCount = 5;

  // Store pages to keep them in memory
  late List<Widget> bottomBarPages;

  @override
  void initState() {
    super.initState();
    bottomBarPages = [
      HomeScreen(
        controller: NotchBottomBarController(index: 0),
        userName: widget.uname,
        location: widget.districtname,
      ),
      TheaterScreen(userName: widget.uname, location: widget.districtname),
      ComingSoonScreen(),
      AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Keeps the last visited screen
        children: bottomBarPages,
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              notchBottomBarController: _controller,
              color: blue,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              shadowElevation: 1,
              kBottomRadius: 6.0,
              notchColor: blue,
              removeMargins: true,
              bottomBarWidth: 450,
              showShadow: true,
              durationInMilliSeconds: 200,
              itemLabelStyle: const TextStyle(fontSize: 5, color: white),
              elevation: 0,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem:
                      Icon(Icons.home_rounded, color: amber, size: 26),
                  activeItem: Icon(Icons.home_rounded, color: amber, size: 26),
                ),
                BottomBarItem(
                  inActiveItem:
                      Icon(CupertinoIcons.videocam_fill, color: amber),
                  activeItem: Icon(CupertinoIcons.videocam_fill, color: amber),
                ),
                BottomBarItem(
                  inActiveItem: Icon(Icons.calendar_month, color: amber),
                  activeItem: Icon(Icons.calendar_month, color: amber),
                ),
                BottomBarItem(
                  inActiveItem: Icon(CupertinoIcons.person_fill, color: amber),
                  activeItem: Icon(CupertinoIcons.person_fill, color: amber),
                ),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index; // Switch without reloading
                });
              },
              kIconSize: 24.0,
            )
          : null,
    );
  }
}

/// add controller to check weather index through change or not. in page 1
class Page1 extends StatelessWidget {
  final NotchBottomBarController? controller;

  const Page1({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        /// adding GestureDetector
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            controller?.jumpTo(2);
          },
          child: const Text('HelpScreen'),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green, child: const Center(child: Text('Page 2')));
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.red, child: const Center(child: Text('Page 3')));
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue, child: const Center(child: Text('Page 4')));
  }
}

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightGreenAccent,
        child: const Center(child: Text('Page 5')));
  }
}
