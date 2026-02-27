import 'package:flutter/material.dart';

/// Radio-button variation selector matching the desktop app layout.
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

  Widget _buildRadioItem(int index) {
    final label = index == 0 ? 'Default' : 'Variation $index';
    return GestureDetector(
      onTap: () => onChanged(index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<int>(
            value: index,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: selectedIndex,
      onChanged: (value) => onChanged(value ?? 0),
      child: Column(
        children: [
          // Default on its own row
          _buildRadioItem(0),
          const SizedBox(height: 6),
          // Variations 1-3 on the next row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i < count; i++) ...[
                if (i > 1) const SizedBox(width: 18),
                _buildRadioItem(i),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
