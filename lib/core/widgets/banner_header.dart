import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_back_button.dart';

/// A full-bleed screen header: title + subtitle floating on the background
/// with an illustration on the right — matching the Home hero treatment.
class BannerHeader extends StatelessWidget {
  const BannerHeader({
    super.key,
    required this.title,
    required this.emblem,
    this.subtitle,
    this.showBack = true,
    this.backdrop,
    this.height = 120,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget emblem;
  final bool showBack;

  /// Optional decorative layer drawn behind the content (e.g. confetti).
  final Widget? backdrop;
  final double height;

  /// Optional top-right action (e.g. a help "?" button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack || action != null) ...[
          Row(
            children: [
              if (showBack) const GlassBackButton(),
              const Spacer(),
              ?action,
            ],
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (backdrop != null)
                Positioned.fill(child: IgnorePointer(child: backdrop!)),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              height: 1.05,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    emblem,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
