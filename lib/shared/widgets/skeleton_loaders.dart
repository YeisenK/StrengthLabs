import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ── Base helper ───────────────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

Widget _shimmer(BuildContext context, Widget child) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Shimmer.fromColors(
    baseColor: isDark
        ? const Color(0xFF2A2A3A)
        : const Color(0xFFE0E0E0),
    highlightColor: isDark
        ? const Color(0xFF3A3A4A)
        : const Color(0xFFF5F5F5),
    child: child,
  );
}

// ── 3.1a — Workout list skeleton ──────────────────────────────────────────────

class WorkoutListSkeleton extends StatelessWidget {
  const WorkoutListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, _) => _WorkoutCardSkeleton(context: context),
          childCount: 5,
        ),
      ),
    );
  }
}

class _WorkoutCardSkeleton extends StatelessWidget {
  const _WorkoutCardSkeleton({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _shimmer(ctx, Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _ShimmerBox(width: 160, height: 16),
                  const Spacer(),
                  const _ShimmerBox(width: 56, height: 12),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const _ShimmerBox(width: 60, height: 12),
                  const SizedBox(width: 20),
                  const _ShimmerBox(width: 70, height: 12),
                  const SizedBox(width: 20),
                  const _ShimmerBox(width: 55, height: 12),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const _ShimmerBox(width: 56, height: 20, borderRadius: 6),
                  const SizedBox(width: 6),
                  const _ShimmerBox(width: 48, height: 20, borderRadius: 6),
                  const SizedBox(width: 6),
                  const _ShimmerBox(width: 40, height: 20, borderRadius: 6),
                ],
              ),
            ],
          )),
        ),
      ),
    );
  }
}

// ── 3.1b — Routine list skeleton ─────────────────────────────────────────────

class RoutineListSkeleton extends StatelessWidget {
  const RoutineListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, _) => _RoutineCardSkeleton(context: context),
          childCount: 4,
        ),
      ),
    );
  }
}

class _RoutineCardSkeleton extends StatelessWidget {
  const _RoutineCardSkeleton({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _shimmer(ctx, Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _ShimmerBox(width: 64, height: 20, borderRadius: 6),
                  const SizedBox(width: 8),
                  const _ShimmerBox(width: 72, height: 20, borderRadius: 6),
                  const Spacer(),
                  const _ShimmerBox(width: 20, height: 20, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 10),
              const _ShimmerBox(width: 200, height: 16),
              const SizedBox(height: 8),
              const _ShimmerBox(width: null, height: 12),
              const SizedBox(height: 4),
              const _ShimmerBox(width: 220, height: 12),
              const SizedBox(height: 14),
              Row(
                children: [
                  const _ShimmerBox(width: 90, height: 12),
                  const SizedBox(width: 16),
                  const _ShimmerBox(width: 100, height: 12),
                ],
              ),
            ],
          )),
        ),
      ),
    );
  }
}

// ── 3.1c — Fatigue skeleton ───────────────────────────────────────────────────

class FatigueSkeleton extends StatelessWidget {
  const FatigueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Readiness gauge card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _shimmer(context, Column(
                children: [
                  const _ShimmerBox(width: 120, height: 14),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ShimmerBox(width: 200, height: 12),
                ],
              )),
            ),
          ),
          const SizedBox(height: 16),
          // Metrics row
          _shimmer(context, Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    child: Column(
                      children: [
                        const _ShimmerBox(width: 24, height: 24, borderRadius: 4),
                        const SizedBox(height: 8),
                        const _ShimmerBox(width: 48, height: 14),
                        const SizedBox(height: 4),
                        const _ShimmerBox(width: 36, height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            )),
          )),
          const SizedBox(height: 16),
          // Volume card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _shimmer(context, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShimmerBox(width: 180, height: 14),
                  const SizedBox(height: 16),
                  ...List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        _ShimmerBox(width: 70 + i * 10.0, height: 10),
                        const SizedBox(width: 8),
                        Expanded(child: _ShimmerBox(
                          width: null, height: 10,
                          borderRadius: 5,
                        )),
                      ],
                    ),
                  )),
                ],
              )),
            ),
          ),
        ]),
      ),
    );
  }
}
