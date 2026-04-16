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
          'Total Fund',
          '₱${(data['totalFund'] ?? 0).toStringAsFixed(2)}',
          Icons.account_balance,
          Colors.blue,
        ),
        _buildMetricCard(
          'Available Cash',
          '₱${(data['availableCash'] ?? 0).toStringAsFixed(2)}',
          Icons.money,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Loan Out',
          '₱${(data['totalLoanOut'] ?? 0).toStringAsFixed(2)}',
          Icons.account_balance,
          Colors.orange,
        ),
        _buildMetricCard(
          'Target Returns',
          '₱${(data['targetReturns'] ?? 0).toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.purple,
        ),
        _buildMetricCard(
          'Vault Liquid Cash',
          '₱${(data['vaultLiquidCash'] ?? 0).toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.teal,
        ),
        _buildMetricCard(
          'Unpaid Balances',
          '₱${(data['unpaidBalances'] ?? 0).toStringAsFixed(2)}',
          Icons.money_off,
          Colors.red,
        ),
        _buildMetricCard(
          'Generated Interest',
          '₱${(data['generatedInterest'] ?? 0).toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.amber,
        ),
        _buildMetricCard(
          'Generated Penalties',
          '₱${(data['generatedPenalties'] ?? 0).toStringAsFixed(2)}',
          Icons.gavel,
          Colors.deepOrange,
        ),
        _buildMetricCard(
          'Paid Interest',
          '₱${(data['paidInterest'] ?? 0).toStringAsFixed(2)}',
          Icons.paid,
          Colors.green,
        ),
        _buildMetricCard(
          'Paid Penalties',
          '₱${(data['paidPenalties'] ?? 0).toStringAsFixed(2)}',
          Icons.check_circle,
          Colors.lightGreen,
        ),
        _buildMetricCard(
          'Unpaid Interest',
          '₱${(data['unpaidInterest'] ?? 0).toStringAsFixed(2)}',
          Icons.money_off,
          Colors.redAccent,
        ),
        _buildMetricCard(
          'Overdue Penalties',
          '₱${(data['overduePenalties'] ?? 0).toStringAsFixed(2)}',
          Icons.warning,
          Colors.pink,
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
