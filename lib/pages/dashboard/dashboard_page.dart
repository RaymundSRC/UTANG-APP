import 'package:flutter/material.dart';
import 'dashboard_cards.dart';
import 'dashboard_recent_loans.dart';
import 'dashboard_quick_actions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DashboardCards.buildMetricCards(_dashboardData),
                    const SizedBox(height: 20),
                    DashboardRecentLoans.buildRecentLoansSection(
                        _dashboardData['recentLoans'] ?? []),
                    const SizedBox(height: 20),
                    DashboardQuickActions.buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }
}
