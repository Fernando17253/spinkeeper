import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinkeeper/teacher_register_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      bool canAuthenticate = await auth.canCheckBiometrics;
      if (canAuthenticate) {
        try {
          bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Por favor autentícate para activar la huella dactilar',
            options: const AuthenticationOptions(biometricOnly: true),
          );
          if (didAuthenticate) {
            setState(() {
              isBiometricEnabled = true;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('biometricEnabled', true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Huella dactilar activada correctamente')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error en la autenticación biométrica')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La autenticación biométrica no está disponible')),
        );
      }
    } else {
      setState(() {
        isBiometricEnabled = false;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('biometricEnabled', false);
    }
  }

  Future<void> _testBiometricAuth() async {
    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autenticación de prueba para verificar huella dactilar',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación exitosa')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación fallida')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en la autenticación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // Color más claro en la parte superior
              Color(0xFF80DEEA), // Color más oscuro en la parte inferior
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ajustes de la Aplicación',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Habilitar Huella Dactilar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    value: isBiometricEnabled,
                    onChanged: _toggleBiometric,
                    activeColor: const Color.fromARGB(255, 2, 86, 94), // Color del switch activado
                    secondary: const Icon(Icons.fingerprint, color: Color.fromARGB(255, 89, 210, 221)),
                  ),
                ),
                const SizedBox(height: 20),
                if (isBiometricEnabled)
                  ElevatedButton(
                    onPressed: _testBiometricAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromARGB(255, 64, 186, 197),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Probar Autenticación Biométrica',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                                  const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherRegisterScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color.fromARGB(255, 49, 207, 222),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Registrar maestros',
                    style: TextStyle(fontSize: 18),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
