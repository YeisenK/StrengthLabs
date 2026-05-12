import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_state.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_state.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(
              l10n.settings,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Account ──────────────────────────────────────────────
                _SectionHeader(l10n.account),
                Card(
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.person_outline,
                        label: l10n.name,
                        value: user?.name ?? '—',
                      ),
                      const Divider(height: 1, indent: 56),
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: l10n.email,
                        value: user?.email ?? '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Preferences ───────────────────────────────────────────
                _SectionHeader(l10n.preferences),
                Card(
                  child: Column(
                    children: [
                      _SegmentTile<WeightUnit>(
                        icon: Icons.monitor_weight_outlined,
                        label: l10n.weightUnit,
                        value: settings.weightUnit,
                        options: [
                          (WeightUnit.kg, 'kg'),
                          (WeightUnit.lb, 'lb'),
                        ],
                        onChanged: context.read<SettingsCubit>().setWeightUnit,
                      ),
                      const Divider(height: 1, indent: 56),
                      _SegmentTile<ThemeMode>(
                        icon: Icons.contrast,
                        label: l10n.theme,
                        value: settings.themeMode,
                        options: [
                          (ThemeMode.system, l10n.themeSystem),
                          (ThemeMode.light, l10n.themeLight),
                          (ThemeMode.dark, l10n.themeDark),
                        ],
                        onChanged: context.read<SettingsCubit>().setThemeMode,
                      ),
                      const Divider(height: 1, indent: 56),
                      _SegmentTile<Locale>(
                        icon: Icons.language_outlined,
                        label: l10n.language,
                        value: settings.locale,
                        options: [
                          (const Locale('en'), l10n.langEnglish),
                          (const Locale('es'), l10n.langSpanish),
                        ],
                        onChanged: context.read<SettingsCubit>().setLocale,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── About ─────────────────────────────────────────────────
                _SectionHeader(l10n.about),
                Card(
                  child: _InfoTile(
                    icon: Icons.info_outline,
                    label: l10n.version,
                    value: '1.0.0',
                  ),
                ),
                const SizedBox(height: 32),

                // ── Logout ────────────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => _confirmLogout(context, l10n),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) async {
    final authCubit = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // El router escucha AuthUnauthenticated y redirige a /login automáticamente.
      // No hacer navigator.pop() manual — causaba race condition entre el pop y el redirect.
      await authCubit.logout();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label),
      trailing: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SegmentTile<T> extends StatelessWidget {
  const _SegmentTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segmentedButton = SegmentedButton<T>(
      segments: options
          .map((o) => ButtonSegment<T>(value: o.$1, label: Text(o.$2)))
          .toList(),
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: theme.textTheme.labelSmall,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Text(label, style: theme.textTheme.bodyLarge),
            ],
          ),
          segmentedButton,
        ],
      ),
    );
  }
}
