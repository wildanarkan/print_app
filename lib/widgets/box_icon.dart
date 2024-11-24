import 'package:flutter/material.dart';

class BoxIcon extends StatelessWidget {
  final Color? backgroundColor;
  final IconData icon;
  final String title;
  final GestureTapCallback onTap;
  final double height;
  final double iconSize;
  final double titleSize;

  const BoxIcon({
    super.key,
    required this.icon,
    this.backgroundColor = Colors.indigo,
    required this.title,
    required this.onTap,
    this.height = 150,
    this.iconSize = 50,
    this.titleSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: Colors.black38, width: 1),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
