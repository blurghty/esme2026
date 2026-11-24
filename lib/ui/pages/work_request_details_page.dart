import 'package:esme26/application/work_request_details_controller.dart';
import 'package:esme26/data/repositories/trade_repository.dart' as data;
import 'package:esme26/data/repositories/user_repository.dart' as data;
import 'package:esme26/data/repositories/work_request_repository.dart' as data;
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_details_view.dart';
import 'package:flutter/material.dart';

class WorkRequestDetailsPage extends StatefulWidget {
  final String requestId;
  final UserRepository? userRepository;
  final WorkRequestRepository? workRequestRepository;
  final TradeRepository? tradeRepository;

  const WorkRequestDetailsPage({
    super.key,
    required this.requestId,
    this.userRepository,
    this.workRequestRepository,
    this.tradeRepository,
  });

  @override
  State<WorkRequestDetailsPage> createState() => _WorkRequestDetailsPageState();
}

class _WorkRequestDetailsPageState extends State<WorkRequestDetailsPage> {
  late final WorkRequestDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkRequestDetailsController(
      requestId: widget.requestId,
      workRequestRepository:
          widget.workRequestRepository ?? data.WorkRequestRepository.instance,
      tradeRepository: widget.tradeRepository ?? data.TradeRepository.instance,
      userRepository: widget.userRepository ?? data.UserRepository.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WorkRequestDetailsView(
      request: _controller.request,
      tradeNames: _controller.tradeNames,
      isOwnRequest: _controller.isOwnRequest,
    );
  }
}
