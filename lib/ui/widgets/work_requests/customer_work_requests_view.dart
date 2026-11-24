import 'package:esme26/application/customer_work_requests_controller.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_card.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:esme26/ui/widgets/work_requests/work_requests_empty_state.dart';
import 'package:flutter/material.dart';

/// The current customer's work requests and their status.
class CustomerWorkRequestsView extends StatelessWidget {
  final CustomerWorkRequestsController controller;
  final ValueChanged<String> onOpen;
  final VoidCallback onCreate;

  const CustomerWorkRequestsView({
    super.key,
    required this.controller,
    required this.onOpen,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = controller.requests;
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              if (requests.isEmpty)
                WorkRequestsEmptyState(
                  icon: Icons.assignment_outlined,
                  message:
                      'Vous n’avez pas encore de demande de projet.\n'
                      'Décrivez vos travaux pour recevoir des devis d’artisans.',
                  actionLabel: controller.canCreate
                      ? 'Créer ma première demande'
                      : null,
                  onAction: controller.canCreate ? onCreate : null,
                )
              else ...[
                Text(
                  '${countLabel(requests.length, 'demande', 'demandes')}'
                  ' · ${countLabel(controller.activeCount, 'en cours', 'en cours')}',
                  style: theme.textTheme.titleMedium,
                ),
                if (controller.canCreate) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle demande'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                for (final request in requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WorkRequestCard(
                      request: request,
                      tradeNames: controller.tradeNamesOf(request),
                      showStatus: true,
                      onTap: () => onOpen(request.id),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
