import 'package:economiapp/controllers/user_file_controller.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cedula = TextEditingController();
  final _pass = TextEditingController();
  final _ctrl = UserFileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/EconomiApp-Icon.png", height: 100),
              const SizedBox(height: 20),
              const Text("Bienvenido",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Inicia sesión para continuar",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),

              // ── Cédula ───────────────────────────────────────────────
              TextField(
                controller: _cedula,
                keyboardType: TextInputType.number,
                decoration: _input("Cédula", Icons.person),
              ),
              const SizedBox(height: 15),

              // ── Contraseña ───────────────────────────────────────────
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: _input("Contraseña", Icons.lock),
              ),
              const SizedBox(height: 25),

              // ── Botón Iniciar ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Iniciar Sesión",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text("¿No tienes cuenta? Regístrate",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label, IconData icon) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      );

  Future<void> _login() async {
    final ced = _cedula.text.trim();
    final pwd = _pass.text;

    if (ced.isEmpty || pwd.isEmpty) {
      _msg('Completa ambos campos');
      return;
    }

    try {
      final userLine = await _ctrl.findByCedula(ced); // nuevo helper
      if (userLine == null) {
        _msg('La cédula no está registrada');
        return;
      }

      final parts = userLine.split(';');
      final nombres = parts[0];
      final saldo = double.parse(parts[4]);

      if (parts[3] != pwd) {
        _msg('Contraseña incorrecta');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            nombres: nombres,
            saldo: saldo,
            cedula: ced, // ← pasa la cédula real
          ),
        ),
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('not-found')) {
        _msg('La cédula no está registrada');
      } else if (msg.contains('file-empty')) {
        _msg('No hay usuarios registrados aún');
      } else {
        _msg('Error inesperado: $msg');
        print("Trae: $msg");
      }
    }
  }

  void _msg(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }
}
