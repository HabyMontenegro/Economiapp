import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_math_fork/flutter_math.dart';

class SimpleInterestFvScreen extends StatefulWidget {
  const SimpleInterestFvScreen({super.key});

  @override
  _SimpleInterestFvScreenState createState() => _SimpleInterestFvScreenState();
}

class _SimpleInterestFvScreenState extends State<SimpleInterestFvScreen> {
  final TextEditingController principalController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController futureValueController = TextEditingController();

  bool showDefinition = false;
  String formula = "";
  String formulaWithValues = "";
  String resultLabel = "";
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
      P = FV! / (1 + ((R! / 100) * T!));
      print("Valor: ${(1 + ((R! / 100) * T!))}");
      principalController.text = P.toStringAsFixed(2);
      resultLabel = "P";
    } else if (R == null) {
      R = (FV! / P - 1) / T!;
      rateController.text = R.toStringAsFixed(4);
      resultLabel = "R";
    } else if (T == null) {
      T = (FV! / P - 1) / (R! / 100);
      if (selectedTimeUnit == "Días") {
        T = T * 365;
      } else if (selectedTimeUnit == "Meses") {
        T = T * 12;
      }
      timeController.text = T.toStringAsFixed(2);
      resultLabel = "T";
    } else if (FV == null) {
      FV = P * (1 + ((R / 100) * T));
      futureValueController.text = FV.toStringAsFixed(2);
      resultLabel = "FV";
    }

    setState(() {

      if(resultLabel == "FV"){

        formula = "FV = P (1 + R × T)";

      }else if(resultLabel == "P"){
        
        formula = "P = FV/(1 + R × T)";
      }
      else if(resultLabel == "T"){
        
        formula = "T = (FV/(P × R))-1";

      }else{
        formula = "R = (FV/(P × T))-1";
      }

      // Convertir T según la unidad de tiempo seleccionada
      double TConvertido = T ?? 0; // Si T es null, usar 0

      if (selectedTimeUnit == "Días") {
        TConvertido = TConvertido / 360; // Convertir días a años
      } else if (selectedTimeUnit == "Meses") {
        TConvertido = TConvertido / 12; // Convertir meses a años
      }

      if (resultLabel == "T") {
        // Convertir T en años, meses y días
        int anios = TConvertido.floor();
        double parteDecimalMeses = (TConvertido - anios) * 12;
        int meses = parteDecimalMeses.floor();
        int dias = ((parteDecimalMeses - meses) * 30).round();

        // Construcción del resultado formateado
        String tiempoFormateado = "${anios > 0 ? "$anios años" : ""} "
                "${meses > 0 ? "$meses meses" : ""} "
                "${dias > 0 ? "$dias días" : ""}"
            .trim();

        resultValue = "$resultLabel = $tiempoFormateado";
        formulaWithValues =
            "$resultLabel = ($P × (1 + $R × $tiempoFormateado))";
      } else {
        String valorCalculado = resultLabel == "FV"
            ? FV!.toStringAsFixed(2)
            : resultLabel == "R"
                ? "${R!.toStringAsFixed(4)}%"
                : P!.toStringAsFixed(2);

        resultValue = "$resultLabel = $valorCalculado";
        formulaWithValues = "$resultLabel = ($P × (1 + $R × $TConvertido))";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Valor Futuro - Interés Simple")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => showDefinition = !showDefinition),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8, // Espacio entre el icono y el texto
                children: [
                  Icon(showDefinition
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down),
                  Text(
                    "¿Qué es el Valor Futuro en Interés Simple?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                      "El valor futuro en interés simple se obtiene aplicando la tasa de interés sobre el capital inicial durante un tiempo determinado.",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fórmula:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Math.tex(
                      r"FV = P (1 + R \times T)",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Donde:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text("• FV: Valor futuro del capital."),
                    const Text("• P: Capital inicial o principal."),
                    const Text(
                        "• R: Tasa de interés por período (expresada en decimal)."),
                    const Text("• T: Tiempo o número de períodos."),
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
                const SizedBox(width: 10),
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
