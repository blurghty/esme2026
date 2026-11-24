import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:flutter/material.dart';

/// Small rounded label used for statuses and urgency.
class WorkRequestBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  const WorkRequestBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: foreground);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 4),
            ],
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}

class WorkRequestStatusBadge extends StatelessWidget {
  final WorkRequestStatus status;

  const WorkRequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      WorkRequestStatus.published => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      WorkRequestStatus.assigned => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      WorkRequestStatus.cancelled => (
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      WorkRequestStatus.draft || WorkRequestStatus.closed => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
    };
    return WorkRequestBadge(
      label: status.label,
      background: background,
      foreground: foreground,
    );
  }
}

class WorkUrgencyBadge extends StatelessWidget {
  final WorkUrgency urgency;

  const WorkUrgencyBadge({super.key, required this.urgency});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (urgency) {
      WorkUrgency.urgent => WorkRequestBadge(
        label: urgency.label,
        icon: Icons.bolt,
        background: colors.error,
        foreground: colors.onError,
      ),
      WorkUrgency.scheduled => WorkRequestBadge(
        label: urgency.label,
        icon: Icons.event_outlined,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      WorkUrgency.flexible => WorkRequestBadge(
        label: urgency.label,
        icon: Icons.schedule_outlined,
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurfaceVariant,
      ),
    };
  }
}

/// Icon followed by a short piece of information.
class WorkRequestInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const WorkRequestInfo({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}
