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

        // Assessment begins on the 1st of the following month
        final assessmentDate = DateTime(year, monthIndex + 1, 1);
        
        if (now.isBefore(assessmentDate)) {
           // Not reached the assessment date yet for this cycle
           continue; 
        }

        // Deadline is 5th of that following month
        final deadlineDate = DateTime(year, monthIndex + 1, 5, 23, 59, 59);

        double balanceAtAssessment = 0;
        
        // If they joined after the assessment date started, they entirely missed the cycle
        if (joinDate.isAfter(assessmentDate)) {
             balanceAtAssessment = member.targetAmount;
        } else {
             // Calculate contributions before deadline
             double historicContributions = 0;
             if (joinDate.isBefore(deadlineDate) || joinDate.isAtSameMomentAs(deadlineDate)) {
                 historicContributions += originalDeposit;
             }
             
             for(var p in payments) {
                 if (p['payment_type'] == 'contribution') {
                     final pDateStr = p['date'];
                     if (pDateStr != null) {
                         final pDate = DateTime.parse(pDateStr);
                         if (pDate.isBefore(deadlineDate) || pDate.isAtSameMomentAs(deadlineDate)) {
                             historicContributions += (p['amount'] as num).toDouble();
                         }
                     }
                 }
             }
             balanceAtAssessment = member.targetAmount - historicContributions;
        }

        if (balanceAtAssessment <= 0) continue; // Fully paid by deadline, no penalty

        // Calculate penalty rate based on current date
        bool isGracePeriod = now.year == deadlineDate.year &&
                             now.month == deadlineDate.month &&
                             now.day >= 1 && now.day <= 5;

        double penaltyRate = 0;

        if (isGracePeriod) {
           penaltyRate = 0.10;
        } else if (now.isAfter(deadlineDate)) {
           penaltyRate = 0.15;
        } else {
           continue;
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
