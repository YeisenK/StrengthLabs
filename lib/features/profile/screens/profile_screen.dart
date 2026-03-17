import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(profile: profile, user: user, ref: ref),
          ),

          // ── Stats strip ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: _StatsStrip(profile: profile),
            ),
          ),

          // ── Sections ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader('INFORMACIÓN PERSONAL'),
                const SizedBox(height: 4),
                _SectionCard(children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Nombre completo',
                    value: user?.fullName.isNotEmpty == true
                        ? user!.fullName
                        : null,
                    onTap: () => _showInfoDialog(context),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: user?.email,
                    onTap: () => _showInfoDialog(context),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Fecha nacimiento',
                    value: profile.birthDate != null
                        ? DateFormat('dd MMM yyyy', 'es').format(profile.birthDate!)
                        : null,
                    onTap: () => _pickBirthDate(context, ref, profile.birthDate),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso',
                    value: profile.weightKg != null
                        ? '${profile.weightKg!.toStringAsFixed(1)} kg'
                        : null,
                    onTap: () => _showNumberEditor(
                      context,
                      ref,
                      label: 'Peso (kg)',
                      current: profile.weightKg,
                      onSave: (v) => ref.read(profileProvider.notifier).updateWeight(v),
                    ),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.height_rounded,
                    label: 'Altura',
                    value: profile.heightCm != null
                        ? '${profile.heightCm!.toStringAsFixed(0)} cm'
                        : null,
                    onTap: () => _showNumberEditor(
                      context,
                      ref,
                      label: 'Altura (cm)',
                      current: profile.heightCm,
                      onSave: (v) => ref.read(profileProvider.notifier).updateHeight(v),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),
                _SectionHeader('ENTRENAMIENTO'),
                const SizedBox(height: 4),
                _SectionCard(children: [
                  _InfoRow(
                    icon: Icons.flag_outlined,
                    label: 'Objetivo',
                    value: profile.goal,
                    onTap: () => _showPickerSheet(
                      context,
                      title: 'Objetivo',
                      options: kGoalOptions,
                      selected: profile.goal,
                      onSelect: (v) =>
                          ref.read(profileProvider.notifier).updateGoal(v),
                    ),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.trending_up_rounded,
                    label: 'Nivel',
                    value: profile.experienceLevel.label,
                    onTap: () => _showPickerSheet(
                      context,
                      title: 'Nivel de experiencia',
                      options: ExperienceLevel.values.map((e) => e.label).toList(),
                      selected: profile.experienceLevel.label,
                      onSelect: (v) {
                        final level = ExperienceLevel.values
                            .firstWhere((e) => e.label == v);
                        ref.read(profileProvider.notifier).updateLevel(level);
                      },
                    ),
                  ),
                ]),

                const SizedBox(height: 20),
                _SectionHeader('AJUSTES'),
                const SizedBox(height: 4),
                _SectionCard(children: [
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notificaciones',
                    value: profile.notificationsEnabled,
                    onChanged: (v) =>
                        ref.read(profileProvider.notifier).toggleNotifications(v),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Cambiar contraseña',
                    onTap: () => _showInfoDialog(context,
                        msg: 'Disponible cuando el backend esté conectado.'),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.shield_outlined,
                    label: 'Privacidad',
                    onTap: () => _showInfoDialog(context,
                        msg: 'Política de privacidad próximamente.'),
                  ),
                ]),

                const SizedBox(height: 28),

                // ── Logout ───────────────────────────────
                _LogoutButton(
                  onTap: () => _confirmLogout(context, ref),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────

  void _showInfoDialog(BuildContext context, {String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          msg ?? 'Edición de nombre/email disponible con el backend.',
          style: const TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 10,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate(
      BuildContext context, WidgetRef ref, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surface2,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(profileProvider.notifier).updateBirthDate(picked);
    }
  }

  Future<void> _showNumberEditor(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required double? current,
    required void Function(double?) onSave,
  }) async {
    final ctrl = TextEditingController(
        text: current != null ? current.toStringAsFixed(1) : '');
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 9,
                letterSpacing: 3,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                ),
                cursorColor: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border2),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(
                          fontFamily: 'BarlowCondensed',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
                      onSave(v);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'GUARDAR',
                        style: TextStyle(
                          fontFamily: 'BarlowCondensed',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPickerSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String? selected,
    required void Function(String) onSelect,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 9,
                letterSpacing: 3,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((opt) => InkWell(
                  onTap: () {
                    onSelect(opt);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontFamily: 'BarlowCondensed',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 1,
                              color: opt == selected
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (opt == selected)
                          const Icon(Icons.check_rounded,
                              color: AppColors.accent, size: 18),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'CERRAR SESIÓN',
          style: TextStyle(
            fontFamily: 'BarlowCondensed',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 1,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          '¿Seguro que quieres cerrar sesión?',
          style: TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 1,
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'CERRAR SESIÓN',
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 1,
                color: AppColors.riskRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(authProvider.notifier).logout();
    }
  }
}

// ─────────────────────────────────────────────────────────
// PROFILE HEADER
// ─────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final dynamic user;
  final WidgetRef ref;

  const _ProfileHeader({
    required this.profile,
    required this.user,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────
              Row(
                children: [
                  const Text(
                    'PERFIL',
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Avatar ───────────────────────────────
              _AvatarWidget(
                profile: profile,
                initial: user?.initial ?? '?',
                onTap: () => _pickPhoto(context),
              ),
              const SizedBox(height: 14),

              // ── Name ─────────────────────────────────
              Text(
                user?.fullName.isNotEmpty == true
                    ? user!.fullName
                    : (user?.email ?? ''),
                style: const TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'FOTO DE PERFIL',
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 9,
                letterSpacing: 3,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            _PickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Elegir de la galería',
              onTap: () async {
                Navigator.pop(ctx);
                final file = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (file != null) {
                  ref.read(profileProvider.notifier).updatePhoto(file.path);
                }
              },
            ),
            _PickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Tomar foto',
              onTap: () async {
                Navigator.pop(ctx);
                final file = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (file != null) {
                  ref.read(profileProvider.notifier).updatePhoto(file.path);
                }
              },
            ),
            if (profile.photoPath != null)
              _PickerOption(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar foto',
                color: AppColors.riskRed,
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(profileProvider.notifier).removePhoto();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// AVATAR WIDGET
// ─────────────────────────────────────────────────────────
class _AvatarWidget extends StatelessWidget {
  final UserProfile profile;
  final String initial;
  final VoidCallback onTap;

  const _AvatarWidget({
    required this.profile,
    required this.initial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // ── Photo or initials ─────────────────────
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5),
                width: 2,
              ),
              gradient: profile.photoPath == null
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accent2],
                    )
                  : null,
              image: profile.photoPath != null
                  ? DecorationImage(
                      image: FileImage(File(profile.photoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile.photoPath == null
                ? Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: 'BarlowCondensed',
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          ),

          // ── Camera badge ─────────────────────────
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bg, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.textPrimary,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STATS STRIP
// ─────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final UserProfile profile;

  const _StatsStrip({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatCell(
            value: '${profile.totalSessions}',
            label: 'SESIONES',
            color: AppColors.accent,
          ),
          _StatDivider(),
          _StatCell(
            value: '${profile.currentStreak}d',
            label: 'RACHA',
            color: AppColors.accent2,
          ),
          _StatDivider(),
          _StatCell(
            value: profile.experienceLevel.label.substring(0, 3),
            label: 'NIVEL',
            color: AppColors.accent4,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'BarlowCondensed',
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 8,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border2,
    );
  }
}

// ─────────────────────────────────────────────────────────
// SECTION COMPONENTS
// ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'ShareTechMono',
          fontSize: 9,
          letterSpacing: 3,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 52,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surface3,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PICKER OPTION (bottom sheet)
// ─────────────────────────────────────────────────────────
class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.riskRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.riskRed.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.riskRed, size: 18),
            SizedBox(width: 10),
            Text(
              'CERRAR SESIÓN',
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 2,
                color: AppColors.riskRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
