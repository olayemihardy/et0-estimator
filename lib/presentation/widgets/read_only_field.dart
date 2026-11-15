import 'package:flutter/material.dart';

/// A read-only labelled value (used for all inputs/intermediate results).
class ReadOnlyField extends StatelessWidget {
  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }
}
