import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:japanese_learning_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:japanese_learning_app/core/theme/theme_provider.dart';
import 'package:japanese_learning_app/core/data/firestore_repository.dart';
import 'package:japanese_learning_app/core/models/exercise.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('No se encontró el perfil'));

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF78C6A3),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  profile.username,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 40),
                          const SizedBox(height: 8),
                          Text(
                            '${profile.totalPoints}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Text('Puntos Obtenidos', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Botón de Modo Oscuro
                Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    final isDark = themeMode == ThemeMode.dark;
                    
                    return SwitchListTile(
                      title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(isDark ? 'Activado' : 'Desactivado'),
                      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? const Color(0xFF78C6A3) : Colors.orange),
                      value: isDark,
                      activeColor: const Color(0xFF78C6A3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).toggleTheme(value);
                      },
                    );
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final String moduleId = "sLhXHV67WcKGz5NMHrkM"; // Recordatorio para poner mi ID

                      final list = [
                        {"moduleId": moduleId, "type": "drawing", "question": "あ"},
                        {"moduleId": moduleId, "type": "drawing", "question": "い"},
                        {"moduleId": moduleId, "type": "drawing", "question": "う"},
                        {"moduleId": moduleId, "type": "drawing", "question": "え"},
                        {"moduleId": moduleId, "type": "drawing", "question": "お"}
                      ];
                      
                      final seedData = list.map((map) => Exercise(
                        id: '', 
                        moduleId: map['moduleId']!, 
                        type: map['type']!, 
                        question: map['question']!, 
                        correctAnswer: null
                      )).toList();
                      
                      try {
                        await ref.read(firestoreRepositoryProvider).seedExercises(seedData);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ejercicios creados con éxito. ¡Ve a probarlos!')),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error sembrando datos: $e');
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('CARGAR DATOS DE PRUEBA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('CERRAR SESIÓN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
