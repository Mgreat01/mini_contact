import 'package:flutter/material.dart';
import '../domain/contact_search.dart';

/// A selection with visible controls, usable without drag or long press.
class LabelPicker extends StatefulWidget {
  const LabelPicker({
    super.key,
    required this.title,
    required this.inputLabel,
    required this.selected,
    required this.onChanged,
    this.suggestions = const [],
  });

  final String title;
  final String inputLabel;
  final List<String> selected;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;

  @override
  State<LabelPicker> createState() => _LabelPickerState();
}

class _LabelPickerState extends State<LabelPicker> {
  final _controller = TextEditingController();
  final _custom = <String>[];

  List<String> get _options {
    final unique = <String, String>{};
    for (final label in [...widget.selected, ...widget.suggestions, ..._custom]) {
      unique.putIfAbsent(normalizeContactText(label), () => label);
    }
    return unique.values.toList();
  }

  bool _selected(String label) => widget.selected.any(
    (value) => normalizeContactText(value) == normalizeContactText(label),
  );

  void _toggle(String label, bool selected) {
    widget.onChanged([
      ...widget.selected.where(
        (value) => normalizeContactText(value) != normalizeContactText(label),
      ),
      if (selected) label,
    ]);
  }

  void _add() {
    final value = _controller.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (value.isEmpty) return;
    final matches = _options.where(
      (label) => normalizeContactText(label) == normalizeContactText(value),
    );
    final label = matches.isEmpty ? value : matches.first;
    setState(() {
      if (matches.isEmpty) _custom.add(label);
      _controller.clear();
    });
    if (!_selected(label)) _toggle(label, true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
      ),
      const SizedBox(height: 8),
      AnimatedSize(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final label in _options)
              FilterChip(
                label: Text(label),
                selected: _selected(label),
                onSelected: (selected) => _toggle(label, selected),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _controller,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _add(),
        decoration: InputDecoration(
          labelText: widget.inputLabel,
          suffixIcon: IconButton(
            tooltip: 'Ajouter : ${widget.inputLabel.toLowerCase()}',
            onPressed: _add,
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    ],
  );
}
