import 'package:flutter/material.dart';
import 'dart:math';

class GradientGeomScreen extends StatefulWidget {
  const GradientGeomScreen({super.key});

  @override
  _GradientGeomScreenState createState() => _GradientGeomScreenState();
}

class _GradientGeomScreenState extends State<GradientGeomScreen> {
  final TextEditingController initialPaymentController = TextEditingController();
  final TextEditingController gradientRateController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  final TextEditingController presentValueController = TextEditingController();
  final TextEditingController futureValueController = TextEditingController();

  String resultLabel = "";
  String resultValue = "";

  void calculate() {
    double A = double.tryParse(initialPaymentController.text) ?? 0.0;
    double g = double.tryParse(gradientRateController.text) ?? 0.0;
    double r = double.tryParse(interestRateController.text) ?? 0.0;
    double n = double.tryParse(periodsController.text) ?? 0.0;

    double? PV = double.tryParse(presentValueController.text);
    double? FV = double.tryParse(futureValueController.text);

    // Convertir porcentajes a decimales
    r = r / 100;
    g = g / 100;

    if (r == g) {
      setState(() {
        resultLabel = "Error";
        resultValue = "La tasa de interés no puede ser igual a la tasa de gradiente.";
      });
      return;
    }

    if (A > 0 && g >= 0 && r > 0 && n > 0) {
      if (PV == null && FV == null) {
        double VP = calcularValorPresente(A, g, r, n);
        double VF = calcularValorFuturo(A, g, r, n);

        setState(() {
          resultLabel = "Valor Presente (VP) y Valor Futuro (FV)";
          resultValue = "VP: ${VP.toStringAsFixed(2)}, FV: ${VF.toStringAsFixed(2)}";
          presentValueController.text = VP.toStringAsFixed(2);
          futureValueController.text = VF.toStringAsFixed(2);
        });

        print("VF: ${VF} - VP: ${VP}");
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

  double calcularValorPresente(double A, double g, double r, double n) {
    return A * (1 - pow((1 + g) / (1 + r), n)) / (r - g);
  }

  double calcularValorFuturo(double A, double g, double r, double n) {
    return A * (pow(1 + r, n) - pow(1 + g, n)) / (r - g);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gradiente Geométrico")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Pago Inicial (A)", initialPaymentController),
            _buildTextField("Tasa de Gradiente (%)", gradientRateController),
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
              Text(resultLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(resultValue, style: const TextStyle(fontSize: 18, color: Colors.blue)),
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
