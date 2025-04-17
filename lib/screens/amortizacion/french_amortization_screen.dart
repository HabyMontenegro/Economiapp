import 'package:flutter/material.dart';
import 'dart:math';

class FrenchAmortizationScreen extends StatefulWidget {
  const FrenchAmortizationScreen({super.key});

  @override
  _FrenchAmortizationScreenState createState() => _FrenchAmortizationScreenState();
}

class _FrenchAmortizationScreenState extends State<FrenchAmortizationScreen> {
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  List<Map<String, dynamic>> amortizationTable = [];
  bool isDefinitionExpanded = false;

  void calculateAmortization() {
    double P = double.tryParse(loanAmountController.text) ?? 0.0;
    double r = double.tryParse(interestRateController.text) ?? 0.0;
    double n = double.tryParse(periodsController.text) ?? 0.0;

    if (P == 0 || r == 0 || n == 0) {
      setState(() {
        amortizationTable.clear();
      });
      return;
    }

    r = r / 100 / 12; // Convertir tasa de interés anual a mensual y decimal
    double cuotaTotal = P * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    double saldo = P;

    List<Map<String, dynamic>> table = [];
    for (int i = 1; i <= n; i++) {
      double interes = saldo * r;
      double capital = cuotaTotal - interes;
      saldo -= capital;

      table.add({
        "Periodo": i,
        "Amortización": capital,
        "Interés": interes,
        "Cuota": cuotaTotal,
        "Saldo": max(saldo, 0),
      });
    }

    setState(() {
      amortizationTable = table;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amortización Francesa")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandableSection(
              "Definición",
              "La amortización francesa se caracteriza por cuotas fijas, donde la proporción de interés disminuye y la del capital aumenta con el tiempo.\n"
              "\nFórmula de la Cuota\n\n"
              "- Cuota fija: Cuota = P * (r * (1 + r)^n) / ((1 + r)^n - 1)",
              isDefinitionExpanded,
              () {
                setState(() {
                  isDefinitionExpanded = !isDefinitionExpanded;
                });
              },
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

  Widget _buildExpandableSection(String title, String content, bool isExpanded, VoidCallback onTap) {
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
