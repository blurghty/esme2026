import 'package:esme26/domain/models/attachment.dart';
import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_badges.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:esme26/ui/widgets/work_requests/work_requests_empty_state.dart';
import 'package:flutter/material.dart';

/// Full description of a work request.
class WorkRequestDetailsView extends StatelessWidget {
  /// Null when the request no longer exists.
  final WorkRequest? request;
  final List<String> tradeNames;
  final bool isOwnRequest;

  const WorkRequestDetailsView({
    super.key,
    required this.request,
    required this.tradeNames,
    required this.isOwnRequest,
  });

  @override
  Widget build(BuildContext context) {
    final request = this.request;
    if (request == null) {
      return const Center(
        child: WorkRequestsEmptyState(
          icon: Icons.search_off,
          message: 'Cette demande de projet est introuvable.',
        ),
      );
    }
    final theme = Theme.of(context);
    final period = request.preferredPeriod;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (isOwnRequest)
                  WorkRequestStatusBadge(status: request.status),
                WorkUrgencyBadge(urgency: request.urgency),
              ],
            ),
            const SizedBox(height: 12),
            Text(request.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              isOwnRequest
                  ? 'Votre demande, publiée le ${formatDate(request.createdAt)}'
                  : 'Publiée le ${formatDate(request.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _DetailSection(
              title: 'Description',
              child: Text(
                request.description,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            _DetailSection(
              title: 'Corps de métier',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in tradeNames) Chip(label: Text(name)),
                ],
              ),
            ),
            _DetailSection(
              title: 'Informations',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.place_outlined,
                    label: 'Lieu',
                    value:
                        '${request.adress.city} (${request.adress.postalCode})',
                  ),
                  _DetailRow(
                    icon: Icons.home_work_outlined,
                    label: 'Logement',
                    value: request.propertyType.label,
                  ),
                  _DetailRow(
                    icon: Icons.euro_outlined,
                    label: 'Budget',
                    value: formatBudget(request.budget),
                  ),
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: 'Période souhaitée',
                    value: period == null
                        ? request.urgency.hint
                        : formatPeriod(period),
                  ),
                ],
              ),
            ),
            if (request.attachments.isNotEmpty)
              _DetailSection(
                title: 'Pièces jointes',
                child: Column(
                  children: [
                    for (final attachment in request.attachments)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          attachment.kind == AttachmentKind.image
                              ? Icons.image_outlined
                              : Icons.description_outlined,
                        ),
                        title: Text(attachment.fileName),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
