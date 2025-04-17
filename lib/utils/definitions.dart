Map<String, String> definitions = {
  "Interés Simple": 
      "El interés simple es una forma de calcular los intereses generados "
      "por un capital inicial a lo largo del tiempo, basado en una tasa "
      "de interés fija. Se calcula con la fórmula:\n\n"
      "I = C × r × t\n\n"
      "Donde:\n"
      "- I es el interés generado.\n"
      "- C es el capital inicial.\n"
      "- r es la tasa de interés (en decimal).\n"
      "- t es el tiempo.",

  "Interés Compuesto": 
      "El interés compuesto es aquel en el que los intereses generados "
      "se suman al capital inicial para generar más intereses en el futuro. "
      "Se calcula con la fórmula:\n\n"
      "A = C (1 + r)^t\n\n"
      "Donde:\n"
      "- A es el monto final.\n"
      "- C es el capital inicial.\n"
      "- r es la tasa de interés.\n"
      "- t es el tiempo.",

  "Descuento Simple": 
      "El descuento simple es un método de cálculo financiero donde "
      "se descuenta una cantidad fija de dinero al capital a pagar en el futuro. "
      "Se usa en transacciones comerciales y en pagarés."
};

String getDefinition(String title) {
  return definitions[title] ?? "No hay definición disponible para este cálculo.";
}
