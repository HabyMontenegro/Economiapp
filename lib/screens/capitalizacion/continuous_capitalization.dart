import 'package:flutter/material.dart';
import 'dart:math'; // Para usar la constante e

class ContinuousCapitalizationScreen extends StatefulWidget {
  const ContinuousCapitalizationScreen({super.key});

  @override
  _ContinuousCapitalizationScreenState createState() =>
      _ContinuousCapitalizationScreenState();
}

class _ContinuousCapitalizationScreenState
    extends State<ContinuousCapitalizationScreen> {
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

    // Si T no es null, convierte la unidad de tiempo.
    if (T != null) {
      if (selectedTimeUnit == "Días") {
        T = T / 365;
      } else if (selectedTimeUnit == "Meses") {
        T = T / 12;
      }
    }

    // Calcular el valor de P si es null
    if (P == null) {
      if (FV != null && R != null && T != null) {
        P = FV / exp((R/100) * T); // Calcula P
        principalController.text = P.toStringAsFixed(2); // Asegúrate de mostrar el resultado
        resultLabel = "P"; // Indica que se calculó P
        print("El valor de P: ${P}");
      } else {
        setState(() {
          resultLabel = "⚠️ Error";
          resultValue = "Faltan campos para calcular el capital inicial.";
        });
        return;
      }
    }
    // Calcular la tasa de interés (R) si es null
    else if (R == null) {
      if (FV != null && P != null && T != null) {
        R = log(FV / P) / T; // log(FV / P) / T
        R = (R * 100);
        rateController.text =
            (R).toStringAsFixed(2); // Para mostrar en porcentaje
        resultLabel = "R";
      } else {
        setState(() {
          resultLabel = "⚠️ Error";
          resultValue = "Faltan campos para calcular la tasa de interés.";
        });
        return;
      }
    }
    // Calcular el tiempo (T) si es null
    else if (T == null) {
      if (FV != null && P != null && R != null) {
        T = log(FV / P) / R; // log(FV / P) / R
        T = (T * 100);
        timeController.text = T.toStringAsFixed(2);
        resultLabel = "T";
      } else {
        setState(() {
          resultLabel = "⚠️ Error";
          resultValue = "Faltan campos para calcular el tiempo.";
        });
        return;
      }
    }
    // Calcular el valor futuro (FV) si es null
    else if (FV == null) {
      if (P != null && R != null && T != null) {
        FV = P * exp(R * (T / 100)); // e^(R * T)
        futureValueController.text = FV.toStringAsFixed(2);
        resultLabel = "FV";
      } else {
        setState(() {
          resultLabel = "⚠️ Error";
          resultValue = "Faltan campos para calcular el valor futuro.";
        });
        return;
      }
    }

    setState(() {
      formula = "FV = P × e^(R × T)";
      formulaWithValues =
          "$resultLabel = (${P != null ? P!.toStringAsFixed(2) : "?"} × e^($R × $T))";
      String unidadTiempo = selectedTimeUnit == "Días" ? "Días" : "Meses";
      resultValue = "$resultLabel = ${resultLabel == "FV" ? (FV != null ? FV!.toStringAsFixed(2) : "?") : 
                         resultLabel == "R" ? (R != null ? R!.toStringAsFixed(2) : "?") : 
                         resultLabel == "T" ? (T != null ? "${T!.toStringAsFixed(2)} $unidadTiempo" : "?") : 
                         resultLabel == "P" ? (P != null ? P!.toStringAsFixed(2) : "?") : "?"}";

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capitalización Continua")),
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
                  const Text("¿Qué es la capitalización continua?",
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
                        "La capitalización continua es un proceso mediante el cual los intereses se calculan de manera continua en vez de hacerse en intervalos regulares. Se usa la constante de Euler (e) para este cálculo."),
                    SizedBox(height: 8),
                    Text("Fórmula: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("FV = P × e^(R × T)"),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildTextField("Capital (P)", principalController),
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
