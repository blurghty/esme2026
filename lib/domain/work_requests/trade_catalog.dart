import 'package:esme26/domain/models/trade.dart';
import 'package:esme26/domain/models/work_request.dart';

/// Read-only view of the trade hierarchy used to label and filter requests.
class TradeCatalog {
  final List<Trade> _trades;
  final Map<String, Trade> _byId;

  TradeCatalog(Iterable<Trade> trades)
    : _trades = List.unmodifiable(trades),
      _byId = {for (final trade in trades) trade.id: trade};

  /// Every trade, in catalog order.
  List<Trade> get all => _trades;

  /// Returns the trade name, or the id itself when the trade is unknown.
  String nameOf(String tradeId) => _byId[tradeId]?.name ?? tradeId;

  List<String> namesOf(Iterable<String> tradeIds) => [
    for (final id in tradeIds) nameOf(id),
  ];

  /// Returns the top-level trade of [tradeId] (itself when it has no parent).
  String rootOf(String tradeId) {
    var currentId = tradeId;
    final visited = {tradeId};
    while (true) {
      final parentId = _byId[currentId]?.parentTradeId;
      if (parentId == null || !visited.add(parentId)) return currentId;
      currentId = parentId;
    }
  }

  /// Whether [request] needs [rootTradeId] or one of its specialities.
  bool covers(WorkRequest request, String rootTradeId) =>
      request.tradeIds.any((id) => rootOf(id) == rootTradeId);

  /// Known top-level trades needed by [requests], in catalog order.
  List<Trade> rootsOf(Iterable<WorkRequest> requests) {
    final rootIds = {
      for (final request in requests)
        for (final id in request.tradeIds) rootOf(id),
    };
    return [
      for (final trade in _trades)
        if (rootIds.contains(trade.id)) trade,
    ];
  }
}
