import 'package:supabase_flutter/supabase_flutter.dart';
import '../../pages/loans/loan_model.dart';

class LoanService {
  static final LoanService _instance = LoanService._internal();
  factory LoanService() => _instance;
  LoanService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Insert a new loan into the loans table.
  Future<void> addLoan({
    required String borrowerName,
    required double requestedAmount,
    DateTime? dateBorrowed,
  }) async {
    try {
      final loanData = {
        'borrower_name': borrowerName,
        'requested_amount': requestedAmount,
        'date_borrowed': (dateBorrowed ?? DateTime.now()).toIso8601String(),
        'status': 'active',
      };

      await _supabase.from('loans').insert(loanData);
    } catch (e) {
      print('Error adding loan: $e');
      rethrow;
    }
  }

  /// Fetch all loans ordered by most recent first.
  Future<List<Loan>> fetchLoans() async {
    try {
      final response = await _supabase
          .from('loans')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((loan) => Loan.fromMap(loan))
          .toList();
    } catch (e) {
      print('Error fetching loans: $e');
      rethrow;
    }
  }
}
