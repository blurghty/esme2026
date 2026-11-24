import 'package:esme26/application/customer_work_requests_controller.dart';
import 'package:esme26/data/repositories/trade_repository.dart' as data;
import 'package:esme26/data/repositories/user_repository.dart' as data;
import 'package:esme26/data/repositories/work_request_repository.dart' as data;
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/ui/widgets/work_requests/customer_work_requests_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Customers follow their own work requests and create new ones.
class CustomerWorkRequestsPage extends StatefulWidget {
  final UserRepository? userRepository;
  final WorkRequestRepository? workRequestRepository;
  final TradeRepository? tradeRepository;

  const CustomerWorkRequestsPage({
    super.key,
    this.userRepository,
    this.workRequestRepository,
    this.tradeRepository,
  });

  @override
  State<CustomerWorkRequestsPage> createState() =>
      _CustomerWorkRequestsPageState();
}

class _CustomerWorkRequestsPageState extends State<CustomerWorkRequestsPage> {
  late final CustomerWorkRequestsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerWorkRequestsController(
      workRequestRepository:
          widget.workRequestRepository ?? data.WorkRequestRepository.instance,
      userRepository: widget.userRepository ?? data.UserRepository.instance,
      tradeRepository: widget.tradeRepository ?? data.TradeRepository.instance,
    );
  }

  Future<void> _create() async {
    final published = await context.push<bool>('/requests/new');
    if (!mounted) return;
    _controller.refresh();
    if (published ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre demande a été publiée.')),
      );
    }
  }

  Future<void> _open(String requestId) async {
    await context.push('/requests/${Uri.encodeComponent(requestId)}');
    if (mounted) _controller.refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => CustomerWorkRequestsView(
        controller: _controller,
        onOpen: _open,
        onCreate: _create,
      ),
    );
  }
}
