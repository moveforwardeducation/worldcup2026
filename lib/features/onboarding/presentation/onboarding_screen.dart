import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/avatar_chip.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/team.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/providers.dart';
import '../../collection/presentation/widgets/card_fan_emblem.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../../home/presentation/widgets/trophy.dart';
import '../../journey/presentation/widgets/journey_mascot.dart';
import 'onboarding_providers.dart';

const int kMaxFavTeams = 5;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final Set<String> _selected = {};
  final _nameController = TextEditingController();
  String? _primary;
  int _avatarSeed = 7;

  static const _avatarOptions = [7, 1, 13, 21, 34, 42, 55, 68];

  // Briefing pages (the last "page" index is the setup page).
  static const _briefCount = 4;
  int get _lastPage => _briefCount; // setup page index

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _lastPage) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _skip() {
    _controller.animateToPage(_lastPage,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    if (_selected.isEmpty) return;
    final primary = _primary ?? _selected.first;
    final name = _nameController.text.trim();
    final username = name.isEmpty ? 'Football Fan' : name;
    final existing = ref.read(userProfileProvider);
    // Create a fresh profile (new users), or update an existing one.
    final profile = (existing ??
            UserProfile(
              username: username,
              avatarSeed: _avatarSeed,
              favoriteTeamId: primary,
              createdAtMs: DateTime.now().millisecondsSinceEpoch,
              followedTeamIds: _selected.toList(),
            ))
        .copyWith(
      username: username,
      favoriteTeamId: primary,
      followedTeamIds: _selected.toList(),
      avatarSeed: _avatarSeed,
    );
    await ref.read(userProfileProvider.notifier).save(profile);
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (mounted) context.go('/home');
  }

  void _toggleTeam(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_primary == id) _primary = _selected.isEmpty ? null : _selected.first;
      } else {
        if (_selected.length >= kMaxFavTeams) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can follow up to 5 teams')),
          );
          return;
        }
        _selected.add(id);
        _primary ??= id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSetup = _page == _lastPage;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            if (_page == 0)
              const Positioned.fill(child: IgnorePointer(child: Confetti())),
            SafeArea(
              child: Column(
                children: [
                  // Skip (hidden on setup page).
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      opacity: onSetup ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: onSetup ? null : _skip,
                        child: const Text('Skip',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: [
                        _brief(
                          emblem: const Trophy(size: 150),
                          title: 'Football Champions 2026',
                          subtitle:
                              'Your journey to football glory starts here. Learn, predict, collect and compete!',
                        ),
                        _brief(
                          emblem: const JourneyMascot(size: 140),
                          title: 'Learn & Level Up',
                          subtitle:
                              'Play bite-size lessons about teams, players and stadiums. Earn XP, build streaks and climb levels.',
                        ),
                        _brief(
                          emblem: const CardFanEmblem(size: 140),
                          title: 'Collect & Open Packs',
                          subtitle:
                              'Unlock collectible cards of every rarity and open mystery packs for rewards.',
                        ),
                        _brief(
                          emblem: const _PredictBattleEmblem(),
                          title: 'Predict & Battle',
                          subtitle:
                              'Predict match results, take live challenges, and battle rivals for trophies.',
                        ),
                        _setupPage(),
                      ],
                    ),
                  ),
                  _dots(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: onSetup
                        ? PrimaryButton(
                            label: _selected.isEmpty
                                ? 'Pick at least one team'
                                : "Let's Go!",
                            icon: Icons.sports_soccer_rounded,
                            onPressed: _selected.isEmpty ? null : _finish,
                          )
                        : PrimaryButton(
                            label: 'Next',
                            trailingIcon: Icons.arrow_forward_rounded,
                            gradient: AppColors.goldCta,
                            onPressed: _next,
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

  Widget _brief({
    required Widget emblem,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _setupPage() {
    final teams = ref.watch(teamsProvider).valueOrNull ?? const [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      children: [
        const SizedBox(height: 4),
        const Text(
          'Your name',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 24),
        ),
        const SizedBox(height: 6),
        const Text(
          "What should fans call you? You can change this later.",
          textAlign: TextAlign.center,
          style:
              TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _nameController,
          maxLength: 16,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'e.g. Alex',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Pick Your Clubs',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 24),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose the teams you support. Tap ⭐ to set your main club — your XP powers it on the leaderboards.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [for (final t in teams) _teamChip(t)],
        ),
        const SizedBox(height: 22),
        const Text('Choose your avatar',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: [
            for (final seed in _avatarOptions)
              GestureDetector(
                onTap: () => setState(() => _avatarSeed = seed),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _avatarSeed == seed
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: AvatarChip(seed: seed, size: 52),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _teamChip(Team t) {
    final selected = _selected.contains(t.id);
    final isPrimary = _primary == t.id;
    return GestureDetector(
      onTap: () => _toggleTeam(t.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primaryGreen.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.12),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.flagEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              t.code,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
            ),
            const SizedBox(width: 6),
            if (selected)
              GestureDetector(
                onTap: () => setState(() => _primary = t.id),
                child: Icon(
                  isPrimary ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isPrimary ? AppColors.gold : AppColors.textMuted,
                  size: 20,
                ),
              )
            else
              const Icon(Icons.add_rounded,
                  color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_lastPage + 1, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGreen : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _PredictBattleEmblem extends StatelessWidget {
  const _PredictBattleEmblem();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-36, 0),
            child: _badge(Icons.online_prediction_rounded,
                AppColors.greenCta, AppColors.primaryGreen),
          ),
          Transform.translate(
            offset: const Offset(36, 0),
            child: _badge(
                Icons.sports_kabaddi_rounded,
                const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)]),
                AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, Gradient gradient, Color glow) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: glow.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 48),
    );
  }
}
