import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../services/interest_calculator.dart';
import 'package:uuid/uuid.dart';

class LoanProvider with ChangeNotifier {
  final List<Loan> _loans = [];
  List<Loan> get all => List.unmodifiable(_loans);
  List<Loan> get pending => _loans.where((l) => !l.approved).toList();
  List<Loan> get approved => _loans.where((l) => l.approved).toList();

  void requestLoan({
    required double principal,
    required double rate,
    required int periods,
    required InterestType type,
  }) {
    final loan = Loan(
      id: const Uuid().v4(),
      principal: principal,
      rate: rate,
      periods: periods,
      type: type,
      requestedAt: DateTime.now(),
    );
    loan.schedule = InterestCalculator.generateSchedule(loan);
    _loans.add(loan);
    notifyListeners();
  }

  void approve(String id) {
    final loan = _loans.firstWhere((e) => e.id == id);
    loan.approved = true;
    notifyListeners();
  }

  void pay(String loanId, int period, double amount) {
    final loan = _loans.firstWhere((e) => e.id == loanId);
    final payment = loan.schedule.firstWhere((p) => p.period == period);
    payment.paid += amount;
    notifyListeners();
  }
}
