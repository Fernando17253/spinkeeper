import 'package:flutter/material.dart';
import 'package:spinkeeper/database_helper.dart';

class ParentListScreen extends StatefulWidget {
  const ParentListScreen({super.key});

  @override
  _ParentListScreenState createState() => _ParentListScreenState();
}

class _ParentListScreenState extends State<ParentListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Obtén los padres y maestros de la base de datos y muestra resultados en consola
    final parents = await dbHelper.getParents();
    final teachers = await dbHelper.getTeachers();

    print("Padres obtenidos: ${parents.length} - $parents");
    print("Maestros obtenidos: ${teachers.length} - $teachers");

    setState(() {
      _parents = parents;
      _teachers = teachers;
    });
  }

  Future<void> _deleteParent(int id) async {
    await dbHelper.deleteUser(id);
    _fetchData(); // Actualiza la lista después de eliminar
  }

  Future<void> _deleteTeacher(int id) async {
    await dbHelper.deleteTeacher(id);
    _fetchData(); // Actualiza la lista después de eliminar
  }

  void _confirmDelete(int id, String username, bool isTeacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTeacher ? 'Eliminar Maestro' : 'Eliminar Padre'),
        content: Text('¿Estás seguro de que deseas eliminar a $username?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isTeacher) {
                _deleteTeacher(id);
              } else {
                _deleteParent(id);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Padres y Maestros Registrados'),
        backgroundColor: const Color(0xFF00838F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFF80DEEA),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Padres Registrados',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _parents.isEmpty
                ? const Center(
                    child: Text('No hay padres registrados'),
                  )
                : Column(
                    children: _parents.map((parent) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            parent['username'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(parent['id'], parent['username'] ?? 'Sin nombre', false),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 30),
            const Text(
              'Maestros Registrados',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _teachers.isEmpty
                ? const Center(
                    child: Text('No hay maestros registrados'),
                  )
                : Column(
                    children: _teachers.map((teacher) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            teacher['name'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Materia: ${teacher['subject'] ?? 'No especificada'}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(teacher['id'], teacher['name'] ?? 'Sin nombre', true),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
