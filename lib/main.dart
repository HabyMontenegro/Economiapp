import 'package:economiapp/core/provider/loan_provider.dart';
import 'package:economiapp/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoanProvider(),          // <- registra el provider una sola vez
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EconomiApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
