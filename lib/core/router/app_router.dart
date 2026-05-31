import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning_app/features/auth/presentation/screens/login_screen.dart';
import 'package:japanese_learning_app/features/auth/presentation/screens/register_screen.dart';
import 'package:japanese_learning_app/features/levels/presentation/screens/levels_map_screen.dart';
import 'package:japanese_learning_app/features/levels/presentation/screens/module_detail_screen.dart';
import 'package:japanese_learning_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:japanese_learning_app/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Evitar redirecciones mientras el estado de autenticación inicial se está cargando
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isAuthScreen = state.uri.path == '/login' || state.uri.path == '/register';

      // Si está autenticado y trata de acceder a login/registro, redirigir al mapa.
      if (isAuth && isAuthScreen) {
        return '/levels';
      }
      
      // Si no está autenticado y trata de acceder a una página protegida, redirigir a login.
      if (!isAuth && !isAuthScreen) {
        return '/login';
      }

      return null; // Dejar que la navegación continúe.
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/levels',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/module/:id',
        builder: (context, state) {
          final moduleId = state.pathParameters['id']!;
          return ModuleDetailScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
