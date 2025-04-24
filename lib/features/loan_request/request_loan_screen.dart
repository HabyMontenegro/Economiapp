import 'dart:math';
import 'package:flutter/material.dart';
import 'package:economiapp/controllers/user_file_controller.dart';
import '../../core/models/loan.dart';
import '../../core/services/interest_calculator.dart';
import '../../widgets/custom_button.dart';

class RequestLoanScreen extends StatefulWidget {
  final String cedula;
  const RequestLoanScreen({super.key, required this.cedula});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  double _principal = 0;
  double _rate = 0.1;
  int _periods = 12;
  InterestType _type = InterestType.simple;

  double _loanAmount = 0;
  List<Payment> _schedule = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitar Préstamo"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ── Campos ─────────────────────────────────────────────
              TextFormField(
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _principal = double.parse(v!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tasa (%)'),
                keyboardType: TextInputType.number,
                initialValue: '10',
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _rate = double.parse(v!) / 100,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cuotas'),
                keyboardType: TextInputType.number,
                initialValue: '12',
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _periods = int.parse(v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<InterestType>(
                value: _type,
                items: InterestType.values.map((e) {
                  final label = _labelFor(e); // ← texto legible
                  return DropdownMenuItem(value: e, child: Text(label));
                }).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),

              const SizedBox(height: 20),

              // ── Botones ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Calcular',
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        _calcularPrestamo();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Prestar',
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        final ctrl = UserFileController();
                        final nuevoSaldo =
                            await ctrl.addSaldo(widget.cedula, _principal);

                        if (mounted) {
                          Navigator.pop(context, nuevoSaldo); // devuelve saldo
                        }
                      },
                    ),
                  ),
                ],
              ),

              // ── Resultado ──────────────────────────────────────────
              if (_loanAmount > 0) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Monto total a pagar: \$${_loanAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_type == InterestType.amortization && _schedule.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Período')),
                        DataColumn(label: Text('Pago')),
                        DataColumn(label: Text('Interés')),
                        DataColumn(label: Text('Principal')),
                        DataColumn(label: Text('Saldo')),
                      ],
                      rows: _buildAmortRows(),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Cálculos ────────────────────────────────────────────────────
  double _calculateSimpleInterest() => _principal * (1 + _rate * _periods);

  double _calculateCompoundInterest() =>
      _principal * pow(1 + _rate, _periods).toDouble();

  double _calculateGradient() {
    double growthRate = 0.05;
    double total = 0, current = _principal;
    for (int i = 0; i < _periods; i++) {
      total += current;
      current *= (1 + growthRate);
    }
    return total;
  }

  void _calcularPrestamo() {
    double result;
    List<Payment> schedule = [];

    switch (_type) {
      case InterestType.simple:
        result = _calculateSimpleInterest();
        break;
      case InterestType.compound:
        result = _calculateCompoundInterest();
        break;
      case InterestType.gradient:
        result = _calculateGradient();
        break;
      case InterestType.amortization:
        final tempLoan = Loan(
          id: '',
          principal: _principal,
          rate: _rate,
          periods: _periods,
          type: _type,
          requestedAt: DateTime.now(),
        );
        schedule = InterestCalculator.generateSchedule(tempLoan);
        result = schedule.fold(
            0.0, (sum, p) => sum + p.principalPart + p.interestPart);
        break;
    }

    setState(() {
      _loanAmount = result;
      _schedule = schedule;
    });
  }

  List<DataRow> _buildAmortRows() {
    double runningBalance = _principal;
    final List<DataRow> rows = [];

    for (final p in _schedule) {
      final pagoTotal = p.principalPart + p.interestPart;
      runningBalance -= p.principalPart;

      rows.add(DataRow(cells: [
        DataCell(Text(p.period.toString())),
        DataCell(Text('\$${pagoTotal.toStringAsFixed(2)}')),
        DataCell(Text('\$${p.interestPart.toStringAsFixed(2)}')),
        DataCell(Text('\$${p.principalPart.toStringAsFixed(2)}')),
        DataCell(Text('\$${runningBalance.toStringAsFixed(2)}')),
      ]));
    }
    return rows;
  }

  String _labelFor(InterestType t) {
    switch (t) {
      case InterestType.simple:
        return 'Interes simple';
      case InterestType.compound:
        return 'Interes compuesto';
      case InterestType.gradient:
        return 'Interes gradiente';
      case InterestType.amortization:
        return 'Amortizacion alemana';
    }
  }
}
