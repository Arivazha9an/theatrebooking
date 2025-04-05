import 'package:flutter/material.dart';

class CustomZigZag extends StatelessWidget {
  final double width;
  final double height;
  final double zigzagHeight;
  final double zigzagWidth;
  final Color color;
  final Color backgroundColor;

  const CustomZigZag({
    super.key,
    this.width = double.infinity,
    this.height = 2,
    this.zigzagHeight = 6,
    this.zigzagWidth = 10,
    this.color = Colors.transparent,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Half-Circle (Cutout)
        ClipPath(
          clipper: HalfCircleClipper(isLeft: false),
          child: Container(
            width: height * 2,
            height: height * 2,
            color: backgroundColor,
          ),
        ),

        // Zigzag Divider (Overlapping for perfect fit)
        Expanded(
          child: SizedBox(
            height: zigzagHeight,
            child: CustomPaint(
              painter: ZigZagPainter(
                color: color,
                zigzagHeight: zigzagHeight,
                zigzagWidth: zigzagWidth,
              ),
            ),
          ),
        ),

        // Right Half-Circle (Cutout)
        ClipPath(
          clipper: HalfCircleClipper(isLeft: true),
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

// 🎨 Custom Painter for Zigzag Effect (Now Overlapping)
class ZigZagPainter extends CustomPainter {
  final Color color;
  final double zigzagHeight;
  final double zigzagWidth;

  ZigZagPainter({
    required this.color,
    this.zigzagHeight = 6,
    this.zigzagWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(-zigzagWidth, size.height); // Extend beyond left edge

    for (double x = -zigzagWidth;
        x < size.width + zigzagWidth;
        x += zigzagWidth) {
      path.relativeLineTo(zigzagWidth / 2, -zigzagHeight);
      path.relativeLineTo(zigzagWidth / 2, zigzagHeight);
    }

    path.lineTo(
        size.width + zigzagWidth, size.height); // Extend beyond right edge
    path.lineTo(-zigzagWidth, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 🟡 Half-circle cutout clipper for ticket edges
class HalfCircleClipper extends CustomClipper<Path> {
  final bool isLeft;

  HalfCircleClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = size.width / 2;

    if (isLeft) {
      // Left-side cutout
      path.moveTo(size.width, 0);
      path.arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.circular(radius),
        clockwise: false,
      );
    } else {
      // Right-side cutout
      path.arcToPoint(
        Offset(0, size.height),
        radius: Radius.circular(radius),
        clockwise: true,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
