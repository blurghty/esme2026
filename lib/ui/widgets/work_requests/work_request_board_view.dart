import 'package:esme26/application/work_request_board_controller.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_card.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:esme26/ui/widgets/work_requests/work_requests_empty_state.dart';
import 'package:flutter/material.dart';

/// Open work requests for artisans, with a filter by trade.
class WorkRequestBoardView extends StatelessWidget {
  final WorkRequestBoardController controller;
  final ValueChanged<String> onOpen;

  const WorkRequestBoardView({
    super.key,
    required this.controller,
    required this.onOpen,
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
              Text(
                countLabel(
                  controller.openCount,
                  'demande ouverte aux devis',
                  'demandes ouvertes aux devis',
                ),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Consultez les projets des particuliers et repérez ceux '
                'qui correspondent à votre métier.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tous les métiers'),
                    selected: controller.tradeFilter == null,
                    onSelected: (_) => controller.selectTrade(null),
                  ),
                  for (final trade in controller.filterTrades)
                    ChoiceChip(
                      label: Text(trade.name),
                      selected: controller.tradeFilter == trade.id,
                      onSelected: (_) => controller.selectTrade(trade.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (requests.isEmpty)
                const WorkRequestsEmptyState(
                  icon: Icons.inbox_outlined,
                  message: 'Aucune demande ouverte pour le moment.',
                )
              else
                for (final request in requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WorkRequestCard(
                      request: request,
                      tradeNames: controller.tradeNamesOf(request),
                      onTap: () => onOpen(request.id),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
