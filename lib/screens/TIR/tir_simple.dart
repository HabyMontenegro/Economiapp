import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';

class TIRSimpleScreen extends StatefulWidget {
  const TIRSimpleScreen({super.key});

  @override
  State<TIRSimpleScreen> createState() => _TIRSimpleScreenState();
}

class _TIRSimpleScreenState extends State<TIRSimpleScreen> {
  final TextEditingController inversionController = TextEditingController();
  final TextEditingController retornoController = TextEditingController();
  final TextEditingController tiempoController = TextEditingController();

  bool showDefinition = false;
  String selectedTimeUnit = "Años";
  final List<String> timeUnits = ["Años", "Meses"];

  String formula = "";
  String formulaWithValues = "";
  String resultValue = "";

  void calcularTIR() {
    double? inversion = double.tryParse(inversionController.text);
    double? retorno = double.tryParse(retornoController.text);
    double? tiempo = double.tryParse(tiempoController.text);

    if (inversion == null || retorno == null || tiempo == null) {
      setState(() {
        resultValue = "⚠️ Por favor completa todos los campos.";
      });
      return;
    }

    // Si el tiempo está en meses, convertir a años
    if (selectedTimeUnit == "Meses") {
      tiempo = tiempo / 12;
    }

    // Fórmula TIR simple: r = (R - I) / (I * t)
    double tir = (retorno - inversion) / (inversion * tiempo);

    setState(() {
      formula = r"r = \frac{R - I}{I \cdot t}";
      formulaWithValues =
          "r = (${retorno.toStringAsFixed(2)} - ${inversion.toStringAsFixed(2)}) / (${inversion.toStringAsFixed(2)} × ${tiempo?.toStringAsFixed(2)})";
      resultValue = "TIR = ${(tir * 100).toStringAsFixed(2)}%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TIR Simple")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => setState(() => showDefinition = !showDefinition),
            child: Row(
              children: [
                Icon(showDefinition
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down),
                const SizedBox(width: 8),
                const Text("¿Qué es la TIR simple?",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (showDefinition)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "La TIR simple (Tasa Interna de Retorno) es una medida que estima la rentabilidad de una inversión considerando una única entrada y una única salida de efectivo.",
                  ),
                  const SizedBox(height: 8),
                  const Text("Fórmula:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Math.tex(r"r = \frac{R - I}{I \cdot t}",
                      textStyle: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text("Donde:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text("• R: Retorno total de la inversión."),
                  const Text("• I: Inversión inicial."),
                  const Text("• t: Tiempo en años o meses."),
                ],
              ),
            ),
          const SizedBox(height: 20),
          _buildTextField("Inversión Inicial (I)", inversionController),
          _buildTextField("Retorno Total (R)", retornoController),
          Row(
            children: [
              Flexible(
                flex: 3,
                child: _buildTextField(
                    "Tiempo transcurrido (t)", tiempoController),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 2,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedTimeUnit,
                  items: timeUnits
                      .map((unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTimeUnit = value!;
                    });
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: calcularTIR,
            child: const Text("Calcular TIR"),
          ),
          const SizedBox(height: 20),
          if (resultValue.isNotEmpty) ...[
            const Text("Fórmula:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(formula, textStyle: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text("Sustitución:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(formulaWithValues),
            const SizedBox(height: 8),
            const Text("Resultado:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(resultValue,
                style: const TextStyle(fontSize: 18, color: Colors.blue)),
          ]
        ]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
