import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/module.dart';
import '../models/exercise.dart';
import '../models/user_progress.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreProvider));
});

class FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepository(this._firestore);

  // --- Users ---
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // --- Modules ---
  Future<List<Module>> getModules() async {
    final snapshot = await _firestore.collection('modules').orderBy('orderIndex').get();
    return snapshot.docs.map((doc) => Module.fromMap(doc.data(), doc.id)).toList();
  }

  // --- Exercises ---
  Future<List<Exercise>> getExercisesByModule(String moduleId) async {
    final snapshot = await _firestore.collection('exercises').where('moduleId', isEqualTo: moduleId).get();
    return snapshot.docs.map((doc) => Exercise.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Exercise>> getAllExercises() async {
    final snapshot = await _firestore.collection('exercises').get();
    return snapshot.docs.map((doc) => Exercise.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> seedExercises(List<Exercise> exercises) async {
    final batch = _firestore.batch();
    for (final ex in exercises) {
      final docRef = _firestore.collection('exercises').doc(); // Auto-generate ID
      batch.set(docRef, ex.toMap());
    }
    await batch.commit();
  }

  // --- Progress ---
  Future<List<UserProgress>> getUserProgress(String userId) async {
    final snapshot = await _firestore.collection('progress').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => UserProgress.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveUserProgress(UserProgress progress) async {
    final docRef = _firestore.collection('progress').doc('${progress.userId}_${progress.moduleId}');
    await docRef.set(progress.toMap());
  }

  Future<void> addPointsToUser(String userId, int points) async {
    final docRef = _firestore.collection('users').doc(userId);
    await docRef.update({'totalPoints': FieldValue.increment(points)});
  }
}
