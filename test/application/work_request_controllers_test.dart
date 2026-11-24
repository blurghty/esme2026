import 'package:esme26/application/customer_work_requests_controller.dart';
import 'package:esme26/application/work_request_board_controller.dart';
import 'package:esme26/application/work_request_details_controller.dart';
import 'package:esme26/application/work_request_form_controller.dart';
import 'package:esme26/data/mocks/mock_data.dart';
import 'package:esme26/data/repositories/in_memory_repository.dart';
import 'package:esme26/data/repositories/in_memory_user_repository.dart';
import 'package:esme26/domain/models/models.dart';
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _Requests extends InMemoryRepository<WorkRequest, String>
    implements WorkRequestRepository {
  _Requests() : super(MockData.workRequests, keyOf: (request) => request.id);
}

class _Trades extends InMemoryRepository<Trade, String>
    implements TradeRepository {
  _Trades() : super(MockData.trades, keyOf: (trade) => trade.id);
}

void main() {
  late _Requests requests;
  late _Trades trades;
  late InMemoryUserRepository users;

  setUp(() {
    requests = _Requests();
    trades = _Trades();
    users = InMemoryUserRepository();
  });

  group('WorkRequestBoardController', () {
    late WorkRequestBoardController board;

    setUp(() {
      board = WorkRequestBoardController(
        workRequestRepository: requests,
        tradeRepository: trades,
      );
    });

    tearDown(() => board.dispose());

    test('lists only published requests, newest first', () {
      expect(board.requests, isNotEmpty);
      expect(board.openCount, board.requests.length);
      for (final request in board.requests) {
        expect(request.status, WorkRequestStatus.published);
      }
      final dates = board.requests.map((request) => request.createdAt).toList();
      expect(dates, [...dates]..sort((a, b) => b.compareTo(a)));
      expect(
        board.requests.map((request) => request.id),
        isNot(contains('request-1')),
      );
    });

    test('filters by top-level trade, including specialities', () {
      var notifications = 0;
      board.addListener(() => notifications++);
      expect(
        board.filterTrades.map((trade) => trade.id),
        contains('trade-painting'),
      );
      expect(
        board.filterTrades.map((trade) => trade.id),
        isNot(contains('trade-interior-painting')),
      );

      board.selectTrade('trade-painting');
      expect(board.requests.map((request) => request.id), [
        'request-7',
        'request-4',
      ]);
      expect(board.tradeNamesOf(board.requests.first), ['Peinture intérieure']);

      board.selectTrade('trade-painting');
      board.selectTrade(null);
      expect(board.requests, hasLength(board.openCount));
      expect(notifications, 2);
    });

    test('refresh shows new requests and drops a stale filter', () {
      board.selectTrade('trade-masonry');
      requests.delete('request-3');
      final published = MockData.workRequests.firstWhere(
        (request) => request.id == 'request-9',
      );
      requests.save(
        WorkRequest(
          id: 'request-new',
          customerId: 'customer-1',
          title: 'Nouveau projet',
          description: published.description,
          tradeIds: {'trade-tiling'},
          adress: published.adress,
          propertyType: PropertyType.apartment,
          status: WorkRequestStatus.published,
          createdAt: DateTime.utc(2026, 12, 1),
          updatedAt: DateTime.utc(2026, 12, 1),
        ),
      );
      board.refresh();
      expect(board.tradeFilter, isNull);
      expect(board.requests.first.id, 'request-new');
    });
  });

  group('CustomerWorkRequestsController', () {
    test('lists every request of the current customer', () {
      final mine = CustomerWorkRequestsController(
        workRequestRepository: requests,
        userRepository: users,
        tradeRepository: trades,
      );
      addTearDown(mine.dispose);
      expect(mine.canCreate, isTrue);
      expect(mine.requests.map((request) => request.customerId).toSet(), {
        'customer-1',
      });
      expect(
        mine.requests.map((request) => request.status).toSet(),
        containsAll([
          WorkRequestStatus.published,
          WorkRequestStatus.assigned,
          WorkRequestStatus.closed,
          WorkRequestStatus.cancelled,
        ]),
      );
      expect(mine.activeCount, 3);
    });

    test('is empty and cannot create without a persisted user', () {
      users.user = null;
      final mine = CustomerWorkRequestsController(
        workRequestRepository: requests,
        userRepository: users,
        tradeRepository: trades,
      );
      addTearDown(mine.dispose);
      expect(mine.canCreate, isFalse);
      expect(mine.requests, isEmpty);
    });
  });

  group('WorkRequestFormController', () {
    late WorkRequestFormController form;
    final now = DateTime.utc(2026, 11, 24, 9);

    setUp(() {
      form = WorkRequestFormController(
        workRequestRepository: requests,
        tradeRepository: trades,
        userRepository: users,
        createId: () => 'request-created',
        now: () => now,
      );
    });

    tearDown(() => form.dispose());

    void fill() {
      form.updateTitle('Poser une étagère');
      form.updateDescription(
        'Étagère murale en chêne de 1,20 m dans le salon.',
      );
      form.toggleTrade('trade-carpentry');
    }

    test('offers every trade and pre-fills the customer location', () {
      expect(form.trades, hasLength(MockData.trades.length));
      expect(form.city, MockData.customer.adress.city);
      expect(form.postalCode, MockData.customer.adress.postalCode);
      expect(form.isPublished, isFalse);
    });

    test('publishing saves an open request for the current customer', () {
      var notifications = 0;
      form.addListener(() => notifications++);
      fill();
      form.chooseUrgency(WorkUrgency.scheduled);
      form.updateMinimumBudget('150');
      form.updateMaximumBudget(' 300 ');
      form.publish();

      final saved = requests.getById('request-created')!;
      expect(form.published, same(saved));
      expect(saved.customerId, MockData.customer.id);
      expect(saved.status, WorkRequestStatus.published);
      expect(saved.urgency, WorkUrgency.scheduled);
      expect(saved.budget!.maximum, Money(minorUnits: 30000));
      expect(saved.createdAt, now);
      expect(notifications, 3);

      form.publish();
      expect(notifications, 3);
    });

    test('an incomplete draft is neither saved nor marked published', () {
      form.updateTitle('Poser une étagère');
      expect(form.publish, throwsStateError);
      expect(requests.getById('request-created'), isNull);
      expect(form.isPublished, isFalse);
    });

    test('a new customer\'s request is visible to artisans', () {
      users.setUser(
        User(
          id: 'user-new',
          firstName: 'Nina',
          lastName: 'Petit',
          email: '',
          birthDateInMillisFromEpoch: 0,
          adress: const Adress(
            street: '',
            city: 'Vincennes',
            postalCode: '94300',
            country: 'France',
          ),
          createdAt: now,
        ),
      );
      final newcomerForm = WorkRequestFormController(
        workRequestRepository: requests,
        tradeRepository: trades,
        userRepository: users,
        createId: () => 'request-nina',
        now: () => now,
      );
      addTearDown(newcomerForm.dispose);
      newcomerForm.updateTitle('Changer une prise');
      newcomerForm.updateDescription(
        'Prise électrique arrachée dans la cuisine.',
      );
      newcomerForm.toggleTrade('trade-electricity');
      newcomerForm.publish();

      final board = WorkRequestBoardController(
        workRequestRepository: requests,
        tradeRepository: trades,
      );
      addTearDown(board.dispose);
      expect(board.requests.first.id, 'request-nina');
      expect(board.requests.first.adress.city, 'Vincennes');
    });
  });

  group('WorkRequestDetailsController', () {
    test('loads a request with its trade names and ownership', () {
      final details = WorkRequestDetailsController(
        requestId: 'request-8',
        workRequestRepository: requests,
        tradeRepository: trades,
        userRepository: users,
      );
      expect(details.request!.title, contains('salle de bain'));
      expect(details.tradeNames, ['Plomberie', 'Carrelage']);
      expect(details.isOwnRequest, isFalse);

      final own = WorkRequestDetailsController(
        requestId: 'request-9',
        workRequestRepository: requests,
        tradeRepository: trades,
        userRepository: users,
      );
      expect(own.isOwnRequest, isTrue);
    });

    test('returns no request for an unknown id', () {
      final details = WorkRequestDetailsController(
        requestId: 'missing',
        workRequestRepository: requests,
        tradeRepository: trades,
        userRepository: users,
      );
      expect(details.request, isNull);
      expect(details.tradeNames, isEmpty);
      expect(details.isOwnRequest, isFalse);
    });
  });
}
