import 'package:flutter/material.dart';
import 'member_penalties_service.dart';

class ShowPenaltyDialog extends StatelessWidget {
  final List<PenaltyItem> pendingPenalties;

  const ShowPenaltyDialog({
    super.key,
    required this.pendingPenalties,
  });

  @override
  Widget build(BuildContext context) {
    // Separate due and upcoming penalties
    final duePenalties = pendingPenalties.where((p) => !p.isUpcoming).toList();
    final upcomingPenalties = pendingPenalties.where((p) => p.isUpcoming).toList();

    double grossPenalty = duePenalties.fold(0.0, (sum, item) => sum + item.penaltyAmount);

    return AlertDialog(
      title: const Text('Penalty Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Due Penalties
              const Text(
                'Current Due Penalties',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (duePenalties.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No penalties currently due.',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: duePenalties.length,
                  itemBuilder: (context, index) {
                    final p = duePenalties[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.description),
                      trailing: Text(
                        '₱${p.penaltyAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    );
                  },
                ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Due Penalty:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '₱${grossPenalty.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16),
                  ),
                ],
              ),

              // Upcoming Expected Penalty
              if (upcomingPenalties.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Upcoming Penalty Overview',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This penalty will apply if the remaining balance is not paid before the next grace period ends:',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                      ),
                      const SizedBox(height: 8),
                      ...upcomingPenalties.map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    p.description,
                                    style: TextStyle(color: Colors.blue.shade900),
                                  ),
                                ),
                                Text(
                                  '₱${p.penaltyAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
