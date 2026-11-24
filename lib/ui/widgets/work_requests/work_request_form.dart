import 'package:esme26/application/work_request_form_controller.dart';
import 'package:esme26/domain/models/work_request.dart';
import 'package:esme26/domain/work_requests/work_request_draft.dart';
import 'package:esme26/ui/widgets/work_requests/work_request_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form used by a customer to describe a project to artisans.
class WorkRequestForm extends StatefulWidget {
  final WorkRequestFormController controller;
  final VoidCallback onSubmit;

  const WorkRequestForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  State<WorkRequestForm> createState() => _WorkRequestFormState();
}

class _WorkRequestFormState extends State<WorkRequestForm> {
  static const _required = 'Ce champ est obligatoire.';
  final _formKey = GlobalKey<FormState>();

  /// Errors are refreshed while typing once a submission was attempted.
  var _submitted = false;

  WorkRequestFormController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Décrivez votre projet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Votre demande sera visible par les artisans, qui pourront '
            'vous proposer un devis.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _controller.title,
            decoration: const InputDecoration(
              labelText: 'Titre du projet',
              hintText: 'Ex. : Repeindre la chambre',
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            onChanged: _controller.updateTitle,
            validator: (value) => WorkRequestDraft.isValidTitle(value ?? '')
                ? null
                : 'Au moins ${WorkRequestDraft.minTitleLength} caractères.',
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _controller.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Surface, état actuel, matériaux souhaités…',
              alignLabelWithHint: true,
            ),
            textCapitalization: TextCapitalization.sentences,
            minLines: 4,
            maxLines: 8,
            maxLength: 1000,
            onChanged: _controller.updateDescription,
            validator: (value) =>
                WorkRequestDraft.isValidDescription(value ?? '')
                ? null
                : 'Au moins ${WorkRequestDraft.minDescriptionLength} '
                      'caractères pour aider les artisans.',
          ),
          const SizedBox(height: 16),
          _SectionTitle('Corps de métier'),
          FormField<Set<String>>(
            validator: (_) => _controller.tradeIds.isEmpty
                ? 'Choisissez au moins un corps de métier.'
                : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final trade in _controller.trades)
                      FilterChip(
                        label: Text(trade.name),
                        selected: _controller.tradeIds.contains(trade.id),
                        onSelected: (_) {
                          _controller.toggleTrade(trade.id);
                          field.didChange(_controller.tradeIds);
                        },
                      ),
                  ],
                ),
                if (field.errorText case final error?)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Type de logement'),
          SegmentedButton<PropertyType>(
            segments: [
              for (final type in PropertyType.values)
                ButtonSegment(value: type, label: Text(type.label)),
            ],
            selected: {_controller.propertyType},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                _controller.choosePropertyType(selection.single),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Délai souhaité'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final urgency in WorkUrgency.values)
                ChoiceChip(
                  label: Text(urgency.label),
                  selected: _controller.urgency == urgency,
                  onSelected: (_) => _controller.chooseUrgency(urgency),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_controller.urgency.hint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          _SectionTitle('Adresse des travaux'),
          Text(
            'Seuls la ville et le code postal sont visibles par les artisans.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _controller.street,
            decoration: const InputDecoration(
              labelText: 'Adresse (facultatif)',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: _controller.updateStreet,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _controller.postalCode,
            decoration: const InputDecoration(labelText: 'Code postal'),
            keyboardType: TextInputType.number,
            onChanged: _controller.updatePostalCode,
            validator: _requiredField,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _controller.city,
            decoration: const InputDecoration(labelText: 'Ville'),
            textCapitalization: TextCapitalization.words,
            onChanged: _controller.updateCity,
            validator: _requiredField,
          ),
          const SizedBox(height: 24),
          _SectionTitle('Budget estimé (facultatif)'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _controller.minimumBudget?.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Minimum',
                    suffixText: '€',
                    errorMaxLines: 3,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: _amountFormatters,
                  onChanged: _controller.updateMinimumBudget,
                  validator: (_) => _budgetError(forMinimum: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _controller.maximumBudget?.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Maximum',
                    suffixText: '€',
                    errorMaxLines: 3,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: _amountFormatters,
                  onChanged: _controller.updateMaximumBudget,
                  validator: (_) => _budgetError(forMinimum: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              setState(() => _submitted = true);
              if (_formKey.currentState!.validate()) widget.onSubmit();
            },
            icon: const Icon(Icons.send_outlined),
            label: const Text('Publier ma demande'),
          ),
        ],
      ),
    );
  }

  static final _amountFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(7),
  ];

  String? _requiredField(String? value) =>
      WorkRequestDraft.isFilled(value ?? '') ? null : _required;

  String? _budgetError({required bool forMinimum}) {
    final minimum = _controller.minimumBudget;
    final maximum = _controller.maximumBudget;
    final amount = forMinimum ? minimum : maximum;
    return switch (WorkRequestDraft.checkBudget(minimum, maximum)) {
      BudgetIssue.incomplete when amount == null =>
        'Indiquez aussi ce montant.',
      BudgetIssue.notPositive when amount != null && amount <= 0 =>
        'Le montant doit être positif.',
      BudgetIssue.inverted when !forMinimum =>
        'Doit être supérieur au minimum.',
      _ => null,
    };
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
