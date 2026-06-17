import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma = 12.0,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = borderRadius ?? BorderRadius.circular(12.0);
    
    // Theme-aware default background and border colors
    final fallbackBg = backgroundColor ?? 
        (isDark 
            ? theme.colorScheme.surface.withOpacity(0.6) 
            : theme.colorScheme.surface.withOpacity(0.85));
            
    final fallbackBorder = borderColor ?? 
        (isDark 
            ? theme.colorScheme.primary.withOpacity(0.1) 
            : theme.colorScheme.outline.withOpacity(0.4));

    // Dynamic light/dark shadow weight matching the high-fidelity mockups
    final shadowColor = isDark 
        ? Colors.black.withOpacity(0.15) 
        : Colors.black.withOpacity(0.04);
        
    final shadowBlur = isDark ? 20.0 : 12.0;
    final shadowOffset = isDark ? const Offset(0, 10) : const Offset(0, 4);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fallbackBg,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: fallbackBorder,
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
