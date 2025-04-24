import 'package:economiapp/screens/TIR/tir_esperada.dart';
import 'package:economiapp/screens/TIR/tir_modificada.dart';
import 'package:economiapp/screens/TIR/tir_real.dart';
import 'package:economiapp/screens/TIR/tir_requerida.dart';
import 'package:economiapp/screens/TIR/tir_roi.dart';
import 'package:economiapp/screens/TIR/tir_simple.dart';
import 'package:flutter/material.dart';
import '../screens/intereses/simple/simple_interest_screen.dart';
import '../screens/intereses/compuesto/compound_interest_screen.dart';
import '../screens/anualidades/annuities_screen.dart';
import '../screens/anualidades/annuities_screen2.dart';
import '../screens/gradiente/gradient_Arit_screen.dart';
import '../screens/gradiente/gradient_Geo_screen.dart';
import '../screens/amortizacion/american_amortization_screen.dart';
import '../screens/amortizacion/german_amortization_screen.dart';
import '../screens/amortizacion/french_amortization_screen.dart';
import '../screens/capitalizacion/simple_capitalization.dart';
import '../screens/capitalizacion/compound_capitalization.dart';
import '../screens/capitalizacion/continuous_capitalization.dart';
import '../screens/intereses/simple/simple_interest_Fv_screen.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // CABECERA MEJORADA
          UserAccountsDrawerHeader(
            accountName: const Text("Usuario"),
            accountEmail: const Text("usuario@email.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.png'), // Opcional
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF04A665),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildExpansionTile(
                  context,
                  icon: Icons.percent,
                  title: "Interés",
                  items: {
                    "Simple": const SimpleInterestScreen(),
                    "Simple (FV)": const SimpleInterestFvScreen(),
                    "Compuesto": const CompoundInterestScreen(),
                  },
                ),
                _buildExpansionTile(
                  context,
                  icon: Icons.timeline,
                  title: "Anualidades",
                  items: {
                    "Valor Futuro": const AnnuitiesScreen(),
                    "Valor Presente": const AnnuitiesScreen2(),
                  },
                ),
                _buildExpansionTile(
                  context,
                  icon: Icons.trending_up,
                  title: "Gradientes",
                  items: {
                    "Aritmético": const GradientAritScreen(),
                    "Geométrico": const GradientGeomScreen(),
                  },
                ),
                _buildExpansionTile(
                  context,
                  icon: Icons.savings,
                  title: "Capitalización",
                  items: {
                    "Simple": const SimpleCapitalizationScreen(),
                    "Compuesta": const CapitalizationScreen(),
                    "Continua": const ContinuousCapitalizationScreen(),
                  },
                ),
                _buildExpansionTile(
                  context,
                  icon: Icons.account_balance,
                  title: "Sistemas de Amortización",
                  items: {
                    "Alemán": const GermanAmortizationScreen(),
                    "Francés": const FrenchAmortizationScreen(),
                    "Americano": const AmericanAmortizationScreen(),
                  },
                ),
                _buildExpansionTile(
                  context,
                  icon: Icons.account_balance,
                  title: "Tasa Interna de Retorno (TIR)",
                  items: {
                    "Simple": const TIRSimpleScreen(),
                    "Modificada": const TirmScreen(),
                    "Contable": const RoiScreen(),
                    "Requerida": const TrrCapmScreen(),
                    "Real": const RealRateScreen(),
                    "Esperada": const ExpectedReturnScreen()
                  },
                ),
                const Divider(), // Separador estético
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  ExpansionTile _buildExpansionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Map<String, Widget> items,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: items.entries.map((entry) {
        return ListTile(
          leading: const Icon(Icons.arrow_right, color: Colors.grey),
          title: Text(entry.key),
          onTap: () {
            Navigator.pop(context); // Cierra el Drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => entry.value),
            );
          },
        );
      }).toList(),
    );
  }
}
