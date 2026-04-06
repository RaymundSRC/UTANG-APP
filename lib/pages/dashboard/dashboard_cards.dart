import 'package:flutter/material.dart';

class DashboardCards {
  static Widget buildMetricCards(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Members',
          '${data['totalMembers'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildMetricCard(
          'Active Loans',
          '${data['activeLoans'] ?? 0}',
          Icons.money,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Loan Amount',
          '₱${(data['totalLoanAmount'] ?? 0).toStringAsFixed(2)}',
          Icons.account_balance,
          Colors.orange,
        ),
        _buildMetricCard(
          'Collected Amount',
          '₱${(data['collectedAmount'] ?? 0).toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  static Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
