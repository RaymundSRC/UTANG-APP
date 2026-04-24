import 'package:flutter/material.dart';
import '../members/member_input_fields.dart';

/// Dialog for adding a new loan with borrower details.
/// Shows a live "available fund" indicator that updates as the user types.
class AddLoanDialog extends StatefulWidget {
  /// The total fund available before this loan.
  final double availableFund;

  const AddLoanDialog({super.key, required this.availableFund});

  @override
  State<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<AddLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final borrowerNameController = TextEditingController();
  final requestedAmountController = TextEditingController();
  DateTime? selectedDate;

  double _enteredAmount = 0.0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    requestedAmountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {
      _enteredAmount =
          double.tryParse(requestedAmountController.text) ?? 0.0;
    });
  }

  @override
  void dispose() {
    requestedAmountController.removeListener(_onAmountChanged);
    borrowerNameController.dispose();
    requestedAmountController.dispose();
    super.dispose();
  }

  double get _remainingFund => widget.availableFund - _enteredAmount;

  /// 0.0 = nothing used, 1.0 = 100% used
  double get _usageRatio {
    if (widget.availableFund <= 0) return 1.0;
    return (_enteredAmount / widget.availableFund).clamp(0.0, 1.0);
  }

  Color get _balanceColor {
    if (_remainingFund < 0) return Colors.red.shade600;
    if (_usageRatio > 0.8) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  Color get _barColor {
    if (_remainingFund < 0) return Colors.red.shade400;
    if (_usageRatio > 0.8) return Colors.amber.shade400;
    return Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add New Loan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Available Fund Card ──
                _buildFundCard(),
                const SizedBox(height: 20),

                // Borrower Full Name
                CustomTextField(
                  controller: borrowerNameController,
                  label: 'Borrower Full Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter borrower\'s full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Requested Amount
                CustomTextField(
                  controller: requestedAmountController,
                  label: 'Requested Amount',
                  icon: Icons.money,
                  prefixText: '₱',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter requested amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Borrowed
                CustomDateField(
                  selectedDate: selectedDate,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Save Loan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The available-fund visual card with progress bar.
  Widget _buildFundCard() {
    final remaining = _remainingFund;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade50,
            Colors.blueGrey.shade100.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Fund header
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  size: 18, color: Colors.blueGrey.shade600),
              const SizedBox(width: 6),
              Text(
                'Available Fund',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '₱${widget.availableFund.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 12),

          // Progress bar showing usage
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _usageRatio,
              minHeight: 8,
              backgroundColor: Colors.blueGrey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 10),

          // Remaining balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining after loan:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade500,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _balanceColor,
                ),
                child: Text(
                  '₱${remaining.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),

          // Warning if over budget
          if (remaining < 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Loan exceeds available fund',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'borrowerName': borrowerNameController.text.trim(),
        'requestedAmount':
            double.tryParse(requestedAmountController.text) ?? 0,
        'dateBorrowed': selectedDate,
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
