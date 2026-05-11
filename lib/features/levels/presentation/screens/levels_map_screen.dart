import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';
import '../providers/levels_provider.dart';

class LevelsMapScreen extends ConsumerWidget {
  const LevelsMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesProvider);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camino de Aprendizaje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (modules) {
          if (modules.isEmpty) {
            return const Center(child: Text('No hay niveles disponibles aún.'));
          }

          return progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (progress) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 40),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  
                  // Lógica de bloqueo
                  bool isUnlocked = false;
                  if (index == 0) {
                    isUnlocked = true; // El primer nivel siempre está desbloqueado
                  } else {
                    // Está desbloqueado si el módulo ANTERIOR está completado
                    final prevModule = modules[index - 1];
                    final prevProgress = progress.where((p) => p.moduleId == prevModule.id && p.isCompleted).isNotEmpty;
                    isUnlocked = prevProgress;
                  }

                  // Lógica del Zigzag (0, 0.5, 0, -0.5)
                  double alignment = 0;
                  if (index % 4 == 1) alignment = 0.5;
                  else if (index % 4 == 3) alignment = -0.5;

                  return Align(
                    alignment: Alignment(alignment, 0),
                    child: _LevelNode(
                      title: module.title,
                      isUnlocked: isUnlocked,
                      onTap: () {
                        if (isUnlocked) {
                          context.push('/module/${module.id}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Debes completar el nivel anterior para desbloquear este.'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final String title;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _LevelNode({
    required this.title,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUnlocked ? const Color(0xFF58CC02) : Colors.grey.shade400,
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? const Color(0xFF58CC02).withOpacity(0.5) : Colors.black12,
              offset: const Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.star_rounded : Icons.lock_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
