import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded surface card used everywhere on the Home screen.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.color,
    this.borderRadius = 24,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? (color ?? AppColors.surface) : null,
      borderRadius: radius,
      border:
          borderColor == null ? null : Border.all(color: borderColor!, width: 1),
    );

    Widget content = Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: content,
        ),
      );
    }
    return content;
  }
}
