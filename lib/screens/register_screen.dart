import 'package:economiapp/controllers/user_file_controller.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _cedula = TextEditingController();
  final _pass = TextEditingController();
  final _ctrl = UserFileController();

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _cedula.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Crear cuenta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/EconomiApp-Icon.png", height: 80),
              const SizedBox(height: 20),
              const Text("Regístrate",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Crea tu cuenta para continuar",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),

              // ── Nombres ──────────────────────────────────────────────
              TextField(
                controller: _nombres,
                decoration: _inputDeco("Nombres", Icons.badge_outlined),
              ),
              const SizedBox(height: 15),

              // ── Apellidos ────────────────────────────────────────────
              TextField(
                controller: _apellidos,
                decoration: _inputDeco("Apellidos", Icons.badge),
              ),
              const SizedBox(height: 15),

              // ── Cédula ───────────────────────────────────────────────
              TextField(
                controller: _cedula,
                keyboardType: TextInputType.number,
                decoration: _inputDeco("Cédula", Icons.credit_card),
              ),
              const SizedBox(height: 15),

              // ── Contraseña ───────────────────────────────────────────
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: _inputDeco("Contraseña", Icons.lock),
              ),
              const SizedBox(height: 25),

              // ── Botón Registrar ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. leer todos los usuarios
                    final rows = await _ctrl.readAll();
                    final exists =
                        rows.any((line) => line.split(';')[2] == _cedula.text);

                    if (exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Esa cédula ya está registrada')),
                      );
                      return; // aborta el registro
                    }

                    // 2. guardar
                    await _ctrl.registerUser(
                      nombres: _nombres.text,
                      apellidos: _apellidos.text,
                      cedula: _cedula.text,
                      password: _pass.text,
                    );

                    // 3. limpiar campos
                    _nombres.clear();
                    _apellidos.clear();
                    _cedula.clear();
                    _pass.clear();

                    // 4. feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario guardado')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Registrar",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("¿Ya tienes cuenta? Inicia sesión",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      );
}
