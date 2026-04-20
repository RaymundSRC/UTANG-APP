import 'package:flutter/material.dart';

class AddLoanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddLoanButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Add Loan'),
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
