import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_links.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../data/account_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  const BannerHeader(
                    title: 'Settings',
                    subtitle: 'App, support & legal',
                    emblem: _GearEmblem(),
                  ),
                  const SizedBox(height: 10),
                  _section('SPREAD THE WORD'),
                  _Tile(
                    icon: Icons.ios_share_rounded,
                    color: AppColors.primaryGreen,
                    title: 'Share App',
                    subtitle: 'Invite your friends',
                    onTap: () => SharePlus.instance
                        .share(ShareParams(text: AppLinks.shareMessage)),
                  ),
                  _Tile(
                    icon: Icons.star_rounded,
                    color: AppColors.gold,
                    title: 'Rate App',
                    subtitle: 'Leave a review on the Play Store',
                    onTap: () => _open(context, AppLinks.playStoreUrl),
                  ),
                  const SizedBox(height: 18),
                  _section('SUPPORT'),
                  _Tile(
                    icon: Icons.mail_rounded,
                    color: AppColors.info,
                    title: 'Contact / Feedback',
                    subtitle: AppLinks.supportEmail,
                    onTap: () => _email(context),
                  ),
                  const SizedBox(height: 18),
                  _section('LEGAL'),
                  _Tile(
                    icon: Icons.lock_rounded,
                    color: AppColors.rarityRare,
                    title: 'Privacy Policy',
                    onTap: () => _open(context, AppLinks.privacyUrl),
                  ),
                  _Tile(
                    icon: Icons.description_rounded,
                    color: AppColors.rarityEpic,
                    title: 'Terms & Conditions',
                    onTap: () => _open(context, AppLinks.termsUrl),
                  ),
                  const SizedBox(height: 18),
                  _section('ACCOUNT'),
                  _Tile(
                    icon: Icons.delete_forever_rounded,
                    color: AppColors.danger,
                    title: 'Delete Account',
                    subtitle: 'Permanently erase your data',
                    danger: true,
                    onTap: () => _confirmDelete(context, ref),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '${AppLinks.appName} · v${AppLinks.appVersion}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2)),
      );

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _toast(context, 'Could not open link');
    }
  }

  Future<void> _email(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppLinks.supportEmail,
      query: 'subject=${Uri.encodeComponent('${AppLinks.appName} feedback')}'
          '&body=${Uri.encodeComponent('\n\n— App v${AppLinks.appVersion}')}',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      _toast(context, 'No email app found');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete account?',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        content: const Text(
          'This permanently erases your profile, progress, cards, predictions '
          'and leaderboard entries. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    // Progress indicator while we wipe.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen)),
    );
    await deleteAccountAndData(ref);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close spinner
    context.go('/onboarding');
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: danger
                  ? AppColors.danger.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: danger
                    ? AppColors.danger.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: danger
                                  ? AppColors.danger
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                if (!danger)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GearEmblem extends StatelessWidget {
  const _GearEmblem();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        gradient: AppColors.greenCta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 44),
    );
  }
}
