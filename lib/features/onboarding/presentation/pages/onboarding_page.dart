import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs/core/router/app_router.dart';
import 'package:strengthlabs/features/onboarding/data/onboarding_prefs.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_state.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingPrefs.markCompleted();
    AppRouter.markOnboardingCompleted();
    if (!mounted) return;
    context.go('/workouts');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text(AppLocalizations.of(context)!.onboardingSkip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _WelcomeStep(),
                  _UnitStep(),
                  _RoutineStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 28 : 8,
                    decoration: BoxDecoration(
                      color: active
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(_index == 2 ? AppLocalizations.of(context)!.onboardingStart : AppLocalizations.of(context)!.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Welcome ─────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Unit selector ───────────────────────────────────────────────────

class _UnitStep extends StatelessWidget {
  const _UnitStep();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.scale_outlined, color: scheme.primary, size: 80),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.onboardingUnitTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.onboardingUnitSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _UnitOption(
                      label: AppLocalizations.of(context)!.onboardingUnitKg,
                      sub: 'kg',
                      selected: state.weightUnit == WeightUnit.kg,
                      onTap: () => context
                          .read<SettingsCubit>()
                          .setWeightUnit(WeightUnit.kg),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UnitOption(
                      label: AppLocalizations.of(context)!.onboardingUnitLb,
                      sub: 'lb',
                      selected: state.weightUnit == WeightUnit.lb,
                      onTap: () => context
                          .read<SettingsCubit>()
                          .setWeightUnit(WeightUnit.lb),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              sub,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: Routine suggestion ──────────────────────────────────────────────

class _RoutineStep extends StatelessWidget {
  const _RoutineStep();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, color: scheme.primary, size: 80),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.onboardingDoneTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingDoneBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.onboardingTip,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
