import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/domain/work_requests/trade_catalog.dart';
import 'package:esme26/domain/work_requests/work_request_queries.dart';
import 'package:flutter/foundation.dart';

/// Work requests created by the current customer.
class CustomerWorkRequestsController extends ChangeNotifier {
  final WorkRequestRepository workRequestRepository;
  final UserRepository userRepository;
  final TradeCatalog _catalog;
  List<WorkRequest> _requests = const [];

  CustomerWorkRequestsController({
    required this.workRequestRepository,
    required this.userRepository,
    required TradeRepository tradeRepository,
  }) : _catalog = TradeCatalog(tradeRepository.getAll()) {
    _load();
  }

  /// Null when no persisted user is signed in.
  String? get customerId => userRepository.me()?.id;

  bool get canCreate => customerId != null;

  /// The customer's requests, newest first.
  List<WorkRequest> get requests => _requests;

  int get activeCount => _requests.where(WorkRequestQueries.isActive).length;

  List<String> tradeNamesOf(WorkRequest request) =>
      _catalog.namesOf(request.tradeIds);

  /// Reloads the requests, e.g. after a new one was published.
  void refresh() {
    _load();
    notifyListeners();
  }

  void _load() {
    final id = customerId;
    _requests = id == null
        ? const []
        : WorkRequestQueries.ofCustomer(workRequestRepository.getAll(), id);
  }
}
