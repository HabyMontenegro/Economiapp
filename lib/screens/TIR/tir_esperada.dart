import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ExpectedReturnScreen extends StatefulWidget {
  const ExpectedReturnScreen({Key? key}) : super(key: key);

  @override
  State<ExpectedReturnScreen> createState() => _ExpectedReturnScreenState();
}

class _ExpectedReturnScreenState extends State<ExpectedReturnScreen> {
  final List<TextEditingController> retornoControllers = [];
  final List<TextEditingController> probabilidadControllers = [];
  double? resultado;

  void calcularTasaEsperada() {
    double suma = 0;
    bool hayError = false;

    for (int i = 0; i < retornoControllers.length; i++) {
      double? retorno = double.tryParse(retornoControllers[i].text);
      double? probabilidad = double.tryParse(probabilidadControllers[i].text);

      if (retorno == null || probabilidad == null) {
        hayError = true;
        break;
      }

      suma += retorno * probabilidad;
    }

    if (!hayError) {
      setState(() {
        resultado = suma;
      });
    } else {
      setState(() {
        resultado = null;
      });
    }
  }

  void agregarCampos() {
    setState(() {
      retornoControllers.add(TextEditingController());
      probabilidadControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    for (var controller in retornoControllers) {
      controller.dispose();
    }
    for (var controller in probabilidadControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasa de Retorno Esperada'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: const Text(
                "¿Qué es la Tasa de Retorno Esperada?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Es el rendimiento promedio ponderado de una inversión considerando diferentes escenarios con sus respectivas probabilidades.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Math.tex(
                    r"\text{Tasa Esperada} = \sum (R_i \times P_i)",
                    textStyle: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: agregarCampos,
              icon: const Icon(Icons.add),
              label: const Text("Agregar escenario"),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < retornoControllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: retornoControllers[i],
                        decoration: const InputDecoration(
                          labelText: 'Retorno (%)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: probabilidadControllers[i],
                        decoration: const InputDecoration(
                          labelText: 'Probabilidad (0-1)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: calcularTasaEsperada,
                child: const Text('Calcular'),
              ),
            ),
            const SizedBox(height: 20),
            if (resultado != null)
              Center(
                child: Text(
                  "Tasa de Retorno Esperada: ${resultado!.toStringAsFixed(2)}%",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            if (resultado == null && retornoControllers.isNotEmpty)
              const Center(
                child: Text(
                  "Por favor, ingresa valores válidos.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
