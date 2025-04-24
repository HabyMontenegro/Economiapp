import '../models/loan.dart';
import 'dart:math';

class InterestCalculator {
  static List<Payment> generateSchedule(Loan loan) {
    switch (loan.type) {
      case InterestType.simple:
        return _simple(loan);
      case InterestType.compound:
        return _compound(loan);
      case InterestType.gradient:
        return _gradient(loan);
      case InterestType.amortization:
        return _amortizationGerman(loan);
    }
  }

  static List<Payment> _simple(Loan l) {
    final interestTotal = l.principal * l.rate * l.periods;
    final interestPer = interestTotal / l.periods;
    final principalPer = l.principal / l.periods;
    return List.generate(l.periods, (i) => Payment(
          period: i + 1,
          dueDate: l.requestedAt.add(Duration(days: 30 * (i + 1))),
          principalPart: principalPer,
          interestPart: interestPer,
        ));
  }

  static List<Payment> _compound(Loan l) {
    final r = l.rate;
    final n = l.periods;
    final q = pow(1 + r, n);
    final cuota = l.principal * r * q / (q - 1);
    double remaining = l.principal;
    return List.generate(n, (i) {
      final interest = remaining * r;
      final principal = cuota - interest;
      remaining -= principal;
      return Payment(
        period: i + 1,
        dueDate: l.requestedAt.add(Duration(days: 30 * (i + 1))),
        principalPart: principal,
        interestPart: interest,
      );
    });
  }

  static List<Payment> _gradient(Loan l) {
    // Placeholder gradient method
    return _simple(l);
  }

  static List<Payment> _amortizationGerman(Loan l) {
    final principalPer = l.principal / l.periods;
    double remaining = l.principal;
    return List.generate(l.periods, (i) {
      final interest = remaining * l.rate;
      remaining -= principalPer;
      return Payment(
        period: i + 1,
        dueDate: l.requestedAt.add(Duration(days: 30 * (i + 1))),
        principalPart: principalPer,
        interestPart: interest,
      );
    });
  }
}
