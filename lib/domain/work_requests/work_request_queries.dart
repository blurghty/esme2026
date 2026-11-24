import 'package:esme26/domain/models/work_request.dart';

/// Pure selections over work requests, newest first.
abstract final class WorkRequestQueries {
  /// Requests published and still open to artisans.
  static List<WorkRequest> open(Iterable<WorkRequest> requests) => _newestFirst(
    requests.where((request) => request.status == WorkRequestStatus.published),
  );

  /// Every request created by [customerId], whatever its status.
  static List<WorkRequest> ofCustomer(
    Iterable<WorkRequest> requests,
    String customerId,
  ) => _newestFirst(
    requests.where((request) => request.customerId == customerId),
  );

  /// Requests still in progress for the customer (open or assigned).
  static bool isActive(WorkRequest request) =>
      request.status == WorkRequestStatus.published ||
      request.status == WorkRequestStatus.assigned;

  static List<WorkRequest> _newestFirst(Iterable<WorkRequest> requests) =>
      List.unmodifiable(
        requests.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
}
