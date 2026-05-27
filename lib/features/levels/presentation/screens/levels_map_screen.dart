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
        title: const Text('Camino de Aprendizaje', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, color: Color(0xFF78C6A3), size: 32),
            onPressed: () => context.push('/profile'),
            tooltip: 'Mi Perfil',
          ),
          const SizedBox(width: 8),
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

                  // Lógica del Zigzag visual
                  double getAlignment(int idx) {
                    if (idx % 4 == 0) return 0.0;
                    if (idx % 4 == 1) return 0.4;
                    if (idx % 4 == 2) return 0.0;
                    if (idx % 4 == 3) return -0.4;
                    return 0.0;
                  }

                  final currentAlignment = getAlignment(index);
                  final nextAlignment = index < modules.length - 1 ? getAlignment(index + 1) : 0.0;
                  final isLast = index == modules.length - 1;
                  
                  // Lógica de si el siguiente módulo está desbloqueado (para pintar la línea)
                  bool isNextUnlocked = false;
                  if (!isLast) {
                    final currentProgress = progress.where((p) => p.moduleId == module.id && p.isCompleted).isNotEmpty;
                    isNextUnlocked = currentProgress;
                  }

                  return SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Línea conectora hacia el siguiente nodo
                        if (!isLast)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PathPainter(
                                startAlignment: currentAlignment,
                                endAlignment: nextAlignment,
                                isUnlocked: isNextUnlocked,
                              ),
                            ),
                          ),
                        // Nodo interactivo actual
                        Align(
                          alignment: Alignment(currentAlignment, 0),
                          child: _LevelNode(
                            title: module.title,
                            isUnlocked: isUnlocked,
                            isReview: module.isReview,
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
                        ),
                      ],
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

class _PathPainter extends CustomPainter {
  final double startAlignment;
  final double endAlignment;
  final bool isUnlocked;

  _PathPainter({
    required this.startAlignment,
    required this.endAlignment,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isUnlocked ? const Color(0xFF78C6A3) : Colors.grey.shade300
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Convertir alineación (-1 a 1) en coordenadas X (0 a width)
    final startX = (startAlignment + 1) / 2 * size.width;
    final endX = (endAlignment + 1) / 2 * size.width;
    
    // Centro del nodo actual al centro del nodo siguiente
    final startY = size.height / 2;
    final endY = size.height * 1.5;

    final path = Path();
    path.moveTo(startX, startY);
    
    // Curva de Bezier para suavizar el zigzag
    final controlPoint1X = startX;
    final controlPoint1Y = startY + (endY - startY) / 2;
    final controlPoint2X = endX;
    final controlPoint2Y = startY + (endY - startY) / 2;

    path.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y, endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.startAlignment != startAlignment ||
           oldDelegate.endAlignment != endAlignment ||
           oldDelegate.isUnlocked != isUnlocked;
  }
}

class _LevelNode extends StatelessWidget {
  final String title;
  final bool isUnlocked;
  final bool isReview;
  final VoidCallback onTap;

  const _LevelNode({
    required this.title,
    required this.isUnlocked,
    required this.isReview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colores corporativos (Verde Té Matcha y Dorados para Repaso)
    final activeColor = isReview ? const Color(0xFFFFC800) : const Color(0xFF78C6A3);
    final inactiveColor = Colors.grey.shade300;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUnlocked ? activeColor : inactiveColor,
          border: Border.all(
            color: isUnlocked ? activeColor.withOpacity(0.5) : Colors.grey.shade400,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? activeColor.withOpacity(0.4) : Colors.black12,
              offset: const Offset(0, 8),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked 
                ? (isReview ? Icons.star_rounded : Icons.menu_book_rounded) 
                : Icons.lock_rounded,
              color: isUnlocked ? Colors.white : Colors.grey.shade500,
              size: 38,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.grey.shade600,
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
