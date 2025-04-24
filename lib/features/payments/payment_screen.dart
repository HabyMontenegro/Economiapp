import 'package:economiapp/core/provider/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatelessWidget {
  final String loanId;
  const PaymentScreen({super.key, required this.loanId});
  @override
  Widget build(BuildContext context) {
    final loan = context.read<LoanProvider>().all.firstWhere((l) => l.id == loanId);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pagos'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: loan.schedule.map((p) {
          return Card(
            child: ListTile(
              title: Text('Cuota ${p.period} — vence ${p.dueDate.toLocal().toString().split(' ').first}'),
              subtitle: Text('Pendiente: \$${p.remaining.toStringAsFixed(2)}'),
              trailing: CustomButton(
                text: 'Pagar',
                onPressed: p.remaining == 0
                    ? null
                    : () => _showPayDialog(context, p.period),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPayDialog(BuildContext context, int period) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Registrar Pago'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    final amount = double.parse(controller.text);
                    context.read<LoanProvider>().pay(loanId, period, amount);
                    Navigator.pop(context);
                  },
                  child: const Text('Pagar')),
            ],
          );
        });
  }
}
