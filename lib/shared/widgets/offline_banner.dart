import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/core/connectivity/connectivity_cubit.dart';

/// Compact, non-intrusive banner that appears at the top of any screen when
/// the device loses network connectivity. Wrap the page body with this widget
/// — when online it renders nothing, so layout is unaffected.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message});

  /// Optional override; defaults to "No connection — changes will sync when
  /// you're back online".
  final String? message;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        if (status == ConnectivityStatus.online) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.errorContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_outlined,
                      size: 18, color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message ??
                          "No connection — changes will sync when you're back online",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
