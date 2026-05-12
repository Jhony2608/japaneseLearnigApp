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

final exercisesProvider = FutureProvider.family<List<Exercise>, String>((ref, moduleId) async {
  final repo = ref.watch(firestoreRepositoryProvider);
  return await repo.getExercisesByModule(moduleId);
});
