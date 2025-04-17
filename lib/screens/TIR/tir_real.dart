import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';

class RealRateScreen extends StatefulWidget {
  const RealRateScreen({super.key});

  @override
  State<RealRateScreen> createState() => _RealRateScreenState();
}

class _RealRateScreenState extends State<RealRateScreen> {
  final nominalRateController = TextEditingController();
  final inflationRateController = TextEditingController();

  bool showDefinition = false;
  String formula = '';
  String formulaWithValues = '';
  String resultValue = '';

  void calculateRealRate() {
    final double? nominal = double.tryParse(nominalRateController.text.replaceAll(',', '.'));
    final double? inflation = double.tryParse(inflationRateController.text.replaceAll(',', '.'));

    if (nominal == null || inflation == null) {
      setState(() {
        resultValue = '⚠️ Ingresa valores numéricos para ambas tasas.';
      });
      return;
    }

    final double realRate = (1 + nominal/100) / (1 + inflation/100) - 1;
    setState(() {
      formula = r"r_{\mathrm{real}} = \frac{1 + r_{\mathrm{nom}}}{1 + r_{\mathrm{inf}}} - 1";
      formulaWithValues =
          'r_real = (1 + ${nominal.toStringAsFixed(2)}%) / (1 + ${inflation.toStringAsFixed(2)}%) - 1';
      resultValue = 'Tasa real ≈ ${(realRate * 100).toStringAsFixed(2)}%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasa de Retorno Real')),
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
                  '¿Qué es la Tasa de Retorno Real?',
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
                  'La tasa de retorno real ajusta la tasa nominal por la inflación, mostrando el crecimiento real del poder adquisitivo.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text('Fórmula:', style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    r"r_{\mathrm{real}} = \frac{1 + r_{\mathrm{nom}}}{1 + r_{\mathrm{inf}}} - 1",
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Donde:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('• rₙₒₘ: Tasa de interés nominal (%).'),
                const Text('• rᵢₙf: Tasa de inflación (%).'),
              ]),
            ),
          _buildTextField('Tasa nominal (en %)', nominalRateController),
          _buildTextField('Inflación (en %)', inflationRateController),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: calculateRealRate,
              child: const Text('Calcular Tasa Real'),
            ),
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
