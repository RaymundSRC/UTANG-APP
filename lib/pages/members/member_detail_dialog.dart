import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'members_profile.dart';
import 'edit_member_dialog.dart';

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
  double _totalContribution = 0.0;
  double _totalPenalties = 0.0;
  double _remainingBalance = 0.0;

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

      setState(() {
        _totalContribution = initialAmount;
        _totalPenalties =
            0.0; // Can be calculated from penalties table if exists
        _remainingBalance = targetAmount - initialAmount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
                              'Total Contribution',
                              _totalContribution,
                              Colors.blue.shade700,
                              Icons.account_balance_wallet,
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
