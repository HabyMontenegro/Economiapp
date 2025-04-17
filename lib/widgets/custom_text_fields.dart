class CustomTextFields {
  static final Map<String, List<String>> fieldMappings = {
    "Interés Simple": [ "Interés", "Capital", "Tasa", "N° de periodos"],
    "Interés Compuesto": ["Valor Presente", "Tasa", "N° de periodos", "Valor Futuro"],
    "Anualidades": ["Valor Presente", "Renta", "Tasa", "N° de periodos"],
    "Gradiente": ["Valor Inicial", "Tasa", "Tiempo"],
    "Americano": ["Capital", "Tasa", "Tiempo"],
    "Alemán": ["Capital", "Tasa", "Tiempo", "Cuota"],
    "Francés": ["Capital", "Tasa", "Tiempo", "Intereses"],
  };

  static List<String> getFieldsForTitle(String title) {
    return fieldMappings[title] ?? [];
  }
}
