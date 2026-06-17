import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BitByteLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const BitByteLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/bb-logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF0F121C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.2)),
              ),
              child: const Center(
                child: Icon(Icons.broken_image_outlined, color: Color(0xFF00D2FF), size: 30),
              ),
            );
          },
        ),
        if (showText) ...[
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
