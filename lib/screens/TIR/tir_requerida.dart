import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TrrCapmScreen extends StatefulWidget {
  const TrrCapmScreen({super.key});

  @override
  State<TrrCapmScreen> createState() => _TrrCapmScreenState();
}

class _TrrCapmScreenState extends State<TrrCapmScreen> {
  final rfrController = TextEditingController();       // Tasa libre de riesgo
  final betaController = TextEditingController();      // Beta de la acción
  final rMarketController = TextEditingController();   // Rendimiento del mercado

  bool showDefinition = false;
  String formula = '';
  String formulaWithValues = '';
  String resultValue = '';

  void calcularTRR() {
    final double? rfr = double.tryParse(rfrController.text.replaceAll(',', '.'));
    final double? beta = double.tryParse(betaController.text.replaceAll(',', '.'));
    final double? rMarket = double.tryParse(rMarketController.text.replaceAll(',', '.'));

    if (rfr == null || beta == null || rMarket == null) {
      setState(() {
        resultValue = '⚠️ Completa todos los campos con valores numéricos.';
      });
      return;
    }

    // CAPM: E(R) = RFR + β × (Rmarket − RFR)
    final trr = rfr + beta * (rMarket - rfr);

    setState(() {
      formula = r"E(R) = R_{FR} + \beta \times (R_{M} - R_{FR})";
      formulaWithValues =
          'E(R) = ${rfr.toStringAsFixed(2)} + ${beta.toStringAsFixed(2)} × (${rMarket.toStringAsFixed(2)} - ${rfr.toStringAsFixed(2)})';
      resultValue = 'TRR = ${ (trr * 100).toStringAsFixed(2) }%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasa de Retorno Requerida (CAPM)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => setState(() => showDefinition = !showDefinition),
            child: Row(children: [
              Icon(showDefinition ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  '¿Qué es la Tasa de Retorno Requerida (CAPM)?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            ]),
          ),
          if (showDefinition)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  'El CAPM (Capital Asset Pricing Model) calcula la TRR considerando la tasa libre de riesgo, '
                  'la beta de la acción y el rendimiento esperado del mercado.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text('Fórmula:', style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    r"E(R) = R_{FR} + \beta \times (R_{M} - R_{FR})",
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Donde:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('• R_{FR}: Tasa libre de riesgo (ej. T-bill a 10 años).'),
                const Text('• β: Beta de la acción (volatilidad relativa al mercado).'),
                const Text('• R_{M}: Rendimiento esperado del mercado.'),
              ]),
            ),
          _buildTextField('Tasa libre de riesgo (RFR, decimal)', rfrController),
          _buildTextField('Beta de la acción (β)', betaController),
          _buildTextField('Rendimiento de mercado (RM, decimal)', rMarketController),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(onPressed: calcularTRR, child: const Text('Calcular TRR')),
          ),
          const SizedBox(height: 24),
          if (resultValue.isNotEmpty) ...[
            const Text('Fórmula:', style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(formula, textStyle: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Sustitución:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(formulaWithValues),
            const SizedBox(height: 8),
            const Text('Resultado:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(resultValue, style: const TextStyle(fontSize: 18, color: Colors.blue)),
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
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
