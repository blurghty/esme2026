import 'package:esme26/domain/models/money.dart';
import 'package:esme26/domain/models/time_slot.dart';
import 'package:esme26/domain/models/work_request.dart';

/// French labels and formats used by the work request screens.
extension WorkRequestStatusLabel on WorkRequestStatus {
  String get label => switch (this) {
    WorkRequestStatus.draft => 'Brouillon',
    WorkRequestStatus.published => 'Publiée',
    WorkRequestStatus.assigned => 'Artisan choisi',
    WorkRequestStatus.closed => 'Terminée',
    WorkRequestStatus.cancelled => 'Annulée',
  };
}

extension WorkUrgencyLabel on WorkUrgency {
  String get label => switch (this) {
    WorkUrgency.flexible => 'Flexible',
    WorkUrgency.scheduled => 'Planifié',
    WorkUrgency.urgent => 'Urgent',
  };

  String get hint => switch (this) {
    WorkUrgency.flexible => 'Pas de contrainte de date particulière.',
    WorkUrgency.scheduled => 'À réaliser sur une période précise.',
    WorkUrgency.urgent => 'Une intervention rapide est nécessaire.',
  };
}

extension PropertyTypeLabel on PropertyType {
  String get label => switch (this) {
    PropertyType.apartment => 'Appartement',
    PropertyType.house => 'Maison',
    PropertyType.other => 'Autre',
  };
}

const _nbsp = ' ';

const _months = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// Formats an amount in euros, e.g. `1 500 €` or `45,50 €`.
String formatMoney(Money money) {
  final euros = money.minorUnits ~/ 100;
  final cents = money.minorUnits % 100;
  final digits = euros.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(_nbsp);
    grouped.write(digits[i]);
  }
  final decimals = cents == 0 ? '' : ',${cents.toString().padLeft(2, '0')}';
  final symbol = money.currency == 'EUR' ? '€' : money.currency;
  return '$grouped$decimals$_nbsp$symbol';
}

String formatBudget(Budget? budget) {
  if (budget == null) return 'Budget à définir';
  if (budget.minimum == budget.maximum) return formatMoney(budget.maximum);
  return '${formatMoney(budget.minimum)} – ${formatMoney(budget.maximum)}';
}

/// Formats a date in the device time zone, e.g. `23 nov. 2026`.
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

String formatPeriod(TimeSlot period) {
  final start = formatDate(period.startsAt);
  final end = formatDate(period.endsAt);
  return start == end ? 'Le $start' : 'Du $start au $end';
}

/// Returns e.g. `1 demande` or `3 demandes`.
String countLabel(int count, String singular, String plural) =>
    '$count ${count > 1 ? plural : singular}';
