import 'package:esme26/application/work_request_board_controller.dart';
import 'package:esme26/data/repositories/trade_repository.dart' as data;
import 'package:esme26/data/repositories/work_request_repository.dart' as data;
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_board_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Artisans browse the open work requests.
class WorkRequestBoardPage extends StatefulWidget {
  final WorkRequestRepository? workRequestRepository;
  final TradeRepository? tradeRepository;

  const WorkRequestBoardPage({
    super.key,
    this.workRequestRepository,
    this.tradeRepository,
  });

  @override
  State<WorkRequestBoardPage> createState() => _WorkRequestBoardPageState();
}

class _WorkRequestBoardPageState extends State<WorkRequestBoardPage> {
  late final WorkRequestBoardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkRequestBoardController(
      workRequestRepository:
          widget.workRequestRepository ?? data.WorkRequestRepository.instance,
      tradeRepository: widget.tradeRepository ?? data.TradeRepository.instance,
    );
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
      builder: (context, _) =>
          WorkRequestBoardView(controller: _controller, onOpen: _open),
    );
  }
}
