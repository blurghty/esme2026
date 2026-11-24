import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_badges.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:flutter/material.dart';

/// Summary of a work request in a list.
class WorkRequestCard extends StatelessWidget {
  final WorkRequest request;
  final List<String> tradeNames;

  /// Customers follow the status of their requests; artisans the urgency.
  final bool showStatus;
  final VoidCallback onTap;

  const WorkRequestCard({
    super.key,
    required this.request,
    required this.tradeNames,
    required this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (showStatus)
                    WorkRequestStatusBadge(status: request.status),
                  WorkUrgencyBadge(urgency: request.urgency),
                ],
              ),
              const SizedBox(height: 8),
              Text(request.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  WorkRequestInfo(
                    icon: Icons.handyman_outlined,
                    text: tradeNames.join(', '),
                  ),
                  WorkRequestInfo(
                    icon: Icons.place_outlined,
                    text:
                        '${request.adress.city} (${request.adress.postalCode})',
                  ),
                  WorkRequestInfo(
                    icon: Icons.euro_outlined,
                    text: formatBudget(request.budget),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Publiée le ${formatDate(request.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
