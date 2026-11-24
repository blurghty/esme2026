import 'dart:async';

import 'package:esme26/application/customer_work_requests_controller.dart';
import 'package:esme26/application/region_map_controller.dart';
import 'package:esme26/application/work_request_board_controller.dart';
import 'package:esme26/data/repositories/region_map_repository.dart' as data;
import 'package:esme26/data/repositories/trade_repository.dart' as data;
import 'package:esme26/data/repositories/user_repository.dart' as data;
import 'package:esme26/data/repositories/work_request_repository.dart' as data;
import 'package:esme26/domain/models/user.dart';
import 'package:esme26/domain/repositories/region_map_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/ui/widgets/home/region_map_view.dart';
import 'package:esme26/ui/widgets/home/work_requests_shortcut.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final UserRole role;
  final String firstName;
  final RegionMapRepository? regionMapRepository;
  final UserRepository? userRepository;

  const HomePage({
    super.key,
    required this.role,
    required this.firstName,
    this.regionMapRepository,
    this.userRepository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final RegionMapController _mapController;

  /// Exactly one of these is set, depending on the role.
  WorkRequestBoardController? _boardController;
  CustomerWorkRequestsController? _customerController;

  @override
  void initState() {
    super.initState();
    _mapController = RegionMapController(
      repository:
          widget.regionMapRepository ?? data.RegionMapRepository.instance,
    );
    unawaited(_mapController.load());
    if (widget.role == UserRole.artisan) {
      _boardController = WorkRequestBoardController(
        workRequestRepository: data.WorkRequestRepository.instance,
        tradeRepository: data.TradeRepository.instance,
      );
    } else {
      _customerController = CustomerWorkRequestsController(
        workRequestRepository: data.WorkRequestRepository.instance,
        userRepository: widget.userRepository ?? data.UserRepository.instance,
        tradeRepository: data.TradeRepository.instance,
      );
    }
  }

  Future<void> _openWorkRequests() async {
    await context.push(
      widget.role == UserRole.artisan ? '/requests' : '/my-requests',
    );
    if (!mounted) return;
    _boardController?.refresh();
    _customerController?.refresh();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _boardController?.dispose();
    _customerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = widget.role;
    final firstName = widget.firstName.trim();
    final welcome = firstName.isEmpty
        ? 'Bienvenue dans votre espace ${role == UserRole.artisan ? 'artisan' : 'particulier'} !'
        : 'Bienvenue $firstName !';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                role == UserRole.artisan
                    ? Icons.handyman_outlined
                    : Icons.home_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(welcome, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Votre parcours de découverte est terminé.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_boardController case final board?)
            ListenableBuilder(
              listenable: board,
              builder: (context, _) => WorkRequestsShortcut(
                icon: Icons.assignment_outlined,
                title: 'Demandes de projet',
                subtitle: countLabel(
                  board.openCount,
                  'demande ouverte aux devis',
                  'demandes ouvertes aux devis',
                ),
                onTap: _openWorkRequests,
              ),
            ),
          if (_customerController case final mine?)
            ListenableBuilder(
              listenable: mine,
              builder: (context, _) => WorkRequestsShortcut(
                icon: Icons.assignment_outlined,
                title: 'Mes demandes de projet',
                subtitle: mine.requests.isEmpty
                    ? 'Décrivez vos travaux aux artisans'
                    : '${countLabel(mine.requests.length, 'demande', 'demandes')}'
                          ' · ${mine.activeCount} en cours',
                onTap: _openWorkRequests,
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RegionMapView(controller: _mapController),
            ),
          ),
        ],
      ),
    );
  }
}
