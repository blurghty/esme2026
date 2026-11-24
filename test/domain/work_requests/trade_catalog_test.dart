import 'package:esme26/domain/models/models.dart';
import 'package:esme26/domain/work_requests/trade_catalog.dart';
import 'package:esme26/domain/work_requests/work_request_queries.dart';
import 'package:flutter_test/flutter_test.dart';

WorkRequest request(
  String id, {
  Set<String> trades = const {'painting'},
  String customerId = 'customer-1',
  WorkRequestStatus status = WorkRequestStatus.published,
  int day = 1,
}) => WorkRequest(
  id: id,
  customerId: customerId,
  title: 'Projet $id',
  description: 'Description du projet $id',
  tradeIds: trades,
  adress: const Adress(
    street: '',
    city: 'Paris',
    postalCode: '75001',
    country: 'France',
  ),
  propertyType: PropertyType.apartment,
  status: status,
  createdAt: DateTime.utc(2026, 11, day),
  updatedAt: DateTime.utc(2026, 11, day),
);

void main() {
  final catalog = TradeCatalog(const [
    Trade(id: 'painting', name: 'Peinture'),
    Trade(
      id: 'interior',
      name: 'Peinture intérieure',
      parentTradeId: 'painting',
    ),
    Trade(id: 'plumbing', name: 'Plomberie'),
    Trade(id: 'loop-a', name: 'A', parentTradeId: 'loop-b'),
    Trade(id: 'loop-b', name: 'B', parentTradeId: 'loop-a'),
  ]);

  group('TradeCatalog', () {
    test('names trades and falls back to the id when unknown', () {
      expect(catalog.namesOf(['interior', 'unknown']), [
        'Peinture intérieure',
        'unknown',
      ]);
    });

    test('resolves the top-level trade and survives cycles', () {
      expect(catalog.rootOf('interior'), 'painting');
      expect(catalog.rootOf('painting'), 'painting');
      expect(catalog.rootOf('unknown'), 'unknown');
      expect(catalog.rootOf('loop-a'), anyOf('loop-a', 'loop-b'));
    });

    test('a top-level trade covers its specialities', () {
      final interior = request('1', trades: {'interior'});
      expect(catalog.covers(interior, 'painting'), isTrue);
      expect(catalog.covers(interior, 'plumbing'), isFalse);
    });

    test('lists the top-level trades used by requests in catalog order', () {
      final roots = catalog.rootsOf([
        request('1', trades: {'plumbing'}),
        request('2', trades: {'interior'}),
      ]);
      expect(roots.map((trade) => trade.id), ['painting', 'plumbing']);
    });
  });

  group('WorkRequestQueries', () {
    final requests = [
      request('old', day: 1),
      request('closed', status: WorkRequestStatus.closed, day: 5),
      request('new', day: 9),
      request('other', customerId: 'customer-2', day: 3),
    ];

    test('open requests are published ones, newest first', () {
      expect(WorkRequestQueries.open(requests).map((r) => r.id), [
        'new',
        'other',
        'old',
      ]);
    });

    test('customer requests include every status, newest first', () {
      expect(
        WorkRequestQueries.ofCustomer(requests, 'customer-1').map((r) => r.id),
        ['new', 'closed', 'old'],
      );
    });
  });
}
