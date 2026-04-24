class Loan {
  final String? id;
  final String borrowerName;
  final double requestedAmount;
  final DateTime? dateBorrowed;
  final String status;

  Loan({
    this.id,
    required this.borrowerName,
    required this.requestedAmount,
    this.dateBorrowed,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'borrower_name': borrowerName,
      'requested_amount': requestedAmount,
      'date_borrowed': dateBorrowed?.toIso8601String(),
      'status': status,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id']?.toString(),
      borrowerName: map['borrower_name'] ?? '',
      requestedAmount:
          (map['requested_amount'] as num?)?.toDouble() ?? 0.0,
      dateBorrowed: map['date_borrowed'] != null
          ? DateTime.parse(map['date_borrowed'])
          : null,
      status: map['status'] ?? 'active',
    );
  }
}
