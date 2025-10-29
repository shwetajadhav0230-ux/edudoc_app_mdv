import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  // Retaining the 'isTotal' name as it clearly defines the intent
  // (i.e., this row represents the stylized total amount).
  final bool isTotal;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false, // Set default value
  });

  @override
  Widget build(BuildContext context) {
    // The core logic (bolding and color application) is handled by the 'isTotal' flag.
    final fontWeight = isTotal ? FontWeight.bold : FontWeight.normal;
    final valueColor = isTotal ? Theme.of(context).colorScheme.tertiary : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: fontWeight)),
          Text(
            value,
            style: TextStyle(
              fontWeight: fontWeight,
              // Apply tertiary color only for the total row
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
