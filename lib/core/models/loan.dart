enum InterestType { simple, compound, gradient, amortization }

class Loan {
  final String id;
  final double principal;
  final double rate; // 0.12 => 12 %
  final int periods; // cuotas
  final InterestType type;
  final DateTime requestedAt;
  bool approved;
  List<Payment> schedule;

  Loan({
    required this.id,
    required this.principal,
    required this.rate,
    required this.periods,
    required this.type,
    required this.requestedAt,
    this.approved = false,
    this.schedule = const [],
  });
}

class Payment {
  final int period;
  final DateTime dueDate;
  final double principalPart;
  final double interestPart;
  double paid = 0;

  Payment({
    required this.period,
    required this.dueDate,
    required this.principalPart,
    required this.interestPart,
  });

  double get remaining => principalPart + interestPart - paid;
}
