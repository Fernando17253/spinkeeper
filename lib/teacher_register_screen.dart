import 'package:flutter/material.dart';
import 'package:spinkeeper/database_helper.dart';

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  _TeacherRegisterScreenState createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> _registerTeacher() async {
    String name = _nameController.text;
    String subject = _subjectController.text;

    if (name.isNotEmpty && subject.isNotEmpty) {
      await dbHelper.registerTeacher(name, subject);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maestro registrado con éxito')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Maestro'),
        backgroundColor: const Color(0xFF00838F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // Color claro en la parte superior
              Color(0xFF80DEEA), // Color oscuro en la parte inferior
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
                  'Registro de Maestro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 10, 8, 8),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Maestro',
                    filled: true,
                    fillColor: const Color.fromARGB(179, 155, 155, 155),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Materia',
                    filled: true,
                    fillColor: const Color.fromARGB(179, 146, 146, 146),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerTeacher,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromARGB(255, 213, 238, 240),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Registrar Maestro',
                      style: TextStyle(fontSize: 18),
                    ),
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
