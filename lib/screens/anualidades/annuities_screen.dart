import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_math_fork/flutter_math.dart';

class AnnuitiesScreen extends StatefulWidget {
  const AnnuitiesScreen({super.key});

  @override
  _AnnuitiesScreenState createState() => _AnnuitiesScreenState();
}

class _AnnuitiesScreenState extends State<AnnuitiesScreen> {
  final TextEditingController periodicPaymentController =
      TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  final TextEditingController futureValueController = TextEditingController();

  bool showDefinition = false;
  String selectedCalculation = "Monto o Valor Futuro";
  String formula = "";
  String formulaWithValues = "";
  String resultLabel = "";
  String resultValue = "";

  /// Función para calcular la tasa de interés `r` usando Newton-Raphson
  double? calcularTasaInteres(double FV, double P, double t) {
    if (P == 0 || FV == 0 || t == 0) return null; // Evita divisiones por cero

    double r = 0.05; // Suposición inicial del 5% (ajustable)
    double precision = 1e-6;
    int maxIteraciones = 100;

    for (int i = 0; i < maxIteraciones; i++) {
      double funcion = P * (pow(1 + r, t) - 1) / r - FV;
      double derivada =
          (P * t * pow(1 + r, t - 1) * r - P * (pow(1 + r, t) - 1)) / (r * r);

      if (derivada == 0) break;

      double nuevoR = r - funcion / derivada;

      if ((nuevoR - r).abs() < precision) {
        return nuevoR; // Si la diferencia es menor a la precisión, se acepta el resultado
      }

      r = nuevoR;
    }

    return null; // Si no converge, devuelve null
  }

  void calculate() {
    double? P = double.tryParse(periodicPaymentController.text);
    double? r = double.tryParse(rateController.text);
    double? t = double.tryParse(periodsController.text);
    double? FV = double.tryParse(futureValueController.text);

    if (r != null) {
      r /= 100; // Convertir porcentaje a decimal
    }

    int emptyCount = [P, r, t, FV].where((e) => e == null).length;

    if (emptyCount > 1) {
      setState(() {
        resultLabel = "⚠️ Error";
        resultValue = "Debes dejar solo un campo vacío para calcularlo.";
      });
      return;
    }

    if (selectedCalculation == "Monto o Valor Futuro") {
      if (P == null && FV != null && r != null && t != null) {
        P = FV * r / (pow(1 + r, t) - 1);
        periodicPaymentController.text = P.toStringAsFixed(2);
        resultLabel = "Pago Periódico (P)";
        resultValue = "$resultLabel = ${P.toStringAsFixed(2)}";
      } else if (r == null && FV != null && P != null && t != null) {
        r = calcularTasaInteres(FV, P, t);
        if (r != null) {
          rateController.text =
              (r * 100).toStringAsFixed(4); // Convertir a porcentaje
          resultLabel = "Tasa de Interés (r)";
          resultValue = "$resultLabel = ${(r * 100).toStringAsFixed(4)}%";
        } else {
          resultLabel = "⚠️ Error";
          resultValue = "No se pudo calcular la tasa de interés.";
        }
      } else if (t == null && FV != null && P != null && r != null) {
        t = log(FV * r / P + 1) / log(1 + r);
        periodsController.text = t.toStringAsFixed(2);
        resultLabel = "Número de Períodos (t)";
        resultValue = "$resultLabel = ${t.toStringAsFixed(2)}";
      } else if (FV == null && P != null && r != null && t != null) {
        FV = P * (pow(1 + r, t) - 1) / r;
        futureValueController.text = FV.toStringAsFixed(2);
        resultLabel = "Valor Futuro (FV)";
        resultValue = "$resultLabel = ${FV.toStringAsFixed(2)}";
      }

      setState(() {
        formula = "FV = P × ((1 + r)^t - 1) / r";
        formulaWithValues = "$resultLabel = ($P × ((1 + $r)^$t - 1) / $r)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cálculo de Anualidades")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => showDefinition = !showDefinition),
              child: Wrap(
                children: [
                  Icon(showDefinition
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down),
                  const SizedBox(width: 8),
                  const Text("¿Qué es el valor Futuro de una anualidad?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (showDefinition)
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
                      "El Valor Futuro (FV) de una anualidad es el monto acumulado de una serie de pagos periódicos realizados a lo largo del tiempo, que se invierten a una tasa de interés constante. En otras palabras, es el valor que tendría una serie de pagos futuros si se reinvirtieran a una tasa de interés específica durante el período de tiempo determinado.",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fórmula:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Math.tex(
                      r"FV = P \times \frac{(1 + r)^t - 1}{r}",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Donde:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text("• FV: Valor Futuro de la anualidad."),
                    const Text("• P: Pago periódico o renta."),
                    const Text(
                        "• r: Tasa de interés por período (en decimal)."),
                    const Text("• t: Número de períodos."),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildTextField("Pago Periódico (P)", periodicPaymentController),
            _buildTextField("Tasa de Interés (%) (r)", rateController),
            _buildTextField("Número de Períodos (t)", periodsController),
            _buildTextField("Valor Futuro (FV)", futureValueController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculate,
              child: const Text("Calcular"),
            ),
            const SizedBox(height: 20),
            if (resultValue.isNotEmpty) ...[
              Text("Fórmula:",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(formula),
              const SizedBox(height: 8),
              Text("Sustitución:",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(formulaWithValues),
              const SizedBox(height: 8),
              Text("Resultado:",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(resultValue,
                  style: const TextStyle(fontSize: 18, color: Colors.blue)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}
