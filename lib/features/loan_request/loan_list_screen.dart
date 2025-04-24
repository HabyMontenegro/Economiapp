import 'package:economiapp/core/provider/loan_provider.dart';
import 'package:economiapp/features/payments/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanProvider>();
    return Scaffold(
      appBar: const CustomAppBar(title: 'Solicitudes'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: provider.all.map((loan) {
          return Card(
            child: ListTile(
              title: Text('🪙 \$${loan.principal} — ${loan.type.name}'),
              subtitle: Text(
                  'Cuotas: ${loan.periods} | Estado: ${loan.approved ? 'Aprobado' : 'Pendiente'}'),
              trailing: loan.approved
                  ? const Icon(Icons.check, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => provider.approve(loan.id),
                    ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(loanId: loan.id),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}