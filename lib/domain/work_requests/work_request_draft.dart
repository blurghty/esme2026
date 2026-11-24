import 'package:esme26/domain/models/adress.dart';
import 'package:esme26/domain/models/money.dart';
import 'package:esme26/domain/models/work_request.dart';

enum BudgetIssue { incomplete, notPositive, inverted }

/// Inputs collected before a customer publishes a work request.
class WorkRequestDraft {
  static const minTitleLength = 5;
  static const minDescriptionLength = 20;

  String title = '';
  String description = '';
  final Set<String> _tradeIds = {};
  String street;
  String city;
  String postalCode;
  String country;
  PropertyType propertyType = PropertyType.apartment;
  WorkUrgency urgency = WorkUrgency.flexible;

  /// Optional budget bounds in whole euros; both or neither must be set.
  int? minimumBudgetInEuros;
  int? maximumBudgetInEuros;

  /// [adress] pre-fills the work location, usually with the customer's own.
  WorkRequestDraft({Adress? adress})
    : street = adress?.street ?? '',
      city = adress?.city ?? '',
      postalCode = adress?.postalCode ?? '',
      country = (adress?.country.trim().isNotEmpty ?? false)
          ? adress!.country
          : 'France';

  Set<String> get tradeIds => Set.unmodifiable(_tradeIds);

  void toggleTrade(String tradeId) {
    if (!_tradeIds.remove(tradeId)) {
      _tradeIds.add(tradeId);
    }
  }

  static bool isValidTitle(String value) =>
      value.trim().length >= minTitleLength;

  static bool isValidDescription(String value) =>
      value.trim().length >= minDescriptionLength;

  static bool isFilled(String value) => value.trim().isNotEmpty;

  static BudgetIssue? checkBudget(int? minimum, int? maximum) {
    if (minimum == null && maximum == null) return null;
    if (minimum == null || maximum == null) return BudgetIssue.incomplete;
    if (minimum <= 0 || maximum <= 0) return BudgetIssue.notPositive;
    if (minimum > maximum) return BudgetIssue.inverted;
    return null;
  }

  bool get isComplete =>
      isValidTitle(title) &&
      isValidDescription(description) &&
      _tradeIds.isNotEmpty &&
      isFilled(city) &&
      isFilled(postalCode) &&
      isFilled(country) &&
      checkBudget(minimumBudgetInEuros, maximumBudgetInEuros) == null;

  /// Builds the published request; throws [StateError] when incomplete.
  WorkRequest publish({
    required String id,
    required String customerId,
    required DateTime now,
  }) {
    if (!isComplete) {
      throw StateError('Cannot publish an incomplete work request.');
    }
    final minimum = minimumBudgetInEuros;
    final maximum = maximumBudgetInEuros;
    return WorkRequest(
      id: id,
      customerId: customerId,
      title: title.trim(),
      description: description.trim(),
      tradeIds: _tradeIds,
      adress: Adress(
        street: street.trim(),
        city: city.trim(),
        postalCode: postalCode.trim(),
        country: country.trim(),
      ),
      propertyType: propertyType,
      urgency: urgency,
      status: WorkRequestStatus.published,
      budget: minimum == null || maximum == null
          ? null
          : Budget(
              minimum: Money(minorUnits: minimum * 100),
              maximum: Money(minorUnits: maximum * 100),
            ),
      createdAt: now,
      updatedAt: now,
    );
  }
}
