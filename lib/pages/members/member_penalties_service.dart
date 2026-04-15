import 'package:supabase_flutter/supabase_flutter.dart';
import 'members_profile.dart'; // for Member

class PenaltyItem {
  final int monthIndex; // 1 to 11
  final String monthName;
  final double penaltyAmount;
  final String description;
  final bool isUpcoming;
  final DateTime? dueDate;

  PenaltyItem({
    required this.monthIndex,
    required this.monthName,
    required this.penaltyAmount,
    required this.description,
    this.isUpcoming = false,
    this.dueDate,
  });
}

class MemberPenaltiesService {
  static const List<String> cycleMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November'
  ];

  static Future<List<PenaltyItem>> calculatePendingPenalties(
      Member member) async {
    final supabase = Supabase.instance.client;

    // 1. Get all payments
    final paymentsRes = await supabase
        .from('member_payments')
        .select()
        .eq('member_id', member.id!);

    final List<Map<String, dynamic>> payments =
        List<Map<String, dynamic>>.from(paymentsRes);

    double totalContributionsFromPayments = 0;
    double totalPaidPenalties = 0;
    for (var p in payments) {
      if (p['payment_type'] == 'contribution') {
        totalContributionsFromPayments += (p['amount'] as num).toDouble();
      } else if (p['payment_type'] == 'penalty') {
        totalPaidPenalties += (p['amount'] as num).toDouble();
      }
    }

    final originalDeposit =
        member.initialAmount - totalContributionsFromPayments;

    final currentBalance = member.targetAmount - member.initialAmount;

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

      // Grace period starts on the joinDay of the current cycle month
      final gracePeriodStart = DateTime(year, monthIndex, joinDay);
      final gracePeriodEnd =
          DateTime(year, monthIndex, joinDay + 4, 23, 59, 59);

      if (now.isBefore(gracePeriodStart)) {
        // UPCOMING CYCLE
        // We only want the *next* upcoming cycle
        if (currentBalance > 0) {
          final penaltyAmount = currentBalance * 0.10;
          pending.add(PenaltyItem(
            monthIndex: monthIndex,
            monthName: monthName,
            penaltyAmount: penaltyAmount,
            description:
                "$monthName (Expected) - 10% of ₱${currentBalance.toStringAsFixed(2)}",
            isUpcoming: true,
            dueDate: gracePeriodStart,
          ));
        }
        break; // Stop after finding the very next cycle
      }

      double balanceAtAssessment = 0;

      // If they joined in a month strictly after this cycle, they entirely missed it
      if (joinDate.month > monthIndex) {
        balanceAtAssessment = member.targetAmount;
      } else {
        // Calculate contributions before gracePeriodEnd
        double historicContributions = 0;
        if (joinDate.isBefore(gracePeriodEnd) ||
            joinDate.isAtSameMomentAs(gracePeriodEnd)) {
          historicContributions += originalDeposit;
        }

        for (var p in payments) {
          if (p['payment_type'] == 'contribution') {
            final pDateStr = p['date'];
            if (pDateStr != null) {
              final pDate = DateTime.parse(pDateStr);
              if (pDate.isBefore(gracePeriodEnd) ||
                  pDate.isAtSameMomentAs(gracePeriodEnd)) {
                historicContributions += (p['amount'] as num).toDouble();
              }
            }
          }
        }
        balanceAtAssessment = member.targetAmount - historicContributions;
      }

      if (balanceAtAssessment <= 0)
        continue; // Fully paid by deadline, no penalty

      double penaltyRate = 0;

      if (now.isBefore(gracePeriodEnd) ||
          now.isAtSameMomentAs(gracePeriodEnd)) {
        penaltyRate = 0.10;
      } else {
        penaltyRate = 0.15;
      }

      double penaltyAmount = balanceAtAssessment * penaltyRate;
      final pctStr = (penaltyRate * 100).toInt();

      // Deduct previously paid penalties for this cycle
      if (totalPaidPenalties > 0) {
        if (totalPaidPenalties >= penaltyAmount) {
          totalPaidPenalties -= penaltyAmount;
          continue; // Fully paid penalty for this month
        } else {
          penaltyAmount -= totalPaidPenalties;
          totalPaidPenalties = 0;
        }
      }

      pending.add(PenaltyItem(
        monthIndex: monthIndex,
        monthName: monthName,
        penaltyAmount: penaltyAmount,
        description:
            "$monthName - $pctStr% of ₱${balanceAtAssessment.toStringAsFixed(2)}",
        isUpcoming: false,
      ));
    }

    return pending;
  }
}
