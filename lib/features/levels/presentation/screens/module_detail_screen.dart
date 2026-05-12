import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japanese_learning_app/core/models/exercise.dart';
import 'package:japanese_learning_app/core/models/user_progress.dart';
import 'package:japanese_learning_app/features/levels/presentation/providers/levels_provider.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:japanese_learning_app/core/data/firestore_repository.dart';
import 'package:japanese_learning_app/features/exercises/presentation/widgets/multiple_choice_exercise.dart';
import 'package:japanese_learning_app/features/exercises/presentation/widgets/flashcard_exercise.dart';

class ModuleDetailScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  ConsumerState<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends ConsumerState<ModuleDetailScreen> {
  int currentIndex = 0;
  List<Exercise>? exercisesList;

  void _nextExercise() {
    if (exercisesList == null) return;
    if (currentIndex < exercisesList!.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _completeModule();
    }
  }

  void _retryExercise() {
    // Por simplicidad en este MVP, si el usuario falla, también avanzamos.
    // Una mecánica real lo pondría al final de la cola.
    _nextExercise();
  }

  Future<void> _completeModule() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final score = (exercisesList?.length ?? 0) * 10;

      // Guardar el progreso en Firestore
      final progress = UserProgress(
        id: '${user.uid}_${widget.moduleId}',
        userId: user.uid,
        moduleId: widget.moduleId,
        isCompleted: true,
        score: score,
      );
      
      try {
        await ref.read(firestoreRepositoryProvider).saveUserProgress(progress);
        await ref.read(firestoreRepositoryProvider).addPointsToUser(user.uid, progress.score);
        
        // Invalidar el provider del progreso para forzar que el mapa (Fase 4) se refresque y desbloquee el siguiente nivel
        ref.invalidate(userProgressProvider);
      } catch (e) {
        debugPrint('Error guardando progreso: $e');
      }
    }

    if (!mounted) return;
    
    // Mostrar pantalla de éxito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Módulo Completado!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFC800), size: 100),
            const SizedBox(height: 16),
            Text('¡Has ganado ${(exercisesList?.length ?? 0) * 10} puntos!'),
            const SizedBox(height: 8),
            const Text('El siguiente nivel ha sido desbloqueado.', textAlign: TextAlign.center),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              context.pop(); // Cerrar dialog
              context.pop(); // Volver al mapa
            },
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider(widget.moduleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lección'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirmación antes de salir
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('¿Quieres salir?'),
                content: const Text('Perderás todo tu progreso en esta lección.'),
                actions: [
                  TextButton(onPressed: () => context.pop(), child: const Text('CANCELAR')),
                  TextButton(
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                    child: const Text('SALIR'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error al cargar ejercicios: $error')),
        data: (exercises) {
          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay ejercicios en este módulo.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _completeModule, 
                    child: const Text('Simular Completar Módulo')
                  ),
                ],
              ),
            );
          }

          exercisesList = exercises;
          final currentExercise = exercises[currentIndex];
          // Calculamos el progreso (añadimos 1 al index para no empezar en 0 si estamos en el primero)
          final progressPercent = currentIndex / exercises.length;

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 16,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF58CC02),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildExerciseWidget(currentExercise),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseWidget(Exercise exercise) {
    // Usamos Keys para forzar que el widget se reconstruya si el estado cambia pero el tipo de widget es el mismo
    if (exercise.type == 'multiple_choice') {
      return MultipleChoiceExercise(
        key: ValueKey(exercise.id),
        exercise: exercise,
        onCorrect: _nextExercise,
        onIncorrect: _retryExercise,
      );
    } else if (exercise.type == 'flashcard') {
      return FlashcardExercise(
        key: ValueKey(exercise.id),
        exercise: exercise,
        onKnewIt: _nextExercise,
        onDidNotKnowIt: _retryExercise,
      );
    }
    
    // Fallback por si hay un tipo no implementado
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Tipo de ejercicio desconocido: ${exercise.type}'),
          ElevatedButton(onPressed: _nextExercise, child: const Text('Saltar Ejercicio')),
        ],
      ),
    );
  }
}
