import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SimpleInterestScreen extends StatefulWidget {
  const SimpleInterestScreen({super.key});

  @override
  _SimpleInterestScreenState createState() => _SimpleInterestScreenState();
}

class _SimpleInterestScreenState extends State<SimpleInterestScreen> {
  final TextEditingController principalController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  bool showDefinition = false;
  String formula = "";
  String formulaWithValues = "";
  String resultLabel = ""; // 🔥 Variable para mostrar P, R, T o I
  String resultValue = "";
  List<String> timeUnits = ["Días", "Meses", "Años"];
  List<String> timeInteresUnits = ["Días", "Meses", "Años"];
  String selectedTimeUnit = "Años";
  String selectedInteresTimeUnit = "Años";

  void calculate() {
    double? P = double.tryParse(principalController.text);
    double? R = double.tryParse(rateController.text);
    double? T = double.tryParse(timeController.text);
    double? I = double.tryParse(interestController.text);

    int emptyCount = [P, R, T, I].where((e) => e == null).length;

    if (emptyCount > 1) {
      setState(() {
        resultLabel = "⚠️ Error";
        resultValue = "Debes dejar solo un campo vacío para calcularlo.";
      });
      return;
    }

    if (R != null && T != null) {
      if (selectedTimeUnit == "Días" && selectedInteresTimeUnit == "Años") {
        T = T / 360;
      } else if (selectedTimeUnit == "Meses" &&
          selectedInteresTimeUnit == "Años") {
        T = T / 12;
      }
    }

    if (P == null) {
      P = (I!) / ((R! / 100) * T!);
      principalController.text = P.toStringAsFixed(2);
      resultLabel = "P";
    } else if (R == null) {
      if (selectedInteresTimeUnit == "Años" && selectedTimeUnit == "Días") {
        R = (((I!) / (P * T!)) * (360)) * 100;
        print("R1: ${(((I!) / (P * T!)) * (360)) * 100}");
      } else if (selectedInteresTimeUnit == "Años" &&
          selectedTimeUnit == "Meses") {
        R = (((I!) / (P * T!)) * (12)) * 100;
      } else {
        R = (I!) / (P * T!);
      }
      rateController.text = R.toStringAsFixed(2);
      resultLabel = "R";
    } else if (T == null) {
      selectedTimeUnit = "Años";
      T = (I! * 100) / (P! * R!);

      if (selectedTimeUnit == "Días") {
        T = T * 360;
      } else if (selectedTimeUnit == "Meses") {
        T = T * 12;
      }
      timeController.text = T.toStringAsFixed(2);
      resultLabel = "T";
    } else if (I == null) {
      print("Valor de T: ${T}");
      print("Valor de R: ${R}");
      print("Valor de P: ${P}");

      I = (P * (R / 100) * T);
      interestController.text = I.toStringAsFixed(2);
      resultLabel = "I";
    }

    setState(() {
      if(resultLabel == "I"){
        formula = "I = (P × R × T)";
        formulaWithValues = "$resultLabel = ($P × ${R!/100} × $T)";
      }else if(resultLabel == "P"){
        formula = "P = I/(R × T)";
        formulaWithValues = "$resultLabel = $I/(${R!/100} × $T)";
      }
      else if(resultLabel == "T"){
        formula = "T = I/(P × R)";
        formulaWithValues = "$resultLabel = $I/($P × ${R!/100})";
      }else{
        formula = "R = I/(P × T)";
        formulaWithValues = "$resultLabel = $I/($P/ × $T)";

      }
      
      if (resultLabel == "T") {
        // Convertir T en años, meses y días
        int anios = T!.floor();
        double parteDecimalMeses = (T! - anios) * 12;
        int meses = parteDecimalMeses.floor();
        int dias = ((parteDecimalMeses - meses) * 30).round();

        // Construir el resultado formateado
        resultValue = "$resultLabel = "
                "${anios > 0 ? "$anios años" : ""} "
                "${meses > 0 ? "$meses meses" : ""} "
                "${dias > 0 ? "$dias días" : ""}"
            .trim();
      } else {
        resultValue =
            "$resultLabel = ${resultLabel == "I" ? I!.toStringAsFixed(2) : resultLabel == "R" ? R!.toStringAsFixed(2) : P!.toStringAsFixed(2)}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interés Simple")),
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
                  const Text("¿Qué es el interés simple?",
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
                      "El interés simple es el dinero que se obtiene o se paga por un préstamo o inversión en función del capital inicial, la tasa de interés y el tiempo.",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fórmula:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Math.tex(
                      r"I = P \times R \times T",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Donde:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text("• I: Interés generado."),
                    const Text("• P: Capital inicial o principal."),
                    const Text(
                        "• R: Tasa de interés por período (expresada en decimal)."),
                    const Text("• T: Tiempo o número de períodos."),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildTextField("Capital (P)", principalController),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      "Tasa de Interés (%) (R)", rateController),
                ),
                const SizedBox(width: 10), // Espacio entre los elementos
                DropdownButton<String>(
                  value: selectedInteresTimeUnit,
                  items: timeInteresUnits.map((String unit) {
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
            _buildTextField("Interés (I)", interestController),
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
