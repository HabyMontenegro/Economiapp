import 'package:flutter/material.dart';
import 'dart:math';

class GradientAritScreen extends StatefulWidget {
  const GradientAritScreen({super.key});

  @override
  _GradientAritScreenState createState() => _GradientAritScreenState();
}

class _GradientAritScreenState extends State<GradientAritScreen> {
  final TextEditingController initialPaymentController =
      TextEditingController();
  final TextEditingController gradientController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  final TextEditingController presentValueController = TextEditingController();
  final TextEditingController futureValueController = TextEditingController();

  String resultLabel = "";
  String resultValue = "";

  void calculate() {
    double? A = double.tryParse(initialPaymentController.text);
    double? G = double.tryParse(gradientController.text);
    double? r = double.tryParse(interestRateController.text);
    double? n = double.tryParse(periodsController.text);
    double? PV = double.tryParse(presentValueController.text);
    double? FV = double.tryParse(futureValueController.text);

    if (r != null) {
      r = r / 100; // Convertir tasa de interés de % a decimal
    }

    if (A != null && G != null && r != null && n != null) {
      if (PV == null && FV == null) {
        // Cálculo de VP y FV corregidos
        double VP = calcularValorPresente(A, G, r, n);
        //double VP = valorPresente(A, G, r, n);
        double FV = calcularValorFuturo(A, G, r, n);

        setState(() {
          resultLabel = "Valor Presente (VP) y Valor Futuro (FV)";
          resultValue =
              "VP: ${VP.toStringAsFixed(2)}, FV: ${FV.toStringAsFixed(2)}";
          presentValueController.text = VP.toStringAsFixed(2);
          futureValueController.text = FV.toStringAsFixed(2);
        });
      } else if (PV == null && FV != null) {
        double VP = FV / pow(1 + r, n);
        setState(() {
          resultLabel = "Valor Presente (VP)";
          resultValue = VP.toStringAsFixed(2);
          presentValueController.text = resultValue;
        });
      } else if (FV == null && PV != null) {
        double FV = PV * pow(1 + r, n);
        setState(() {
          resultLabel = "Valor Futuro (FV)";
          resultValue = FV.toStringAsFixed(2);
          futureValueController.text = resultValue;
        });
      }
    } else {
      setState(() {
        resultLabel = "Error";
        resultValue = "Faltan datos para completar el cálculo.";
      });
    }
  }

  double calcularValorPresente(double A, double G, double r, double n) {
    if (r == 0) {
      throw ArgumentError("La tasa de interés no puede ser cero");
    }

    double factorAnualidad = (pow(1 + r, n) - 1) / (r * pow(1 + r, n));
    double factorGradiente =
        ((pow(1 + r, n) - 1) / (r * pow(1 + r, n))) - (n / pow(1 + r, n));

    double VP = (A * factorAnualidad) + ((G / r) * factorGradiente);
    return VP;
  }

  double calcularValorFuturo(double A, double G, double r, double n) {
    if (r == 0) {
      throw ArgumentError("La tasa de interés no puede ser cero");
    }

    double factorAnualidad = (pow(1 + r, n) - 1) / r;
    double factorGradiente = ((factorAnualidad - n) / r);

    double VF = (A * factorAnualidad) + (G * factorGradiente);
    return VF;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gradiente Aritmético")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Pago Inicial (A)", initialPaymentController),
            _buildTextField("Gradiente (G)", gradientController),
            _buildTextField("Tasa de Interés (%)", interestRateController),
            _buildTextField("Número de Periodos (n)", periodsController),
            _buildTextField("Valor Presente (PV)", presentValueController),
            _buildTextField("Valor Futuro (FV)", futureValueController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculate,
              child: const Text("Calcular"),
            ),
            const SizedBox(height: 20),
            if (resultValue.isNotEmpty) ...[
              Text(resultLabel,
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
