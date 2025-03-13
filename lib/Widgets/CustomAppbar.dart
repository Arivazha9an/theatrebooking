import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final double height;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final BoxShadow boxShadow;

  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.height = 50,
    this.backgroundColor = Colors.amber,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.boxShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: [boxShadow],
        ),
        child: Row(
          children: [
            if (leading != null) leading!,
            Expanded(
              child: Center(child: title ?? const SizedBox.shrink()),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
