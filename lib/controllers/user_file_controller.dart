import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserFileController {
  static const _fileName =
      'users.txt'; // nombres;apellidos;cedula;password;saldo

  /// Guarda un registro en el archivo plano; saldo inicia en 0.
  Future<void> registerUser({
    required String nombres,
    required String apellidos,
    required String cedula,
    required String password,
  }) async {
    final file = await _getFile();
    final linea = '$nombres;$apellidos;$cedula;$password;0\n';
    await file.writeAsString(linea, mode: FileMode.append);
  }

  /// Devuelve todas las líneas (por si luego quieres listarlas).
  Future<List<String>> readAll() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    return file.readAsLines();
  }

  /* Helpers */
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/economiapp';
    await Directory(path).create(recursive: true);
    return File('$path/$_fileName');
  }

  /// Devuelve true si cédula+password son correctos.
  /// Lanza 'not-found' si la cédula no existe.
  Future<bool> auth({required String cedula, required String password}) async {
    final rows = await readAll(); // puede ser []
    if (rows.isEmpty)
      throw Exception('file-empty'); // ningún usuario registrado

    // busca la cédula en cada línea segura
    for (final l in rows) {
      final parts = l.split(';');
      if (parts.length < 5) continue; // línea corrupta, la ignoramos
      if (parts[2] == cedula) {
        return parts[3] == password; // true o false
      }
    }
    throw Exception('not-found'); // no hubo coincidencia
  }

  Future<String?> findByCedula(String cedula) async {
    final rows = await readAll();
    for (final l in rows) {
      final p = l.split(';');
      if (p.length >= 5 && p[2] == cedula) return l;
    }
    return null;
  }

  // user_file_controller.dart
  Future<double> addSaldo(String cedula, double monto) async {
    final rows = await readAll();
    final List<String> updated = [];
    double nuevoSaldo = 0;

    for (final l in rows) {
      final p = l.split(';');
      if (p.length < 5) {
        // línea corrupta
        updated.add(l);
        continue;
      }

      if (p[2] == cedula) {
        // cédula encontrada
        final saldoActual = double.parse(p[4]);
        nuevoSaldo = saldoActual + monto;
        p[4] = nuevoSaldo.toStringAsFixed(2); // actualiza saldo
        updated.add(p.join(';'));
      } else {
        updated.add(l);
      }
    }

    // escribe todo el archivo de nuevo
    final file = await _getFile();
    await file.writeAsString(updated.join('\n'));

    return nuevoSaldo; // saldo actualizado
  }
}
