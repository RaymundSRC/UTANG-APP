import 'package:supabase_flutter/supabase_flutter.dart';
import 'members_profile.dart'; // for Member

class PenaltyItem {
  final int monthIndex; // 1 to 11
  final String monthName;
  final double penaltyAmount;
  final String description;

  PenaltyItem({
    required this.monthIndex,
    required this.monthName,
    required this.penaltyAmount,
    required this.description,
  });
}

class MemberPenaltiesService {
  static const List<String> cycleMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November'
  ];

  static Future<List<PenaltyItem>> calculatePendingPenalties(Member member) async {
    final supabase = Supabase.instance.client;

    // 1. Get all payments
    final paymentsRes = await supabase
        .from('member_payments')
        .select()
        .eq('member_id', member.id!);
        
    final List<Map<String, dynamic>> payments = List<Map<String, dynamic>>.from(paymentsRes);
    
    // 2. Calculate original deposit at join date
    double totalContributionsFromPayments = 0;
    for (var p in payments) {
      if (p['payment_type'] == 'contribution') {
        totalContributionsFromPayments += (p['amount'] as num).toDouble();
      }
    }
    
    final originalDeposit = member.initialAmount - totalContributionsFromPayments;
    
    // 3. Get already paid penalties (we won't skip months, we just calculate gross)
    List<PenaltyItem> pending = [];
    final joinDate = member.date ?? DateTime.now();
    final year = joinDate.year;
    final now = DateTime.now();

    // 4. Iterate over the 11 cycles
    for (int i = 0; i < 11; i++) {
        final monthIndex = i + 1; // 1 to 11
        final monthName = cycleMonths[i];

        final joinDay = joinDate.day;

        // Grace period starts on the joinDay of the following month
        final gracePeriodStart = DateTime(year, monthIndex + 1, joinDay);
        
        if (now.isBefore(gracePeriodStart)) {
           // Not reached the grace period date yet for this cycle
           continue; 
        }

        // Deadline is +4 days to give a 5-day inclusive grace period (e.g. 9 to 13)
        final gracePeriodEnd = DateTime(year, monthIndex + 1, joinDay + 4, 23, 59, 59);

        double balanceAtAssessment = 0;
        
        // If they joined in a month strictly after this cycle, they entirely missed it
        if (joinDate.month > monthIndex) {
             balanceAtAssessment = member.targetAmount;
        } else {
             // Calculate contributions before gracePeriodEnd
             double historicContributions = 0;
             if (joinDate.isBefore(gracePeriodEnd) || joinDate.isAtSameMomentAs(gracePeriodEnd)) {
                 historicContributions += originalDeposit;
             }
             
             for(var p in payments) {
                 if (p['payment_type'] == 'contribution') {
                     final pDateStr = p['date'];
                     if (pDateStr != null) {
                         final pDate = DateTime.parse(pDateStr);
                         if (pDate.isBefore(gracePeriodEnd) || pDate.isAtSameMomentAs(gracePeriodEnd)) {
                             historicContributions += (p['amount'] as num).toDouble();
                         }
                     }
                 }
             }
             balanceAtAssessment = member.targetAmount - historicContributions;
        }

        if (balanceAtAssessment <= 0) continue; // Fully paid by deadline, no penalty

        double penaltyRate = 0;

        if (now.isBefore(gracePeriodEnd) || now.isAtSameMomentAs(gracePeriodEnd)) {
           penaltyRate = 0.10;
        } else {
           penaltyRate = 0.15;
        }

        final penaltyAmount = balanceAtAssessment * penaltyRate;
        final pctStr = (penaltyRate * 100).toInt();
        
        pending.add(PenaltyItem(
          monthIndex: monthIndex,
          monthName: monthName,
          penaltyAmount: penaltyAmount,
          description: "$monthName - $pctStr% of ₱${balanceAtAssessment.toStringAsFixed(2)}",
        ));
    }
    
    return pending;
  }
}
