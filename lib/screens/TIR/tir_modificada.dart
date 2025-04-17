import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';

class TirmScreen extends StatefulWidget {
  const TirmScreen({super.key});

  @override
  State<TirmScreen> createState() => _TirmScreenState();
}

class _TirmScreenState extends State<TirmScreen> {
  final List<Map<String, TextEditingController>> cashFlows = [
    {
      'valor': TextEditingController(),
      'periodo': TextEditingController(),
    },
  ];

  final reinversionRateController = TextEditingController();
  final financiamientoRateController = TextEditingController();

  double? tirmResult;
  double? pvNegativos;
  double? fvPositivos;
  String? validationError;

  void calcularTIRM() {
    // Reset previous error
    setState(() {
      validationError = null;
    });

    // Parse rates
    final reinversionRate =
        double.tryParse(reinversionRateController.text.replaceAll(',', '.')) ?? 0;
    final financiamientoRate =
        double.tryParse(financiamientoRateController.text.replaceAll(',', '.')) ?? 0;

    double fvPos = 0;
    double pvNeg = 0;
    int maxPosPeriodo = 0;
    bool hasNegativo = false;
    bool hasPositivo = false;

    // First pass: determine max positive period and validation
    for (var flujo in cashFlows) {
      final valor =
          double.tryParse(flujo['valor']!.text.replaceAll(',', '.')) ?? 0;
      final periodo = int.tryParse(flujo['periodo']!.text) ?? 0;
      if (valor > 0) {
        hasPositivo = true;
        maxPosPeriodo = max(maxPosPeriodo, periodo);
      }
      if (valor < 0) {
        hasNegativo = true;
      }
    }

    // Validate presence of negative and positive flows
    if (!hasNegativo) {
      setState(() {
        validationError =
            'Debes ingresar al menos un flujo NEGATIVO (inversión inicial).';
        tirmResult = null;
      });
      return;
    }
    if (!hasPositivo) {
      setState(() {
        validationError =
            'Debes ingresar al menos un flujo POSITIVO (retorno).';
        tirmResult = null;
      });
      return;
    }
    if (maxPosPeriodo <= 0) {
      setState(() {
        validationError =
            'El período máximo de flujos positivos debe ser mayor que 0.';
        tirmResult = null;
      });
      return;
    }

    // Second pass: compute PV and FV
    for (var flujo in cashFlows) {
      final valor =
          double.tryParse(flujo['valor']!.text.replaceAll(',', '.')) ?? 0;
      final periodo = int.tryParse(flujo['periodo']!.text) ?? 0;
      if (valor > 0) {
        fvPos += valor * pow(1 + reinversionRate, maxPosPeriodo - periodo);
      } else {
        pvNeg += valor / pow(1 + financiamientoRate, periodo);
      }
    }

    // Final calculation
    final tirm = pow(fvPos / -pvNeg, 1 / maxPosPeriodo) - 1;
    setState(() {
      tirmResult = tirm.toDouble();
      pvNegativos = pvNeg;
      fvPositivos = fvPos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasa Interna de Retorno Modificada (TIRM)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: const Text('¿Qué es la TIRM?'),
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "La Tasa Interna de Retorno Modificada (TIRM) es una métrica financiera que mejora la TIR tradicional al considerar una tasa de reinversión para los flujos positivos y una tasa de financiamiento para los flujos negativos. Es más realista en proyectos con flujos de caja irregulares.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Math.tex(
                    r"TIRM = \left( \frac{FV_{positivos}}{-PV_{negativos}} \right)^{\frac{1}{n}} - 1",
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Donde:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                          '- FVₚₒₛᵢₜᵢᵥₒₛ: Valor futuro de los flujos de caja positivos, reinvertidos a una tasa dada.'),
                      Text(
                          '- PVₙₑgₐₜᵢᵥₒₛ: Valor presente de los flujos negativos, descontados con la tasa de financiamiento.'),
                      Text('- n: Número total de periodos.'),
                    ],
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    '⚠️ Recuerda: ingresa NEGATIVO para inversiones (por ejemplo, inversión inicial).',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (validationError != null) ...[
              Text(
                validationError!,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            ...cashFlows.map((controladores) {
              final index = cashFlows.indexOf(controladores);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controladores['valor'],
                        decoration:
                            const InputDecoration(labelText: 'Flujo de caja'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controladores['periodo'],
                        decoration:
                            const InputDecoration(labelText: 'Periodo'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          cashFlows.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { cashFlows.add({
                  'valor': TextEditingController(),
                  'periodo': TextEditingController(),
                });});
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar flujo'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: reinversionRateController,
              decoration: const InputDecoration(
                  labelText: 'Tasa de reinversión (decimal)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: financiamientoRateController,
              decoration: const InputDecoration(
                  labelText: 'Tasa de financiamiento (decimal)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: calcularTIRM,
                child: const Text('Calcular TIRM'),
              ),
            ),
            const SizedBox(height: 24),
            if (tirmResult != null) ...[
              Text(
                  'PV de flujos negativos: ${pvNegativos!.toStringAsFixed(2)}'),
              Text(
                  'FV de flujos positivos: ${fvPositivos!.toStringAsFixed(2)}'),
              Text('TIRM: ${(tirmResult! * 100).toStringAsFixed(2)}%'),
            ],
          ],
        ),
      ),
    );
  }
}
