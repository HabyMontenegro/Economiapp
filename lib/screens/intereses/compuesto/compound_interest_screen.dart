import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_math_fork/flutter_math.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  _CompoundInterestScreenState createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final TextEditingController principalController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController periodsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool showDefinition = false;
  String formula = "";
  String formulaWithValues = "";
  String resultLabel = "";
  String resultValue = "";
  List<String> timeUnits = ["Días", "Meses", "Años"];
  String selectedTimeUnit = "Años";

  List<String> CapiUnits = ["Sin Capitalizar", "Diaria","Quincenal", "Mensual","Trimestral","Semestral", "Anual"];
  String selectedCapiUnit = "Sin Capitalizar";

  void calculate() {
    double? P = double.tryParse(principalController.text);
    double? R = double.tryParse(rateController.text);
    double? T = double.tryParse(timeController.text);
    double? A = double.tryParse(amountController.text);
    int? n = int.tryParse(periodsController.text);

    int emptyCount = [P, R, T, A].where((e) => e == null).length;

    if (emptyCount > 1) {
      setState(() {
        resultLabel = "⚠️ Error";
        resultValue = "Debes dejar solo un campo vacío para calcularlo.";
      });
      return;
    }

    // Ajustar el tiempo según la unidad seleccionada
    /*if (selectedTimeUnit == "Días") {
      T = T! / 365;
    } else if (selectedTimeUnit == "Meses") {
      T = T! / 12;
    }*/

    // Ajustar n según la frecuencia de capitalización
    if (selectedCapiUnit == "Diaria") {
      n = 365;
    } else if (selectedCapiUnit == "Quincenal") {
      n = 24;
    } else if(selectedCapiUnit == "Mensual"){
      n = 12;
    } else if(selectedCapiUnit == "Trimestral"){
      n = 4;
    } else if(selectedCapiUnit == "Semestral"){
      n = 2;
    } else if(selectedCapiUnit == "Anual"){
      n = 1;
    }else {
      n = 0; // Sin capitalización
    }

    if (selectedCapiUnit != "Sin Capitalizar") {
      if (P == null) {
        P = A! / pow((1 + (R! / (n! * 100))), n! * T!);
        principalController.text = P.toStringAsFixed(2);
        resultLabel = "P";
      } else if (R == null) {
        R = (pow(A! / P, 1 / (n! * T!)) - 1) * n! * 100;
        rateController.text = R.toStringAsFixed(2);
        resultLabel = "R";
      } else if (T == null) {
        /*print ("Valor de R: ${R}");
        print ("Valor de A: ${A}");
        print ("Valor de P: ${P}");*/

        T = log(A! / P) / (n! * log(1 + (R! / 100) / n!));
        timeController.text = T.toStringAsFixed(2);
        resultLabel = "T";
      } else if (A == null) {
        /*print ("Valor de R: ${R}");
        print ("Valor de T: ${T}");
        print ("Valor de P: ${P}");*/
        A = P * pow((1 + ((R / n) / 100)), n * T);
        amountController.text = A.toStringAsFixed(2);
        resultLabel = "A";
      } else if (n == null) {
        // Despejando n numéricamente usando pruebas iterativas
        double left = 1;
        double right =
            1000; // Supongamos que no hay más de 1000 capitalizaciones por año
        double tolerance = 0.0001;
        double mid = 0;

        while ((right - left) > tolerance) {
          mid = (left + right) / 2;
          double calculatedA = P * pow((1 + R! / (mid * 100)), mid * T!);

          if ((calculatedA - A!).abs() < tolerance) {
            break;
          } else if (calculatedA < A) {
            left = mid;
          } else {
            right = mid;
          }
        }

        n = mid.round();
        periodsController.text = n.toString();
        resultLabel = "n";
      }

      setState(() {
        formula = "A = P × (1 + R/n)^(nT)";

        if (resultLabel == "A") {
          formulaWithValues = "$resultLabel = $P × (1 + $R% / $n) ^ ($n × $T)";
        } else if (resultLabel == "P") {
          formulaWithValues = "$resultLabel = $A / (1 + $R% / $n) ^ ($n × $T)";
        } else if (resultLabel == "T") {
          formulaWithValues =
              "$resultLabel = log($A / $P) / ($n × log(1 + $R% / $n))";
        } else if (resultLabel == "R") {
          formulaWithValues =
              "$resultLabel = (($A / $P)^(1 / ($n × $T))) - 1 × $n × 100";
        } else if (resultLabel == "n") {
          formulaWithValues = "n = Iteración numérica para encontrar el valor";
        }

        resultValue = "$resultLabel = " +
            (resultLabel == "P"
                ? P!.toStringAsFixed(2)
                : resultLabel == "R"
                    ? "${R!.toStringAsFixed(2)}%"
                    : resultLabel == "T"
                        ? T!.toStringAsFixed(2)
                        : resultLabel == "n"
                            ? n!.toString()
                            : A!.toStringAsFixed(2));
      });
    } else {
      if (P == null) {
        P = A! / pow((1 + R! / 100), T!);
        principalController.text = P.toStringAsFixed(2);
        resultLabel = "P";
      } else if (R == null) {
        R = (pow(A! / P, 1 / T!) - 1) * 100;
        rateController.text = R.toStringAsFixed(2);
        resultLabel = "R";
      } else if (T == null) {
        T = log(A! / P) / log(1 + (R! / 100));
        timeController.text = T.toStringAsFixed(2);

        print("Valor de R: ${R}");
        print("Valor de A: ${A}");
        print("Valor de P: ${P}");
        print("Logaritmo: ${log(A! / P)}");

        resultLabel = "T";
      } else if (A == null) {
        A = P * pow((1 + R / 100), T);
        amountController.text = A.toStringAsFixed(2);
        resultLabel = "A";
      }

      setState(() {
        formula = "A = P × (1 + R) ^ T";
        if (resultLabel == "A") {
          formulaWithValues = "$resultLabel = $P × (1 + $R%) ^ $T";
        } else if (resultLabel == "P") {
          formulaWithValues = "$resultLabel = $A/(1 + $R%) ^ $T";
        } else if (resultLabel == "T") {
          formulaWithValues = "$resultLabel = log($A/$P) / log(1 + $R%)";
        } else {
          formulaWithValues = "$resultLabel = (($A / $P)^(1/$T)) - 1";
        }
        resultValue =
            "$resultLabel = ${resultLabel == "P" ? P!.toStringAsFixed(2) : resultLabel == "R" ? "${R!.toStringAsFixed(2)}%" : resultLabel == "T" ? T!.toStringAsFixed(2) : A!.toStringAsFixed(2)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interés Compuesto")),
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
                  const Text("¿Qué es el interés compuesto?",
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
                      "El interés compuesto es el interés que se calcula sobre el capital inicial y los intereses acumulados en períodos anteriores.",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fórmula:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Math.tex(
                      r"A = P \times (1 + R) ^ T",
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Donde:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                        "• A: Monto final después de aplicar el interés compuesto."),
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
            DropdownButton<String>(
              value: selectedCapiUnit,
              items: CapiUnits.map((String unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCapiUnit = newValue!;
                });
              },
            ),
            _buildTextField("Monto Final (A)", amountController),
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
