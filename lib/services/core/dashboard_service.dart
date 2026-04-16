import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  Future<Map<String, dynamic>> getDashboardData() async {
    // This method is deprecated, use getDashboardDataWithRealFund() instead
    return await getDashboardDataWithRealFund();
  }

  Future<double> getTotalFund() async {
    return await calculateTotalFundFromMembers();
  }

  Future<void> updateTotalFund(double newAmount) async {
    // This method will need to be implemented with real database logic
    // For now, it's a placeholder for future implementation
    throw UnimplementedError('updateTotalFund needs database implementation');
  }

  Future<void> addFund(double amount) async {
    // This method will need to be implemented with real database logic
    // For now, it's a placeholder for future implementation
    throw UnimplementedError('addFund needs database implementation');
  }

  Future<void> withdrawFund(double amount) async {
    // This method will need to be implemented with real database logic
    // For now, it's a placeholder for future implementation
    throw UnimplementedError('withdrawFund needs database implementation');
  }

  // Method to refresh all dashboard data
  Future<Map<String, dynamic>> refreshDashboardData() async {
    return await getDashboardDataWithRealFund();
  }

  // Calculate Total Fund from members.target_amount column
  Future<double> calculateTotalFundFromMembers() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('members').select('target_amount');

      double totalFund = 0.0;
      for (var member in response) {
        final targetAmount =
            (member['target_amount'] as num?)?.toDouble() ?? 0.0;
        totalFund += targetAmount;
      }

      return totalFund;
    } catch (e) {
      print('Error calculating total fund from members: $e');
      rethrow;
    }
  }

  // Get dashboard data with real Total Fund from database
  Future<Map<String, dynamic>> getDashboardDataWithRealFund() async {
    try {
      final realTotalFund = await calculateTotalFundFromMembers();

      return {
        'totalFund': realTotalFund,
        'availableCash': 0.0, // To be implemented with real data
        'totalLoanOut': 0.0, // To be implemented with real data
        'targetReturns': 0.0, // To be implemented with real data
        'vaultLiquidCash': 0.0, // To be implemented with real data
        'unpaidBalances': 0.0, // To be implemented with real data
        'generatedInterest': 0.0, // To be implemented with real data
        'generatedPenalties': 0.0, // To be implemented with real data
        'paidInterest': 0.0, // To be implemented with real data
        'paidPenalties': 0.0, // To be implemented with real data
        'unpaidInterest': 0.0, // To be implemented with real data
        'overduePenalties': 0.0, // To be implemented with real data
      };
    } catch (e) {
      print('Error getting dashboard data with real fund: $e');
      rethrow;
    }
  }
}
