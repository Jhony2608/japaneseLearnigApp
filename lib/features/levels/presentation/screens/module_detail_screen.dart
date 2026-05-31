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
import 'package:japanese_learning_app/features/exercises/presentation/widgets/drawing_exercise.dart';

class ModuleDetailScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  ConsumerState<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends ConsumerState<ModuleDetailScreen> {
  int currentIndex = 0;
  List<Exercise>? exercisesList;
  int correctAnswers = 0;

  void _advanceExercise(bool isCorrect) {
    if (isCorrect) {
      correctAnswers++;
    }
    
    if (exercisesList == null) return;
    if (currentIndex < exercisesList!.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _completeModule();
    }
  }

  Future<void> _completeModule() async {
    final totalExercises = exercisesList?.length ?? 0;
    // Umbral del 80%
    final bool isPassed = totalExercises > 0 ? (correctAnswers / totalExercises) >= 0.8 : true;
    final int score = correctAnswers * 10;

    final user = ref.read(authStateProvider).value;
    
    if (isPassed && user != null) {
      // Solo guardamos si aprueba
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
        
        // Invalidar el provider del progreso para forzar que el mapa se refresque
        ref.invalidate(userProgressProvider);
      } catch (e) {
        debugPrint('Error guardando progreso: $e');
      }
    }

    if (!mounted) return;
    
    if (isPassed) {
      // Mostrar pantalla de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text('¡Módulo Completado!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.orange.shade200, size: 120),
                        const Icon(Icons.workspace_premium, color: Color(0xFFFFC800), size: 100),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Puntuación: $correctAnswers / $totalExercises',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+$score PUNTOS',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF58CC02)),
                    ),
                    const SizedBox(height: 8),
                    const Text('¡Excelente trabajo! El mapa se ha actualizado.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop(); // Cerrar dialog
                        context.pop(); // Volver al mapa
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('CONTINUAR'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Mostrar pantalla de fallo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Módulo Suspendido', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded, color: Colors.redAccent, size: 100),
              const SizedBox(height: 16),
              Text(
                'Aciertos: $correctAnswers / $totalExercises',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Necesitas al menos un 80% de aciertos para aprobar este módulo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // Cerrar dialog
                  context.pop(); // Volver al mapa (para que lo reintente entrando de nuevo)
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('VOLVER AL MAPA'),
              ),
            ),
          ],
        ),
      );
    }
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
                    onPressed: () {
                      correctAnswers = exercises.length;
                      _completeModule();
                    }, 
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
    if (exercise.type == 'multiple_choice') {
      return MultipleChoiceExercise(
        key: ValueKey(exercise.id),
        exercise: exercise,
        onCorrect: () => _advanceExercise(true),
        onIncorrect: () => _advanceExercise(false),
      );
    } else if (exercise.type == 'flashcard') {
      return FlashcardExercise(
        key: ValueKey(exercise.id),
        exercise: exercise,
        onKnewIt: () => _advanceExercise(true),
        onDidNotKnowIt: () => _advanceExercise(false),
      );
    } else if (exercise.type == 'drawing') {
      return DrawingExercise(
        key: ValueKey(exercise.id),
        exercise: exercise,
        onEvaluated: (isCorrect) => _advanceExercise(isCorrect),
      );
    }
    
    // Fallback por si hay un tipo no implementado
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Tipo de ejercicio desconocido: ${exercise.type}'),
          ElevatedButton(onPressed: () => _advanceExercise(false), child: const Text('Saltar Ejercicio')),
        ],
      ),
    );
  }
}
