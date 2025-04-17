import 'dart:math';  // Importa el paquete necesario

import 'package:flutter/material.dart';

class CapitalizationScreen extends StatefulWidget {
  const CapitalizationScreen({super.key});

  @override
  _CapitalizationScreenState createState() => _CapitalizationScreenState();
}

class _CapitalizationScreenState extends State<CapitalizationScreen> {
  final TextEditingController principalController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController futureValueController = TextEditingController();

  bool showDefinition = false;
  String formula = "";
  String formulaWithValues = "";
  String resultLabel = ""; // 🔥 Variable para mostrar P, R, T o FV
  String resultValue = "";
  List<String> timeUnits = ["Días", "Meses", "Años"];
  String selectedTimeUnit = "Años";

  void calculate() {
    double? P = double.tryParse(principalController.text);
    double? R = double.tryParse(rateController.text);
    double? T = double.tryParse(timeController.text);
    double? FV = double.tryParse(futureValueController.text);

    int emptyCount = [P, R, T, FV].where((e) => e == null).length;

    if (emptyCount > 1) {
      setState(() {
        resultLabel = "⚠️ Error";
        resultValue = "Debes dejar solo un campo vacío para calcularlo.";
      });
      return;
    }

    if (T != null) {
      if (selectedTimeUnit == "Días") {
        T = T / 365;
      } else if (selectedTimeUnit == "Meses") {
        T = T / 12;
      }
    }

    if (P == null) {
      P = FV! / pow(1 + R! / 100, T!);  // Usar pow correctamente con importación
      principalController.text = P.toStringAsFixed(2);
      resultLabel = "P";
    } else if (R == null) {
      R = ((FV! / P!) - 1) * 100 / T!;
      rateController.text = R.toStringAsFixed(2);
      resultLabel = "R";
    } else if (T == null) {
      T = (log(FV! / P!) / log(1 + R! / 100));
      timeController.text = T.toStringAsFixed(2);
      resultLabel = "T";
    } else if (FV == null) {
      FV = P! * pow(1 + R! / 100, T!);  // Usar pow correctamente con importación
      futureValueController.text = FV.toStringAsFixed(2);
      resultLabel = "FV";
    }

    setState(() {
      formula = "FV = P × (1 + R / 100)^T";
      formulaWithValues = "$resultLabel = $P × (1 + $R / 100)^$T";
      String unidadTiempo = selectedTimeUnit == "Días" ? "Días" : "Meses";
      resultValue =
      "$resultLabel = ${resultLabel == "FV" ? FV!.toStringAsFixed(2) : 
                      resultLabel == "R" ? R!.toStringAsFixed(2) : 
                      resultLabel == "T" ? "${T!.toStringAsFixed(2)} $unidadTiempo" : 
                      P!.toStringAsFixed(2)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capitalización Compuesta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => showDefinition = !showDefinition),
              child: Row(
                children: [
                  Icon(showDefinition
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down),
                  const SizedBox(width: 8),
                  const Text("¿Qué es la capitalización compuesta?",
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "La capitalización compuesta es el proceso mediante el cual el interés generado por una inversión se añade al capital, de modo que el interés siguiente se calcula sobre el capital original más los intereses previos."),
                    SizedBox(height: 8),
                    Text("Fórmula:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("FV = P × (1 + R / 100)^T"),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildTextField("Capital Inicial (P)", principalController),
            _buildTextField("Tasa de Interés (%) (R)", rateController),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Tiempo (T)", timeController),
                ),
                const SizedBox(width: 10), // Espacio entre los elementos
                DropdownButton<String>(
                  value: selectedTimeUnit,
                  items: timeUnits.map((String unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTimeUnit = newValue!;
                    });
                  },
                ),
              ],
            ),
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
