import 'package:economiapp/features/loan_request/request_loan_screen.dart';
import 'package:economiapp/widgets/custom_app_bar.dart';
import 'package:economiapp/widgets/custom_button.dart';
import 'package:economiapp/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String nombres;
  final String cedula; // necesitamos la cédula para actualizar saldo
  final double saldo;

  const HomeScreen({
    super.key,
    required this.nombres,
    required this.cedula,
    required this.saldo,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double _saldo; // saldo que podrá mutar

  @override
  void initState() {
    super.initState();
    _saldo = widget.saldo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "EconomiApp"),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${widget.nombres}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _saldoCard(),
            const Spacer(),
            Center(
              child: CustomButton(
                text: "Prestar Plata",
                onPressed: _abrirPrestamo,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _saldoCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Saldo Disponible",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_saldo.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );

  Future<void> _abrirPrestamo() async {
    final nuevoSaldo = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestLoanScreen(cedula: widget.cedula),
      ),
    );
    if (nuevoSaldo != null) setState(() => _saldo = nuevoSaldo);

    if (nuevoSaldo != null && mounted) {
      setState(() => _saldo = nuevoSaldo); // refresca UI
    }
  }
}
