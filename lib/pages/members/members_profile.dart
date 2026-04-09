import 'package:flutter/material.dart';
import 'member_detail_dialog.dart';

class Member {
  final String? id;
  final String fullName;
  final double initialAmount;
  final double targetAmount;
  final DateTime? date;

  Member({
    this.id,
    required this.fullName,
    required this.initialAmount,
    required this.targetAmount,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullName,
      'initial_amount': initialAmount,
      'target_amount': targetAmount,
      'select_date': date?.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id']?.toString(),
      fullName: map['fullname'] ?? '',
      initialAmount: (map['initial_amount'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
      date: map['select_date'] != null
          ? DateTime.parse(map['select_date'])
          : null,
    );
  }
}

class MemberCard extends StatelessWidget {
  final Member member;
  final int index;
  final Function(String, int) onDelete;
  final VoidCallback? onEdit;

  const MemberCard({
    super.key,
    required this.member,
    required this.index,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress if possible
    double progress = 0.0;
    if (member.targetAmount > 0) {
      progress = (member.initialAmount / member.targetAmount).clamp(0.0, 1.0);
    }

    return InkWell(
      onTap: () => _showMemberDetail(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Top Accent Line
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade300],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, top: 10, right: 4, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade200,
                                Colors.purple.shade200
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Text(
                              member.fullName.isNotEmpty
                                  ? member.fullName[0].toUpperCase()
                                  : 'M',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (member.date != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 10, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Joined ${member.date!.day}/${member.date!.month}/${member.date!.year}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz,
                              color: Colors.grey.shade600, size: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'delete') {
                              onDelete(member.id!, index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete Member',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Financial info row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildFinancialColumn(
                            'Initial Deposit',
                            member.initialAmount,
                            Colors.blue.shade600,
                          ),
                          if (member.targetAmount > 0)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 4,
                                        backgroundColor: Colors.blue.shade50,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blue.shade400),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          _buildFinancialColumn(
                            'Target Goal',
                            member.targetAmount,
                            Colors.purple.shade600,
                            isRightAligned: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemberDetailDialog(member: member),
    ).then((result) {
      if (result == 'edit' && onEdit != null) {
        onEdit!();
      }
    });
  }

  Widget _buildFinancialColumn(String label, double amount, Color color,
      {bool isRightAligned = false}) {
    return Column(
      crossAxisAlignment:
          isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
