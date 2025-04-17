import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_math_fork/flutter_math.dart';

class GermanAmortizationScreen extends StatefulWidget {
  const GermanAmortizationScreen({super.key});

  @override
  _GermanAmortizationScreenState createState() =>
      _GermanAmortizationScreenState();
}

class _GermanAmortizationScreenState extends State<GermanAmortizationScreen> {
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  List<Map<String, dynamic>> amortizationTable = [];
  bool isDefinitionExpanded = false;
  bool isFormulaExpanded = false;

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

    r = (r / 100) / 12; // ✅ Convertir tasa anual a mensual
    double C = P / n; // Capital amortizado constante
    double saldo = P;

    List<Map<String, dynamic>> table = [];
    for (int i = 1; i <= n; i++) {
      double interes = saldo * r;
      double cuotaTotal = C + interes;
      saldo -= C;

      table.add({
        "Periodo": i,
        "Amortización": C,
        "Interés": interes,
        "Cuota": cuotaTotal,
        "Saldo": saldo > 0 ? saldo : 0,
      });
    }

    setState(() {
      amortizationTable = table;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amortización Alemana")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandableSection(
              "Definición de la Amortización Alemana",
              "La amortización alemana se caracteriza por cuotas de capital constantes, con intereses decrecientes y una cuota total que disminuye con el tiempo.\n"
                  "\nFórmulas Utilizadas:\n\n"
                  "- **Capital amortizado por período (C)**: ",
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
                      "En este tipo de amortización, el monto de las cuotas es mayor al principio y va disminuyendo a medida que se paga el capital.",
                    ),
                    const SizedBox(height: 8),
                    const Text("Fórmulas utilizadas:"),
                    Math.tex(
                      r"C = \frac{P}{n}",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Math.tex(
                      r"I = \text{saldo} \times r",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Math.tex(
                      r"\text{Cuota} = C + I",
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
              color: const Color.fromARGB(255, 4, 166, 101),
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
