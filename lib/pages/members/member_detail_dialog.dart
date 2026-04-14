import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'members_profile.dart';
import 'edit_member_dialog.dart';
import 'member_payment_form.dart';
import 'payment_history_dialog.dart';
import 'member_penalties_service.dart';
import 'show_penalty_dialog.dart';

class MemberDetailDialog extends StatefulWidget {
  final Member member;

  const MemberDetailDialog({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  late final SupabaseClient supabase;
  bool _isLoading = false;

  // Financial data
  double _targetAmount = 0.0;
  double _initialDeposit = 0.0;
  double _totalContribution = 0.0;
  double _totalPenalties = 0.0;
  double _remainingBalance = 0.0;
  List<PenaltyItem> _pendingPenalties = [];

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _calculateFinancialSummary();
  }

  Future<bool> _updateMember(Map<String, dynamic> updatedData) async {
    try {
      final memberData = {
        'fullname': updatedData['fullName'],
        'initial_amount': updatedData['amount'],
        'target_amount': updatedData['targetAmount'],
        'select_date': updatedData['select_date']?.toIso8601String(),
      };

      await supabase
          .from('members')
          .update(memberData)
          .eq('id', widget.member.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Member updated successfully')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating member: $e')),
        );
      }
      return false;
    }
  }

  Future<bool> _addPayment(Map<String, dynamic> paymentData) async {
    try {
      final paymentRecord = {
        'member_id': widget.member.id,
        'amount': paymentData['amount'],
        'payment_type': paymentData['payment_type'],
        'date': paymentData['date']?.toIso8601String(),
        if (paymentData['selected_months'] != null)
          'selected_months': paymentData['selected_months'],
      };

      await supabase.from('member_payments').insert(paymentRecord);

      // If it's a contribution, update the member's initial_amount
      if (paymentData['payment_type'] == 'contribution') {
        final currentMember = await supabase
            .from('members')
            .select()
            .eq('id', widget.member.id!)
            .single();

        final currentInitialAmount =
            (currentMember['initial_amount'] as num?)?.toDouble() ?? 0.0;
        final contributionAmount = (paymentData['amount'] as num).toDouble();
        final newInitialAmount = currentInitialAmount + contributionAmount;

        await supabase.from('members').update({
          'initial_amount': newInitialAmount,
        }).eq('id', widget.member.id!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment added successfully')),
        );
      }

      // Recalculate financial summary
      await _calculateFinancialSummary();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding payment: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _calculateFinancialSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch member's data from members table
      final memberData = await supabase
          .from('members')
          .select()
          .eq('id', widget.member.id!)
          .single();

      // Calculate values based on member data
      final initialAmount =
          (memberData['initial_amount'] as num?)?.toDouble() ?? 0.0;
      final targetAmount =
          (memberData['target_amount'] as num?)?.toDouble() ?? 0.0;

      // Fetch payment data from member_payments table
      final payments = await supabase
          .from('member_payments')
          .select()
          .eq('member_id', widget.member.id!);

      // Calculate total penalties and contributions from payments
      double totalPaidPenalties = 0.0;
      double totalContributions = 0.0;

      for (var payment in payments) {
        final amount = (payment['amount'] as num).toDouble();
        final paymentType = payment['payment_type'] as String;

        if (paymentType == 'penalty') {
          totalPaidPenalties += amount;
        } else if (paymentType == 'contribution') {
          totalContributions += amount;
        }
      }

      // Dynamically calculate net penalties (MemberPenaltiesService already deducts totalPaidPenalties)
      final pendingPenalties =
          await MemberPenaltiesService.calculatePendingPenalties(widget.member);
      _pendingPenalties = pendingPenalties;

      double currentOwedPenalties = pendingPenalties
          .where((p) => !p.isUpcoming)
          .fold(0.0, (sum, item) => sum + item.penaltyAmount);

      if (mounted) {
        setState(() {
          _targetAmount = targetAmount;
          _initialDeposit = initialAmount;
          _totalContribution = initialAmount;
          _totalPenalties = currentOwedPenalties;
          _remainingBalance = targetAmount - initialAmount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPenaltyPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => ShowPenaltyDialog(
        pendingPenalties: _pendingPenalties,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade200,
                                  Colors.purple.shade200,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Text(
                                widget.member.fullName.isNotEmpty
                                    ? widget.member.fullName[0].toUpperCase()
                                    : 'M',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.member.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                if (widget.member.date != null)
                                  Text(
                                    'Joined ${widget.member.date!.day}/${widget.member.date!.month}/${widget.member.date!.year}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Financial Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildFinancialRow(
                              'Target Amount',
                              _targetAmount,
                              Colors.blue.shade700,
                              Icons.flag,
                            ),
                            const SizedBox(height: 16),
                            _buildFinancialRow(
                              'Initial Deposit',
                              _initialDeposit,
                              Colors.blue.shade700,
                              Icons.account_balance_wallet,
                            ),
                            const SizedBox(height: 16),
                            _buildFinancialRow(
                              'Total Contributions',
                              _totalContribution,
                              Colors.green.shade700,
                              Icons.add_circle,
                            ),
                            const SizedBox(height: 16),
                            _buildFinancialRow(
                              'Total Penalties',
                              _totalPenalties,
                              Colors.red.shade700,
                              Icons.warning,
                            ),
                            const SizedBox(height: 16),
                            _buildFinancialRow(
                              'Remaining Balance',
                              _remainingBalance,
                              _remainingBalance > 0
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              Icons.trending_up,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result =
                                    await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) =>
                                      EditMemberDialog(member: widget.member),
                                );

                                if (result != null) {
                                  // Update member in Supabase
                                  final success = await _updateMember(result);
                                  if (success) {
                                    // Recalculate financial summary
                                    await _calculateFinancialSummary();
                                    // Return 'edit' to trigger refresh in parent
                                    if (mounted) {
                                      Navigator.pop(context, 'edit');
                                    }
                                  }
                                }
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Member'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Payment History Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => PaymentHistoryDialog(
                                memberId: widget.member.id!,
                              ),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('View Payment History'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Add Payment Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result =
                                await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => MemberPaymentForm(
                                member: widget.member,
                                onPaymentSaved: () {
                                  // This callback is called after payment is saved
                                },
                              ),
                            );

                            if (result != null) {
                              final success = await _addPayment(result);
                              if (success) {
                                // Return 'payment' to trigger refresh in parent
                                if (mounted) {
                                  Navigator.pop(context, 'payment');
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Add Payment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Show Penalty Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showPenaltyPreviewDialog,
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Show Penalty'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
      String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
