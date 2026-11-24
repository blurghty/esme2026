import 'package:esme26/domain/models/trade.dart';
import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/domain/work_requests/trade_catalog.dart';
import 'package:esme26/domain/work_requests/work_request_draft.dart';
import 'package:flutter/foundation.dart';

/// Collects a customer's project description and publishes it to artisans.
class WorkRequestFormController extends ChangeNotifier {
  final WorkRequestRepository workRequestRepository;
  final TradeCatalog _catalog;
  final String? _customerId;
  final WorkRequestDraft _draft;
  final String Function() _createId;
  final DateTime Function() _now;
  WorkRequest? _published;

  WorkRequestFormController({
    required this.workRequestRepository,
    required TradeRepository tradeRepository,
    required UserRepository userRepository,
    String Function()? createId,
    DateTime Function()? now,
  }) : _catalog = TradeCatalog(tradeRepository.getAll()),
       _customerId = userRepository.me()?.id,
       _draft = WorkRequestDraft(adress: userRepository.me()?.adress),
       _createId = createId ?? _defaultId,
       _now = now ?? _utcNow;

  static String _defaultId() =>
      'request-${DateTime.now().microsecondsSinceEpoch}';

  static DateTime _utcNow() => DateTime.now().toUtc();

  List<Trade> get trades => _catalog.all;
  String get title => _draft.title;
  String get description => _draft.description;
  Set<String> get tradeIds => _draft.tradeIds;
  String get street => _draft.street;
  String get city => _draft.city;
  String get postalCode => _draft.postalCode;
  PropertyType get propertyType => _draft.propertyType;
  WorkUrgency get urgency => _draft.urgency;
  int? get minimumBudget => _draft.minimumBudgetInEuros;
  int? get maximumBudget => _draft.maximumBudgetInEuros;

  /// The request once published, otherwise null.
  WorkRequest? get published => _published;
  bool get isPublished => _published != null;

  void updateTitle(String value) => _draft.title = value;
  void updateDescription(String value) => _draft.description = value;
  void updateStreet(String value) => _draft.street = value;
  void updateCity(String value) => _draft.city = value;
  void updatePostalCode(String value) => _draft.postalCode = value;
  void updateMinimumBudget(String value) =>
      _draft.minimumBudgetInEuros = int.tryParse(value.trim());
  void updateMaximumBudget(String value) =>
      _draft.maximumBudgetInEuros = int.tryParse(value.trim());

  void toggleTrade(String tradeId) {
    _draft.toggleTrade(tradeId);
    notifyListeners();
  }

  void choosePropertyType(PropertyType value) {
    _draft.propertyType = value;
    notifyListeners();
  }

  void chooseUrgency(WorkUrgency value) {
    _draft.urgency = value;
    notifyListeners();
  }

  /// Saves the request as published for the current customer, once.
  void publish() {
    if (isPublished) return;
    final customerId = _customerId;
    if (customerId == null) {
      throw StateError('A signed-in customer is required to publish.');
    }
    final request = _draft.publish(
      id: _createId(),
      customerId: customerId,
      now: _now(),
    );
    workRequestRepository.save(request);
    _published = request;
    notifyListeners();
  }
}
