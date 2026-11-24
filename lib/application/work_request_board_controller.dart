import 'package:esme26/domain/models/trade.dart';
import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/domain/work_requests/trade_catalog.dart';
import 'package:esme26/domain/work_requests/work_request_queries.dart';
import 'package:flutter/foundation.dart';

/// Open work requests shown to artisans, filterable by top-level trade.
class WorkRequestBoardController extends ChangeNotifier {
  final WorkRequestRepository workRequestRepository;
  final TradeCatalog _catalog;
  List<WorkRequest> _open = const [];
  String? _tradeFilter;

  WorkRequestBoardController({
    required this.workRequestRepository,
    required TradeRepository tradeRepository,
  }) : _catalog = TradeCatalog(tradeRepository.getAll()) {
    _load();
  }

  /// Open requests matching the current filter, newest first.
  List<WorkRequest> get requests {
    final filter = _tradeFilter;
    if (filter == null) return _open;
    return List.unmodifiable(
      _open.where((request) => _catalog.covers(request, filter)),
    );
  }

  int get openCount => _open.length;

  /// Top-level trades that have at least one open request.
  List<Trade> get filterTrades => _catalog.rootsOf(_open);

  /// Selected top-level trade id, or null for every trade.
  String? get tradeFilter => _tradeFilter;

  List<String> tradeNamesOf(WorkRequest request) =>
      _catalog.namesOf(request.tradeIds);

  void selectTrade(String? rootTradeId) {
    if (_tradeFilter == rootTradeId) return;
    _tradeFilter = rootTradeId;
    notifyListeners();
  }

  /// Reloads the requests, e.g. after returning from another screen.
  void refresh() {
    _load();
    notifyListeners();
  }

  void _load() {
    _open = WorkRequestQueries.open(workRequestRepository.getAll());
    final filter = _tradeFilter;
    if (filter != null && !filterTrades.any((trade) => trade.id == filter)) {
      _tradeFilter = null;
    }
  }
}
