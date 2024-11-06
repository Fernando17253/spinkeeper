import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinkeeper/database_helper.dart';

class ChildRegisterScreen extends StatefulWidget {
  final int parentId;

  const ChildRegisterScreen({super.key, required this.parentId});

  @override
  _ChildRegisterScreenState createState() => _ChildRegisterScreenState();
}

class _ChildRegisterScreenState extends State<ChildRegisterScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdateController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> _registerChild() async {
    String name = _nameController.text;
    String address = _addressController.text;
    String birthdate = _birthdateController.text;

    if (name.isNotEmpty && address.isNotEmpty && birthdate.isNotEmpty) {
      await dbHelper.registerChild(widget.parentId, name, address, birthdate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hijo registrado con éxito')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Hijo'),
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
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _birthdateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerChild,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF00838F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Registrar Hijo',
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
