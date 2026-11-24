import 'package:esme26/application/work_request_form_controller.dart';
import 'package:esme26/data/repositories/trade_repository.dart' as data;
import 'package:esme26/data/repositories/user_repository.dart' as data;
import 'package:esme26/data/repositories/work_request_repository.dart' as data;
import 'package:esme26/domain/repositories/trade_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/domain/repositories/work_request_repository.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A customer describes a new project; pops `true` once it is published.
class CreateWorkRequestPage extends StatefulWidget {
  final UserRepository? userRepository;
  final WorkRequestRepository? workRequestRepository;
  final TradeRepository? tradeRepository;

  const CreateWorkRequestPage({
    super.key,
    this.userRepository,
    this.workRequestRepository,
    this.tradeRepository,
  });

  @override
  State<CreateWorkRequestPage> createState() => _CreateWorkRequestPageState();
}

class _CreateWorkRequestPageState extends State<CreateWorkRequestPage> {
  late final WorkRequestFormController _controller;
  var _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = WorkRequestFormController(
      workRequestRepository:
          widget.workRequestRepository ?? data.WorkRequestRepository.instance,
      tradeRepository: widget.tradeRepository ?? data.TradeRepository.instance,
      userRepository: widget.userRepository ?? data.UserRepository.instance,
    );
    _controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (_controller.isPublished && !_hasNavigated) {
      _hasNavigated = true;
      context.pop(true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => WorkRequestForm(
                  controller: _controller,
                  onSubmit: _controller.publish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
