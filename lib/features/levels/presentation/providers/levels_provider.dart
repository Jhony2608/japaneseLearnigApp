import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning_app/core/data/firestore_repository.dart';
import 'package:japanese_learning_app/core/models/module.dart';
import 'package:japanese_learning_app/core/models/exercise.dart';
import 'package:japanese_learning_app/core/models/user_progress.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';

final modulesProvider = FutureProvider<List<Module>>((ref) async {
  final repo = ref.watch(firestoreRepositoryProvider);
  return await repo.getModules();
});

final userProgressProvider = FutureProvider<List<UserProgress>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userObj = authState.value;
  
  if (userObj == null) return [];
  
  final repo = ref.watch(firestoreRepositoryProvider);
  return await repo.getUserProgress(userObj.uid);
});

final exercisesProvider = FutureProvider.autoDispose.family<List<Exercise>, String>((ref, moduleId) async {
  final repo = ref.watch(firestoreRepositoryProvider);
  
  // Buscar el módulo en la lista de módulos para saber si es de repaso
  final modulesList = await ref.watch(modulesProvider.future);
  final module = modulesList.firstWhere(
    (m) => m.id == moduleId, 
    orElse: () => throw Exception('Módulo no encontrado')
  );

  List<Exercise> exercises;
  if (module.isReview) {
    // Si es módulo de repaso, traemos TODO el banco de preguntas
    exercises = await repo.getAllExercises();
  } else {
    // Si es un módulo normal, traemos solo las de su ID
    exercises = await repo.getExercisesByModule(moduleId);
  }
  
  // Hacemos una copia y la desordenamos aleatoriamente
  final shuffledList = List<Exercise>.from(exercises)..shuffle();
  
  if (module.isReview) {
    // Limitar a 10 ejercicios aleatorios para el examen
    return shuffledList.take(10).toList();
  }
  
  return shuffledList;
});
