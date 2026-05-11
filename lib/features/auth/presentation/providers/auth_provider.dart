import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import 'package:japanese_learning_app/core/data/firestore_repository.dart';
import 'package:japanese_learning_app/core/models/user_profile.dart';

// Stream que expone el estado de autenticación (usuario activo o no)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// AsyncNotifierProvider es la forma moderna de manejar estados en Riverpod 2.x/3.x
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email: email, password: password);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn FirebaseAuthException: ${e.code} - ${e.message}');
      state = AsyncValue.error(_mapFirebaseError(e), StackTrace.current);
    } catch (e) {
      debugPrint('SignIn Exception: $e');
      state = AsyncValue.error('Ocurrió un error inesperado', StackTrace.current);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final userCredential = await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(email: email, password: password);
      
      final user = userCredential.user;
      if (user != null) {
        // Crear el perfil del usuario en Firestore
        final username = email.split('@').first;
        final profile = UserProfile(
          uid: user.uid,
          email: email,
          username: username,
          totalPoints: 0,
        );
        
        try {
          await ref.read(firestoreRepositoryProvider).createUserProfile(profile);
          debugPrint('Perfil creado en Firestore con UID: ${user.uid}');
        } catch (e) {
          debugPrint('Error en Firestore: $e');
          state = AsyncValue.error('Tu cuenta fue creada pero hubo un error guardando tu perfil.', StackTrace.current);
          return;
        }
      }

      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('Register FirebaseAuthException: ${e.code} - ${e.message}');
      state = AsyncValue.error(_mapFirebaseError(e), StackTrace.current);
    } catch (e) {
      debugPrint('Register Exception: $e');
      state = AsyncValue.error('Ocurrió un error inesperado', StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales incorrectas.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return 'El formato del correo es inválido.';
      default:
        return e.message ?? 'Error de autenticación.';
    }
  }
}
