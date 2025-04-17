import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_math_fork/flutter_math.dart';

class AmericanAmortizationScreen extends StatefulWidget {
  const AmericanAmortizationScreen({super.key});

  @override
  _AmericanAmortizationScreenState createState() =>
      _AmericanAmortizationScreenState();
}

class _AmericanAmortizationScreenState
    extends State<AmericanAmortizationScreen> {
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  List<Map<String, dynamic>> amortizationTable = [];
  bool isDefinitionExpanded = false;

  void calculateAmortization() {
    double P = double.tryParse(loanAmountController.text) ?? 0.0;
    double r = double.tryParse(interestRateController.text) ?? 0.0;
    int n = int.tryParse(periodsController.text) ?? 0;

    if (P == 0 || r == 0 || n == 0) {
      setState(() {
        amortizationTable.clear();
      });
      return;
    }

    r = r / 100; // Convertir tasa de interés a decimal
    double interesFijo = P * r; // Intereses fijos en cada período

    List<Map<String, dynamic>> table = [];
    for (int i = 1; i <= n; i++) {
      double cuotaTotal = interesFijo;
      double saldo = P; // El capital no cambia hasta el último período

      if (i == n) {
        cuotaTotal += P; // Última cuota incluye el capital completo
        saldo = 0; // Se paga el capital
      }

      table.add({
        "Periodo": i,
        "Amortización": (i == n) ? P : 0,
        "Interés": interesFijo,
        "Cuota": cuotaTotal,
        "Saldo": saldo,
      });
    }

    setState(() {
      amortizationTable = table;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amortización Americana")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandableSection(
              "Definición de la Amortización Americana",
              "La amortización americana se caracteriza por el pago de solo intereses durante todos los períodos, "
                  "y el pago del capital total al final.\n\n"
                  "Fórmulas Utilizadas:\n\n"
                  "- **Intereses por período (I)**: ",
              isDefinitionExpanded,
              () {
                setState(() {
                  isDefinitionExpanded = !isDefinitionExpanded;
                });
              },
            ),
            if (isDefinitionExpanded)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "En la amortización americana, solo se pagan los intereses durante todos los períodos, "
                      "y el capital total se paga en la última cuota.",
                    ),
                    const SizedBox(height: 8),
                    const Text("Fórmulas utilizadas:"),
                    Math.tex(
                      r"I = P \times r",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Math.tex(
                      r"\text{Cuota} = I",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Math.tex(
                      r"\text{Cuota final} = I + P",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            _buildTextField("Monto del Préstamo", loanAmountController),
            _buildTextField("Tasa de Interés (%)", interestRateController),
            _buildTextField("Número de Periodos", periodsController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateAmortization,
              child: const Text("Calcular"),
            ),
            const SizedBox(height: 20),
            _buildResponsiveTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
      String title, String content, bool isExpanded, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildResponsiveTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 20.0,
          columns: const [
            DataColumn(label: Text("Periodo")),
            DataColumn(label: Text("Amortización")),
            DataColumn(label: Text("Interés")),
            DataColumn(label: Text("Cuota")),
            DataColumn(label: Text("Saldo")),
          ],
          rows: amortizationTable.map((row) {
            return DataRow(cells: [
              DataCell(Text(row["Periodo"].toString())),
              DataCell(Text(row["Amortización"].toStringAsFixed(2))),
              DataCell(Text(row["Interés"].toStringAsFixed(2))),
              DataCell(Text(row["Cuota"].toStringAsFixed(2))),
              DataCell(Text(row["Saldo"].toStringAsFixed(2))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
