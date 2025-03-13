import 'package:flutter/material.dart';

class TicketDivider extends StatelessWidget {
  final double width;
  final double height;
  final double dashWidth;
  final double dashHeight;
  final Color color;
  final Color backgroundColor;

  const TicketDivider({
    super.key,
    this.width = double.infinity,
    this.height = 2,
    this.dashWidth = 6,
    this.dashHeight = 2,
    this.color = Colors.black,
    this.backgroundColor = Colors.white, // Match ticket background
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Right Half-Circle (Should be on the left now)
        ClipPath(
          clipper: HalfCircleClipper(isLeft: true), // Swapped
          child: Container(
            width: height * 2,
            height: height * 2,
            color: backgroundColor,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int dashCount = (constraints.maxWidth / (2 * dashWidth)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (index) {
                  return Container(
                    width: dashWidth,
                    height: dashHeight,
                    color: color,
                  );
                }),
              );
            },
          ),
        ),
        // Left Half-Circle (Should be on the right now)
        ClipPath(
          clipper: HalfCircleClipper(isLeft: false), // Swapped
          child: Container(
            width: height * 2,
            height: height * 2,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }
}

// Half-circle cutout clipper
class HalfCircleClipper extends CustomClipper<Path> {
  final bool isLeft;

  HalfCircleClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (!isLeft) {
      // Right half-circle now on left
      path.moveTo(size.width, 0);
      path.arcToPoint(Offset(size.width, size.height),
          radius: Radius.circular(size.width / 2), clockwise: false);
    } else {
      // Left half-circle now on right
      path.arcToPoint(Offset(0, size.height),
          radius: Radius.circular(size.width / 2), clockwise: true);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
