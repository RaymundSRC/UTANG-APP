import 'package:flutter/material.dart';
import 'members_profile.dart';
import 'member_penalties_service.dart';
import 'penalty_month_selector.dart';

class MemberPaymentForm extends StatefulWidget {
  final Member member;
  final VoidCallback? onPaymentSaved;

  const MemberPaymentForm({
    super.key,
    required this.member,
    this.onPaymentSaved,
  });

  @override
  State<MemberPaymentForm> createState() => _MemberPaymentFormState();
}

class _MemberPaymentFormState extends State<MemberPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  String selectedPaymentType = 'contribution';
  DateTime? selectedDate;
  
  List<PenaltyItem> _pendingPenalties = [];
  bool _isLoadingPenalties = false;
  String _selectedMonthsString = '';
  double _lastSelectedPenaltyAmount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPenalties();
  }

  Future<void> _fetchPenalties() async {
    setState(() => _isLoadingPenalties = true);
    final penalties = await MemberPenaltiesService.calculatePendingPenalties(widget.member);
    if (mounted) {
      setState(() {
        _pendingPenalties = penalties;
        _isLoadingPenalties = false;
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                      Icons.payment,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Payment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Type Selection
              const Text(
                'Payment Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Contribution'),
                      value: 'contribution',
                      groupValue: selectedPaymentType,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentType = value!;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Penalty'),
                      value: 'penalty',
                      groupValue: selectedPaymentType,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentType = value!;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Remaining Balance Display (for contribution)
              if (selectedPaymentType == 'contribution')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Remaining balance to reach target: ₱${(widget.member.targetAmount - widget.member.initialAmount).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (selectedPaymentType == 'contribution')
                const SizedBox(height: 16),

              if (selectedPaymentType == 'penalty')
                _isLoadingPenalties 
                    ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                    : PenaltyMonthSelector(
                        pendingPenalties: _pendingPenalties,
                        onSelectionChanged: (selectedItems, totalAmount) {
                          setState(() {
                            // Automatically prefix amount if they haven't manually tweaked it (optional)
                            // Here we just overwrite to help them, but they can still override it
                            _selectedMonthsString = selectedItems.map((p) => p.monthName).join(', ');
                            amountController.text = totalAmount > 0 ? totalAmount.toStringAsFixed(2) : '';
                            _lastSelectedPenaltyAmount = totalAmount;
                          });
                        },
                      ),
              if (selectedPaymentType == 'penalty')
                const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₱',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.tryParse(value)! <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Date',
                          style: TextStyle(
                            color: selectedDate != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a date'),
                              ),
                            );
                            return;
                          }
                          if (selectedPaymentType == 'penalty' && _selectedMonthsString.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select at least one penalty month to pay for.'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context, {
                            'amount':
                                double.tryParse(amountController.text) ?? 0,
                            'payment_type': selectedPaymentType,
                            'date': selectedDate,
                            'selected_months': selectedPaymentType == 'penalty' ? _selectedMonthsString : null,
                          });

                          if (widget.onPaymentSaved != null) {
                            widget.onPaymentSaved!();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
