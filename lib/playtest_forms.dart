import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'playtest_theme.dart';

class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _form = GlobalKey<FormState>();
  String _question = '';
  String _context = '';

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    Navigator.pop(context, (_question, _context));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create new topic')),
    body: SafeArea(
      child: PlaytestFrame(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  height: 144,
                  child: TopicArt('hermit-crab'),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Main question'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength: 120,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  final length = value!.trim().characters.length;
                  return length < 10 || length > 120
                      ? 'Use 10–120 characters for your question.'
                      : null;
                },
                onSaved: (value) => _question = value!.trim(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Context (optional)',
                  alignLabelWithHint: true,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                minLines: 3,
                maxLines: 5,
                maxLength: 2000,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value!.trim().characters.length > 2000
                    ? 'Use 2,000 characters or fewer for context.'
                    : null,
                onSaved: (value) => _context = value!.trim(),
              ),
              const SizedBox(height: 10),
              const Text(
                'This topic is available during this playtest session.',
                style: TextStyle(color: textMuted),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Ngobrol'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ProposalDialog extends StatefulWidget {
  const ProposalDialog({super.key});

  @override
  State<ProposalDialog> createState() => _ProposalDialogState();
}

class _ProposalDialogState extends State<ProposalDialog> {
  final _form = GlobalKey<FormState>();
  String _from = '';
  String _to = '';
  String _rationale = '';
  bool _positive = true;

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(context, Proposal(_from, _to, _positive, _rationale));
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: AlertDialog(
      scrollable: true,
      title: const Text('Propose a causal relationship'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Cause / factor'),
            maxLength: 60,
            validator: (value) => _factorError(value!),
            onChanged: (value) => _from = value.trim(),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Effect / factor'),
            maxLength: 60,
            validator: (value) {
              final error = _factorError(value!);
              if (error != null) return error;
              return _from.toLowerCase() == value.trim().toLowerCase()
                  ? 'Choose two different factors.'
                  : null;
            },
            onChanged: (value) => _to = value.trim(),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_positive ? 'Same direction (+)' : 'Opposite (−)'),
            value: _positive,
            onChanged: (value) => setState(() => _positive = value),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Reason or evidence'),
            maxLength: 500,
            maxLines: 2,
            validator: (value) =>
                value!.trim().isEmpty ? 'Add a reason or evidence.' : null,
            onChanged: (value) => _rationale = value.trim(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Submit for review'),
        ),
      ],
    ),
  );

  String? _factorError(String value) =>
      value.trim().isEmpty ? 'Enter a factor.' : null;
}
