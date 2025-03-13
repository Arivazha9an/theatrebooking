import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/ComingSoon.dart';
import 'package:ticket_booking/Screens/HomeScreen.dart';
import 'package:ticket_booking/Screens/TheatreScreen.dart';
import 'package:ticket_booking/const/colors.dart';
import 'UserProfile.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Bottomnavigation> {
  final _pageController = PageController(initialPage: 0);

  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  int maxCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      HomeScreen(controller: _controller),
      TheaterScreen(
        userName: '',
        location: '',
      ),
      ComingSoonScreen(),
      AccountScreen(),
    ];
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              notchBottomBarController: _controller,
              color: blue,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: 1,
              kBottomRadius: 6.0,

              // notchShader: const SweepGradient(
              //   startAngle: 0,
              //   endAngle: pi / 2,
              //   colors: [Colors.red, Colors.green, Colors.orange],
              //   tileMode: TileMode.mirror,
              // ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),
              notchColor: blue,

              /// restart app if you change removeMargins
              removeMargins: true,
              bottomBarWidth: 450,
              showShadow: true,
              durationInMilliSeconds: 200,
              itemLabelStyle: const TextStyle(fontSize: 5, color: white),
              elevation: 0,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.home_rounded,
                    color: amber,
                    size: 26,
                  ),
                  activeItem: Icon(
                    Icons.home_rounded,
                    color: amber,
                    size: 26,
                  ),
                ),
                BottomBarItem(
                  inActiveItem:
                      Icon(CupertinoIcons.videocam_fill, color: amber),
                  activeItem: Icon(
                    CupertinoIcons.videocam_fill,
                    color: amber,
                  ),
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.calendar_month,
                    color: amber,
                  ),
                  activeItem: Icon(
                    Icons.calendar_month,
                    color: amber,
                  ),
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    CupertinoIcons.person_fill,
                    color: amber,
                  ),
                  activeItem: Icon(
                    CupertinoIcons.person_fill,
                    color: amber,
                  ),
                ),
              ],
              onTap: (index) {
                log('current selected index $index');
                _pageController.jumpToPage(index);
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
