import 'package:esme26/domain/models/models.dart';
import 'package:esme26/domain/work_requests/work_request_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WorkRequestDraft completeDraft() =>
      WorkRequestDraft(
          adress: const Adress(
            street: '1 rue Test',
            city: 'Paris',
            postalCode: '75001',
            country: 'France',
          ),
        )
        ..title = '  Repeindre la chambre  '
        ..description = 'Deux couches de peinture blanche sur 12 m2.'
        ..toggleTrade('trade-painting');

  test('pre-fills the location and defaults the country to France', () {
    final prefilled = completeDraft();
    expect(prefilled.city, 'Paris');
    expect(prefilled.postalCode, '75001');
    expect(WorkRequestDraft().country, 'France');
  });

  test('toggling a trade twice removes it', () {
    final draft = completeDraft()..toggleTrade('trade-plumbing');
    expect(draft.tradeIds, {'trade-painting', 'trade-plumbing'});
    draft.toggleTrade('trade-plumbing');
    expect(draft.tradeIds, {'trade-painting'});
    expect(() => draft.tradeIds.add('x'), throwsUnsupportedError);
  });

  test('budget bounds must be both set, positive and ordered', () {
    expect(WorkRequestDraft.checkBudget(null, null), isNull);
    expect(WorkRequestDraft.checkBudget(100, null), BudgetIssue.incomplete);
    expect(WorkRequestDraft.checkBudget(null, 100), BudgetIssue.incomplete);
    expect(WorkRequestDraft.checkBudget(0, 100), BudgetIssue.notPositive);
    expect(WorkRequestDraft.checkBudget(300, 100), BudgetIssue.inverted);
    expect(WorkRequestDraft.checkBudget(100, 100), isNull);
  });

  test('is incomplete without title, description, trade or location', () {
    expect(completeDraft().isComplete, isTrue);
    expect((completeDraft()..title = 'abc').isComplete, isFalse);
    expect((completeDraft()..description = 'Trop court').isComplete, isFalse);
    expect(
      (completeDraft()..toggleTrade('trade-painting')).isComplete,
      isFalse,
    );
    expect((completeDraft()..city = ' ').isComplete, isFalse);
    expect((completeDraft()..postalCode = '').isComplete, isFalse);
    expect((completeDraft()..minimumBudgetInEuros = 50).isComplete, isFalse);
  });

  test('publishes a trimmed request with a budget in cents', () {
    final now = DateTime.utc(2026, 11, 24, 10);
    final request =
        (completeDraft()
              ..urgency = WorkUrgency.urgent
              ..propertyType = PropertyType.house
              ..minimumBudgetInEuros = 400
              ..maximumBudgetInEuros = 1500)
            .publish(id: 'request-new', customerId: 'customer-1', now: now);

    expect(request.id, 'request-new');
    expect(request.customerId, 'customer-1');
    expect(request.title, 'Repeindre la chambre');
    expect(request.status, WorkRequestStatus.published);
    expect(request.urgency, WorkUrgency.urgent);
    expect(request.propertyType, PropertyType.house);
    expect(request.tradeIds, {'trade-painting'});
    expect(request.adress.city, 'Paris');
    expect(request.budget!.minimum, Money(minorUnits: 40000));
    expect(request.budget!.maximum, Money(minorUnits: 150000));
    expect(request.createdAt, now);
    expect(request.updatedAt, now);
  });

  test('publishes without budget and refuses an incomplete draft', () {
    final request = completeDraft().publish(
      id: 'r',
      customerId: 'c',
      now: DateTime.utc(2026),
    );
    expect(request.budget, isNull);
    expect(
      () => WorkRequestDraft().publish(
        id: 'r',
        customerId: 'c',
        now: DateTime.utc(2026),
      ),
      throwsStateError,
    );
  });
}
