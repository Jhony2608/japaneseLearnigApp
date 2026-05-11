import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModuleDetailScreen extends StatelessWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Módulo: $moduleId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 80, color: Color(0xFF58CC02)),
            const SizedBox(height: 24),
            Text(
              'Estás en el módulo $moduleId',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Pronto añadiremos los ejercicios interactivos aquí.'),
          ],
        ),
      ),
    );
  }
}
