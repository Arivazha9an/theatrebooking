import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _leftPosition;
  late Animation<double> _rightPosition;
  late Animation<double> _leftRotation;
  late Animation<double> _rightRotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double screenWidth = MediaQuery.of(context).size.width;

      _leftPosition = Tween<double>(begin: screenWidth / 2, end: -100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _rightPosition = Tween<double>(begin: screenWidth / 2, end: screenWidth + 100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _leftRotation = Tween<double>(begin: 0, end: -0.05).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _rightRotation = Tween<double>(begin: 0, end: - 0.05).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.forward();

      // Navigate to home screen after animation
      // Timer(const Duration(seconds: 2), () {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const HomeScreen()),
      //   );
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    // BLUE (LEFT) TICKET PART
                    Positioned(
                      left: _leftPosition.value - MediaQuery.of(context).size.width / 2,
                      child: Transform.rotate(
                        angle: _leftRotation.value,
                        child: ClipPath(
                          clipper: ZigZagClipper(),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 + 30, // Overlapping to align
                            height: MediaQuery.of(context).size.height,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ),
                    // WHITE (RIGHT) TICKET PART
                    Positioned(
                      left: _rightPosition.value - MediaQuery.of(context).size.width / 2,
                      child: Transform.rotate(
                        angle: _rightRotation.value,
                        child: ClipPath(
                          clipper: ZigZagClipper(reverse: true),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 + 30, // Overlapping to align
                            height: MediaQuery.of(context).size.height,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



// Zigzag Clipper for Ticket Edge
class ZigZagClipper extends CustomClipper<Path> {
  final bool reverse;

  ZigZagClipper({this.reverse = false});

  @override
  Path getClip(Size size) {
    Path path = Path();
    double step = 20;
    double halfStep = step / 2;
    double startX = reverse ? size.width - 30 : 0; // Shift zigzag to center
    double endX = reverse ? 0 : size.width - 30;  // Ensure proper overlap

    path.moveTo(startX, 0);
    for (double i = 0; i < size.height; i += step) {
      path.lineTo(startX + (reverse ? -halfStep : halfStep), i + halfStep);
      path.lineTo(startX, i + step);
    }
    path.lineTo(endX, size.height);
    path.lineTo(endX, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
