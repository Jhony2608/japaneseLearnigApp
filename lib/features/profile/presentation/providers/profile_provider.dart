import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning_app/core/data/firestore_repository.dart';
import 'package:japanese_learning_app/core/models/user_profile.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userObj = authState.value;
  
  if (userObj == null) return null;
  
  final repo = ref.watch(firestoreRepositoryProvider);
  return await repo.getUserProfile(userObj.uid);
});
