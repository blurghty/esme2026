import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/domain/work_requests/trade_catalog.dart';

/// Loads a single work request and the labels needed to display it.
class WorkRequestDetailsController {
  /// Null when the request does not exist.
  final WorkRequest? request;
  final List<String> tradeNames;

  /// Whether the current user is the customer who created the request.
  final bool isOwnRequest;

  WorkRequestDetailsController._(
    this.request,
    this.tradeNames,
    this.isOwnRequest,
  );

  factory WorkRequestDetailsController({
    required String requestId,
    required WorkRequestRepository workRequestRepository,
    required TradeRepository tradeRepository,
    required UserRepository userRepository,
  }) {
    final request = workRequestRepository.getById(requestId);
    final catalog = TradeCatalog(tradeRepository.getAll());
    final meId = userRepository.me()?.id;
    return WorkRequestDetailsController._(
      request,
      request == null ? const [] : catalog.namesOf(request.tradeIds),
      request != null && meId != null && request.customerId == meId,
    );
  }
}
