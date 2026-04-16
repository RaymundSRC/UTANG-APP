import 'dart:async';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  // Mock data for demonstration - replace with actual data source
  double _totalFund = 500000.00;
  double _availableCash = 125000.00;
  double _totalLoanOut = 375000.00;
  double _targetReturns = 45000.00;
  double _vaultLiquidCash = 80000.00;
  double _unpaidBalances = 25000.00;
  double _generatedInterest = 15000.00;
  double _generatedPenalties = 3200.00;
  double _paidInterest = 12000.00;
  double _paidPenalties = 2800.00;
  double _unpaidInterest = 3000.00;
  double _overduePenalties = 400.00;

  Future<Map<String, dynamic>> getDashboardData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'totalFund': _totalFund,
      'availableCash': _availableCash,
      'totalLoanOut': _totalLoanOut,
      'targetReturns': _targetReturns,
      'vaultLiquidCash': _vaultLiquidCash,
      'unpaidBalances': _unpaidBalances,
      'generatedInterest': _generatedInterest,
      'generatedPenalties': _generatedPenalties,
      'paidInterest': _paidInterest,
      'paidPenalties': _paidPenalties,
      'unpaidInterest': _unpaidInterest,
      'overduePenalties': _overduePenalties,
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
    // In a real app, this would fetch fresh data from your backend
    return await getDashboardData();
  }
}
