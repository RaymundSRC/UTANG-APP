import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../pages/members/members_profile.dart';
import '../../pages/members/member_penalties_service.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  // Placeholder values for cards not yet connected to real data
  double _totalFund = 0.0;
  double _availableCash = 0.0;
  double _totalLoanOut = 0.0;
  double _targetReturns = 0.0;
  double _vaultLiquidCash = 0.0;
  double _generatedInterest = 0.0;
  double _generatedPenalties = 0.0;
  double _paidInterest = 0.0;
  double _unpaidInterest = 0.0;

  Future<Map<String, dynamic>> getDashboardData() async {
    final supabase = Supabase.instance.client;

    // --- Unpaid Balances ---
    // Sum of (target_amount - initial_amount) for all members where balance > 0
    double unpaidBalances = 0.0;
    final membersRes = await supabase.from('members').select();
    final List<Map<String, dynamic>> membersData =
        List<Map<String, dynamic>>.from(membersRes);

    for (var m in membersData) {
      final target = (m['target_amount'] as num?)?.toDouble() ?? 0.0;
      final initial = (m['initial_amount'] as num?)?.toDouble() ?? 0.0;
      final balance = target - initial;
      if (balance > 0) {
        unpaidBalances += balance;
      }
    }

    // --- Paid Penalties ---
    // Sum of all payments where payment_type == 'penalty'
    double paidPenalties = 0.0;
    final penaltyPaymentsRes = await supabase
        .from('member_payments')
        .select('amount')
        .eq('payment_type', 'penalty');
    final List<Map<String, dynamic>> penaltyPayments =
        List<Map<String, dynamic>>.from(penaltyPaymentsRes);

    for (var p in penaltyPayments) {
      paidPenalties += (p['amount'] as num).toDouble();
    }

    // --- Overdue Penalties ---
    // For each member, calculate pending (non-upcoming) penalties and sum them
    double overduePenalties = 0.0;
    for (var m in membersData) {
      final member = Member.fromMap(m);
      final pendingPenalties =
          await MemberPenaltiesService.calculatePendingPenalties(member);
      for (var penalty in pendingPenalties) {
        if (!penalty.isUpcoming) {
          overduePenalties += penalty.penaltyAmount;
        }
      }
    }

    return {
      'totalFund': _totalFund,
      'availableCash': _availableCash,
      'totalLoanOut': _totalLoanOut,
      'targetReturns': _targetReturns,
      'vaultLiquidCash': _vaultLiquidCash,
      'unpaidBalances': unpaidBalances,
      'generatedInterest': _generatedInterest,
      'generatedPenalties': _generatedPenalties,
      'paidInterest': _paidInterest,
      'paidPenalties': paidPenalties,
      'unpaidInterest': _unpaidInterest,
      'overduePenalties': overduePenalties,
    };
  }

  Future<double> getTotalFund() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _totalFund;
  }

  Future<void> updateTotalFund(double newAmount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _totalFund = newAmount;
  }

  Future<void> addFund(double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _totalFund += amount;
    _availableCash += amount;
  }

  Future<void> withdrawFund(double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_availableCash >= amount) {
      _availableCash -= amount;
      _totalFund -= amount;
    } else {
      throw Exception('Insufficient available cash');
    }
  }

  // Method to refresh all dashboard data
  Future<Map<String, dynamic>> refreshDashboardData() async {
    return await getDashboardData();
  }
}
