import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';

class InterestCalculations {
  static double calculate(
    String type,
    Map<String, TextEditingController> controllers,
    String? emptyField,
    String timeUnit,
  ) {
    double? Ci = _parseOrNull(controllers["Valor Presente"]?.text);
    double? Cf = _parseOrNull(controllers["Valor Futuro"]?.text);
    double? r = _parseOrNull(controllers["Tasa"]?.text);
    double? I = _parseOrNull(controllers["Interés"]?.text);
    double? n = _parseOrNull(controllers["N° de periodos"]?.text);

    if (timeUnit == "Meses") n = (n ?? 0) / 12;
    if (timeUnit == "Días") n = (n ?? 0) / 365;
    if (r != null) r = r / 100; // Convertimos la tasa a decimal

    dev.log("Valores ingresados - Ci: $Ci, Cf: $Cf, r: $r, I: $I, n: $n");

    switch (type) {
      case "Interés Simple":
        return _calculateSimple(Ci, r, n, I, emptyField);
      case "Interés Compuesto":
        return _calculateCompound(Ci, Cf, r, n, emptyField);
      default:
        throw ArgumentError("Tipo de interés no válido.");
    }
  }

  static double _calculateSimple(
      double? Ci, double? r, double? n, double? I, String? missing) {
    if ([Ci, r, n, I].where((v) => v != null).length != 3) {
      throw ArgumentError("Debe haber exactamente un campo vacío.");
    }

    switch (missing) {
      case "Capital Inicial":
        return I! / (r! * n!);
      case "Tasa":
        return I! / (Ci! * n!);
      case "N° de periodos":
        return I! / (Ci! * r!);
      case "Interés":
        return Ci! * r! * n!;
      default:
        throw ArgumentError("Campo no válido.");
    }
  }

  static double _calculateCompound(
      double? Ci, double? Cf, double? r, double? n, String? missing) {
    if ([Ci, Cf, r, n].where((v) => v != null).length != 3) {
      throw ArgumentError("Debe haber exactamente un campo vacío.");
    }

    switch (missing) {
      case "Capital Inicial":
        return Cf! / pow((1 + r!), n!);
      case "Capital Final":
        return Ci! * pow((1 + r!), n!);
      case "Tasa":
        return pow(Cf! / Ci!, 1 / n!) - 1;
      case "N° de periodos":
        return log(Cf! / Ci!) / log(1 + r!);
      default:
        throw ArgumentError("Campo no válido.");
    }
  }

  static String getCalculationSteps(String type, String missingField,
      Map<String, TextEditingController> controllers, String timeUnit) {
    double? Ci = _parseOrNull(controllers["Valor Presente"]?.text);
    double? Cf = _parseOrNull(controllers["Capital Final"]?.text);
    double? r = _parseOrNull(controllers["Tasa"]?.text);
    double? I = _parseOrNull(controllers["Interés"]?.text);
    double? n = _parseOrNull(controllers["N° de periodos"]?.text);

    if (timeUnit == "Meses") n = (n ?? 0) / 12;
    if (timeUnit == "Días") n = (n ?? 0) / 365;
    if (r != null) r = r / 100;

    switch (type) {
      case "Interés Simple":
        switch (missingField) {
          case "Valor Presente":
            return "Ci = I / (r * n)\nCi = ${I!} / (${r!} * ${n!})\nCi = ${I / (r * n)}";
          case "Tasa":
            return "r = I / (Ci * n)\nr = ${I!} / (${Ci!} * ${n!})\nr = ${I / (Ci * n)}";
          case "N° de periodos":
            return "n = I / (Ci * r)\nn = ${I!} / (${Ci!} * ${r!})\nn = ${I / (Ci * r)}";
          case "Interés":
            return "I = Ci * r * n\nI = ${Ci!} * ${r!} * ${n!}\nI = ${Ci * r * n}";
        }
        break;
      case "Interés Compuesto":
        switch (missingField) {
          case "Valor Presente":
            return "Ci = Cf / (1 + r)^n\nCi = ${Cf!} / (1 + ${r!})^${n!}\nCi = ${Cf / pow(1 + r, n)}";
          case "Valor Futuro":
            return "Cf = Ci * (1 + r)^n\nCf = ${Ci!} * (1 + ${r!})^${n!}\nCf = ${Ci * pow(1 + r, n)}";
          case "Tasa":
            return "r = (Cf / Ci)^(1/n) - 1\nr = (${Cf!} / ${Ci!})^(1/${n!}) - 1\nr = ${pow(Cf / Ci, 1 / n) - 1}";
          case "N° de periodos":
            return "n = log(Cf / Ci) / log(1 + r)\nn = log(${Cf!} / ${Ci!}) / log(1 + ${r!})\nn = ${log(Cf / Ci) / log(1 + r)}";
        }
    }
    return "Error en la fórmula.";
  }

  static double? _parseOrNull(String? text) {
    return text != null && text.isNotEmpty ? double.tryParse(text) : null;
  }
}
