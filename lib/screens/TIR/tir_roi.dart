import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class RoiScreen extends StatefulWidget {
  const RoiScreen({super.key});

  @override
  State<RoiScreen> createState() => _RoiScreenState();
}

class _RoiScreenState extends State<RoiScreen> {
  final TextEditingController inversionController = TextEditingController();
  final TextEditingController utilidadController = TextEditingController();

  bool showDefinition = false;
  String formula = "";
  String formulaWithValues = "";
  String resultValue = "";

  void calcularROI() {
    final double? I =
        double.tryParse(inversionController.text.replaceAll(',', '.'));
    final double? U =
        double.tryParse(utilidadController.text.replaceAll(',', '.'));

    if (I == null || I <= 0 || U == null) {
      setState(() {
        resultValue = "⚠️ Ingresa inversión > 0 y utilidad.";
      });
      return;
    }

    final double roi = (U / I) * 100;
    setState(() {
      formula = r"ROI = \frac{U}{I} \times 100";
      formulaWithValues =
          "ROI = (${U.toStringAsFixed(2)} / ${I.toStringAsFixed(2)}) × 100";
      resultValue = "ROI = ${roi.toStringAsFixed(2)}%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasa de Retorno Contable")),
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
                // Aquí envolvemos el Text en un Expanded para que pueda hacer wrap
                Expanded(
                  child: const Text(
                    "¿Qué es la Tasa de Retorno Contable (ROI)?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          if (showDefinition)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "La Tasa de Retorno Contable o ROI (Return on Investment) mide la rentabilidad basada en utilidad contable, "
                    "dividiendo la utilidad promedio anual entre la inversión inicial.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text("Fórmula:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Math.tex(r"ROI = \frac{U}{I} \times 100",
                      textStyle: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text("Donde:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text("• U: Utilidad promedio anual."),
                  const Text("• I: Inversión inicial (debe ser > 0)."),
                ],
              ),
            ),
          _buildTextField("Inversión Inicial (I)", inversionController),
          _buildTextField("Utilidad Promedio Anual (U)", utilidadController),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: calcularROI,
              child: const Text("Calcular ROI"),
            ),
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
          ],
        ]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
