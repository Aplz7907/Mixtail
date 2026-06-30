import 'package:flutter/material.dart';

class PixelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const PixelButton({super.key, required this.text, required this.onPressed, this.color = Colors.orange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            // สร้างเงาแบบ Pixel (Hard shadow)
            BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
