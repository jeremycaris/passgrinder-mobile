import 'package:flutter/material.dart';

class VariationSelector extends StatelessWidget {
  final int count;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const VariationSelector({
    super.key,
    required this.count,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variation',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(count, (index) {
            final isSelected = index == selectedIndex;
            return ChoiceChip(
              label: Text(index == 0 ? 'Default' : 'Variation $index'),
              selected: isSelected,
              onSelected: (_) => onChanged(index),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            );
          }),
        ),
      ],
    );
  }
}
