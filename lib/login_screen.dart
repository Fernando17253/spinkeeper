import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinkeeper/database_helper.dart';
import 'package:spinkeeper/home_screen.dart';
import 'package:spinkeeper/admin_home_screen.dart';
import 'package:spinkeeper/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final LocalAuthentication auth = LocalAuthentication();

  bool isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricPreference();
  }

  Future<void> _checkBiometricPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });

    // Intenta iniciar sesión con biometría automáticamente si está habilitada
    if (isBiometricEnabled) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor autentícate para iniciar sesión',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        _redirectToHome(); // Redirige automáticamente si la biometría es exitosa
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación biométrica')),
      );
    }
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final user = await dbHelper.loginUser(username, password);

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (user['userType'] == 'admin') {
        prefs.setBool('isAdmin', true);
        prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        prefs.setBool('isAdmin', false);
        prefs.setBool('isLoggedIn', true);
        prefs.setInt('parentId', user['id']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(parentId: user['id']),
          ),
        );
      }
    } else {
      _showRegisterDialog(username, password);
    }
  }

  void _showRegisterDialog(String username, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registro'),
          content: const Text('Los datos son incorrectos. ¿Deseas registrarte como padre?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Registrarse'),
            ),
          ],
        );
      },
    );
  }

  void _redirectToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
    } else {
      int? parentId = prefs.getInt('parentId');
      if (parentId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Iniciar Sesión'),
                    ),
                    if (isBiometricEnabled)
                      ElevatedButton(
                        onPressed: _authenticateWithBiometrics,
                        child: const Text('Iniciar Sesión con Huella Dactilar'),
                      ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
