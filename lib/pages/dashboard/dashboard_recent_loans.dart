import 'package:flutter/material.dart';

class DashboardRecentLoans {
  static Widget buildRecentLoansSection(List<dynamic> recentLoans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Loans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: recentLoans.map((loan) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      loan['status'] == 'Active' ? Colors.green : Colors.orange,
                  child: Icon(
                    loan['status'] == 'Active' ? Icons.check : Icons.pending,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(loan['memberName']),
                subtitle: Text('Date: ${loan['date']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${loan['amount'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      loan['status'],
                      style: TextStyle(
                        fontSize: 12,
                        color: loan['status'] == 'Active'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
