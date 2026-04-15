import 'package:flutter/material.dart';
import 'member_penalties_service.dart';

class PenaltyMonthSelector extends StatefulWidget {
  final List<PenaltyItem> pendingPenalties;
  final Function(List<PenaltyItem>, double) onSelectionChanged;

  const PenaltyMonthSelector({
    super.key,
    required this.pendingPenalties,
    required this.onSelectionChanged,
  });

  @override
  State<PenaltyMonthSelector> createState() => _PenaltyMonthSelectorState();
}

class _PenaltyMonthSelectorState extends State<PenaltyMonthSelector> {
  late List<PenaltyItem> _duePenalties;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // Filter to only include actual due penalties (exclude expected/upcoming)
    _duePenalties =
        widget.pendingPenalties.where((p) => !p.isUpcoming).toList();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        // If unchecking, uncheck this and all subsequent months
        _selectedIndices.removeWhere((i) => i >= index);
      } else {
        // If checking, check this and all prior months (enforcing chronological order)
        for (int i = 0; i <= index; i++) {
          _selectedIndices.add(i);
        }
      }
    });

    _notifyParent();
  }

  void _notifyParent() {
    final selectedItems =
        _selectedIndices.map((i) => _duePenalties[i]).toList();
    final totalAmount =
        selectedItems.fold(0.0, (sum, item) => sum + item.penaltyAmount);
    widget.onSelectionChanged(selectedItems, totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (_duePenalties.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No pending penalties due.',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Select Penalty Months',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            children: List.generate(_duePenalties.length, (index) {
              final penalty = _duePenalties[index];
              final isSelected = _selectedIndices.contains(index);

              return InkWell(
                onTap: () => _toggleSelection(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.shade50 : Colors.transparent,
                    border: index < _duePenalties.length - 1
                        ? Border(
                            bottom: BorderSide(color: Colors.grey.shade200))
                        : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) => _toggleSelection(index),
                          activeColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              penalty.monthName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.red.shade900
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              penalty.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${penalty.penaltyAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.red.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '* Selecting a month will automatically select all earlier unpaid months.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
