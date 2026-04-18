import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../pages/members/members_profile.dart'; // for Member model
import '../../pages/members/member_penalties_service.dart'; // for MemberPenaltiesService

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
      final supabase = Supabase.instance.client;

      // 1. Fetch all members
      final membersResponse = await supabase.from('members').select();

      // 2. Calculate Total Fund & Unpaid Balances from members
      double realTotalFund = 0.0;
      double unpaidBalances = 0.0;

      final List<Member> members = [];
      for (var memberData in membersResponse) {
        final targetAmount =
            (memberData['target_amount'] as num?)?.toDouble() ?? 0.0;
        final initialAmount =
            (memberData['initial_amount'] as num?)?.toDouble() ?? 0.0;

        realTotalFund += targetAmount;

        final remainingBalance = targetAmount - initialAmount;
        if (remainingBalance > 0) {
          unpaidBalances += remainingBalance;
        }

        // Parse into Member object for penalty calculations
        members.add(Member.fromMap(memberData));
      }

      // 3. Calculate Paid Penalties from member_payments table
      double paidPenalties = 0.0;
      final penaltyPayments = await supabase
          .from('member_payments')
          .select('amount')
          .eq('payment_type', 'penalty');

      for (var payment in penaltyPayments) {
        paidPenalties += (payment['amount'] as num).toDouble();
      }

      // 4. Calculate Overdue Penalties using MemberPenaltiesService
      double overduePenalties = 0.0;
      for (var member in members) {
        try {
          final pendingPenalties =
              await MemberPenaltiesService.calculatePendingPenalties(member);
          // Only sum currently-due penalties (not upcoming/projected ones)
          for (var p in pendingPenalties) {
            if (!p.isUpcoming) {
              overduePenalties += p.penaltyAmount;
            }
          }
        } catch (e) {
          print('Error calculating penalties for member ${member.fullName}: $e');
          // Continue with other members even if one fails
        }
      }

      return {
        'totalFund': realTotalFund,
        'availableCash': 0.0, // To be implemented with real data
        'totalLoanOut': 0.0, // To be implemented with real data
        'targetReturns': 0.0, // To be implemented with real data
        'vaultLiquidCash': 0.0, // To be implemented with real data
        'unpaidBalances': unpaidBalances,
        'generatedInterest': 0.0, // To be implemented with real data
        'generatedPenalties': 0.0, // To be implemented with real data
        'paidInterest': 0.0, // To be implemented with real data
        'paidPenalties': paidPenalties,
        'unpaidInterest': 0.0, // To be implemented with real data
        'overduePenalties': overduePenalties,
      };
    } catch (e) {
      print('Error getting dashboard data with real fund: $e');
      rethrow;
    }
  }
}

