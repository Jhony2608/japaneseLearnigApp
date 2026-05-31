import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japanese_learning_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:japanese_learning_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:japanese_learning_app/core/theme/theme_provider.dart';
import 'package:japanese_learning_app/core/data/firestore_repository.dart';
import 'package:japanese_learning_app/core/models/exercise.dart';
import 'package:japanese_learning_app/core/models/module.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('No se encontró el perfil'));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF78C6A3),
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null 
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
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
                Builder(
                  builder: (context) {
                    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: isDarkMode ? Border.all(color: Colors.grey[700]!, width: 1) : null,
                        boxShadow: isDarkMode 
                            ? null 
                            : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
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
                );
              }),
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
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final repo = ref.read(firestoreRepositoryProvider);

                      // --- Fila H ---
                      final m21 = Module(id: '', title: 'Hiragana: Fila H 1', description: 'Introducción a la Fila H del silabario.', orderIndex: 21, isCumulativeExam: false);
                      final e21 = [
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'は', correctAnswer: 'ha'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ひ', correctAnswer: 'hi'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ふ', correctAnswer: 'fu'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'へ', correctAnswer: 'he'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ほ', correctAnswer: 'ho'),
                      ];
                      final m22 = Module(id: '', title: 'Hiragana: Fila H 2', description: 'Práctica de lectura para la Fila H.', orderIndex: 22, isCumulativeExam: false);
                      final e22 = [
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ha', correctAnswer: 'は', options: ['ほ', 'は', 'け', 'ひ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'hi', correctAnswer: 'ひ', options: ['い', 'ふ', 'ひ', 'へ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'fu', correctAnswer: 'ふ', options: ['ほ', 'ふ', 'は', 'へ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'he', correctAnswer: 'へ', options: ['く', 'へ', 'ひ', 'ほ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ho', correctAnswer: 'ほ', options: ['は', 'ま', 'ほ', 'ふ']),
                      ];
                      final m23 = Module(id: '', title: 'Hiragana: Fila H 3', description: 'Aprende a escribir correctamente la Fila H.', orderIndex: 23, isCumulativeExam: false);
                      final e23 = [
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'は', correctAnswer: 'ha'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ひ', correctAnswer: 'hi'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ふ', correctAnswer: 'fu'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'へ', correctAnswer: 'he'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ほ', correctAnswer: 'ho'),
                      ];
                      final m24 = Module(id: '', title: 'Hiragana: Fila H Repaso', description: 'Examen acumulativo de todo lo aprendido hasta la Fila H.', orderIndex: 24, isCumulativeExam: true);
                      final e24 = <Exercise>[];

                      // --- Fila M ---
                      final m25 = Module(id: '', title: 'Hiragana: Fila M 1', description: 'Introducción a la Fila M del silabario.', orderIndex: 25, isCumulativeExam: false);
                      final e25 = [
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ま', correctAnswer: 'ma'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'み', correctAnswer: 'mi'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'む', correctAnswer: 'mu'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'め', correctAnswer: 'me'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'も', correctAnswer: 'mo'),
                      ];
                      final m26 = Module(id: '', title: 'Hiragana: Fila M 2', description: 'Práctica de lectura para la Fila M.', orderIndex: 26, isCumulativeExam: false);
                      final e26 = [
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ma', correctAnswer: 'ま', options: ['ほ', 'も', 'ま', 'む']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'mi', correctAnswer: 'み', options: ['み', 'む', 'め', 'ま']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'mu', correctAnswer: 'む', options: ['み', 'め', 'む', 'も']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'me', correctAnswer: 'め', options: ['ぬ', 'め', 'あ', 'ま']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'mo', correctAnswer: 'も', options: ['ま', 'し', 'も', 'む']),
                      ];
                      final m27 = Module(id: '', title: 'Hiragana: Fila M 3', description: 'Aprende a escribir correctamente la Fila M.', orderIndex: 27, isCumulativeExam: false);
                      final e27 = [
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ま', correctAnswer: 'ma'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'み', correctAnswer: 'mi'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'む', correctAnswer: 'mu'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'め', correctAnswer: 'me'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'も', correctAnswer: 'mo'),
                      ];
                      final m28 = Module(id: '', title: 'Hiragana: Fila M Repaso', description: 'Examen acumulativo de todo lo aprendido hasta la Fila M.', orderIndex: 28, isCumulativeExam: true);
                      final e28 = <Exercise>[];

                      // --- Fila Y ---
                      final m29 = Module(id: '', title: 'Hiragana: Fila Y 1', description: 'Introducción a la Fila Y del silabario.', orderIndex: 29, isCumulativeExam: false);
                      final e29 = [
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'や', correctAnswer: 'ya'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ゆ', correctAnswer: 'yu'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'よ', correctAnswer: 'yo'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'や', correctAnswer: 'ya'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'よ', correctAnswer: 'yo'),
                      ];
                      final m30 = Module(id: '', title: 'Hiragana: Fila Y 2', description: 'Práctica de lectura para la Fila Y.', orderIndex: 30, isCumulativeExam: false);
                      final e30 = [
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ya', correctAnswer: 'や', options: ['ゆ', 'や', 'か', 'よ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'yu', correctAnswer: 'ゆ', options: ['め', 'ゆ', 'よ', 'や']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'yo', correctAnswer: 'よ', options: ['ま', 'ゆ', 'よ', 'や']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ya', correctAnswer: 'や', options: ['ち', 'よ', 'や', 'ゆ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'yu', correctAnswer: 'ゆ', options: ['ゆ', 'ぬ', 'よ', 'や']),
                      ];
                      final m31 = Module(id: '', title: 'Hiragana: Fila Y 3', description: 'Aprende a escribir correctamente la Fila Y.', orderIndex: 31, isCumulativeExam: false);
                      final e31 = [
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'や', correctAnswer: 'ya'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ゆ', correctAnswer: 'yu'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'よ', correctAnswer: 'yo'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'や', correctAnswer: 'ya'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ゆ', correctAnswer: 'yu'),
                      ];
                      final m32 = Module(id: '', title: 'Hiragana: Fila Y Repaso', description: 'Examen acumulativo de todo lo aprendido hasta la Fila Y.', orderIndex: 32, isCumulativeExam: true);
                      final e32 = <Exercise>[];

                      // --- Fila R ---
                      final m33 = Module(id: '', title: 'Hiragana: Fila R 1', description: 'Introducción a la Fila R del silabario.', orderIndex: 33, isCumulativeExam: false);
                      final e33 = [
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ら', correctAnswer: 'ra'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'り', correctAnswer: 'ri'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'る', correctAnswer: 'ru'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'れ', correctAnswer: 're'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ろ', correctAnswer: 'ro'),
                      ];
                      final m34 = Module(id: '', title: 'Hiragana: Fila R 2', description: 'Práctica de lectura para la Fila R.', orderIndex: 34, isCumulativeExam: false);
                      final e34 = [
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ra', correctAnswer: 'ら', options: ['ち', 'ら', 'ろ', 'る']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ri', correctAnswer: 'り', options: ['い', 'る', 'り', 'れ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ru', correctAnswer: 'る', options: ['ろ', 'る', 'ら', 'れ']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 're', correctAnswer: 'れ', options: ['ね', 'れ', 'わ', 'る']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'ro', correctAnswer: 'ろ', options: ['る', 'ら', 'ろ', 'り']),
                      ];
                      final m35 = Module(id: '', title: 'Hiragana: Fila R 3', description: 'Aprende a escribir correctamente la Fila R.', orderIndex: 35, isCumulativeExam: false);
                      final e35 = [
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ら', correctAnswer: 'ra'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'り', correctAnswer: 'ri'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'る', correctAnswer: 'ru'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'れ', correctAnswer: 're'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ろ', correctAnswer: 'ro'),
                      ];
                      final m36 = Module(id: '', title: 'Hiragana: Fila R Repaso', description: 'Examen acumulativo de todo lo aprendido hasta la Fila R.', orderIndex: 36, isCumulativeExam: true);
                      final e36 = <Exercise>[];

                      // --- Fila W / N ---
                      final m37 = Module(id: '', title: 'Hiragana: Fila W 1', description: 'Introducción a la Fila W y carácter final N.', orderIndex: 37, isCumulativeExam: false);
                      final e37 = [
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'わ', correctAnswer: 'wa'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'を', correctAnswer: 'wo'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ん', correctAnswer: 'n'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'わ', correctAnswer: 'wa'),
                        Exercise(id: '', moduleId: '', type: 'flashcard', question: 'ん', correctAnswer: 'n'),
                      ];
                      final m38 = Module(id: '', title: 'Hiragana: Fila W 2', description: 'Práctica de lectura para la Fila W y N.', orderIndex: 38, isCumulativeExam: false);
                      final e38 = [
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'wa', correctAnswer: 'わ', options: ['れ', 'ね', 'わ', 'を']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'wo', correctAnswer: 'を', options: ['わ', 'を', 'ち', 'ん']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'n', correctAnswer: 'ん', options: ['ん', 'ソ', 'わ', 'を']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'wa', correctAnswer: 'わ', options: ['わ', 'を', 'ん', 'ね']),
                        Exercise(id: '', moduleId: '', type: 'multiple_choice', question: 'wo', correctAnswer: 'を', options: ['て', 'ん', 'わ', 'を']),
                      ];
                      final m39 = Module(id: '', title: 'Hiragana: Fila W 3', description: 'Aprende a escribir correctamente la Fila W y N.', orderIndex: 39, isCumulativeExam: false);
                      final e39 = [
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'わ', correctAnswer: 'wa'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'を', correctAnswer: 'wo'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ん', correctAnswer: 'n'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'わ', correctAnswer: 'wa'),
                        Exercise(id: '', moduleId: '', type: 'drawing', question: 'ん', correctAnswer: 'n'),
                      ];
                      final m40 = Module(id: '', title: 'Hiragana: Repaso Final', description: '¡Gran examen final! Demuestra tu dominio absoluto del Hiragana.', orderIndex: 40, isCumulativeExam: true);
                      final e40 = <Exercise>[];

                      try {
                        await repo.seedCompleteModule(m21, e21); await repo.seedCompleteModule(m22, e22); await repo.seedCompleteModule(m23, e23); await repo.seedCompleteModule(m24, e24);
                        await repo.seedCompleteModule(m25, e25); await repo.seedCompleteModule(m26, e26); await repo.seedCompleteModule(m27, e27); await repo.seedCompleteModule(m28, e28);
                        await repo.seedCompleteModule(m29, e29); await repo.seedCompleteModule(m30, e30); await repo.seedCompleteModule(m31, e31); await repo.seedCompleteModule(m32, e32);
                        await repo.seedCompleteModule(m33, e33); await repo.seedCompleteModule(m34, e34); await repo.seedCompleteModule(m35, e35); await repo.seedCompleteModule(m36, e36);
                        await repo.seedCompleteModule(m37, e37); await repo.seedCompleteModule(m38, e38); await repo.seedCompleteModule(m39, e39); await repo.seedCompleteModule(m40, e40);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Se inyectaron 20 módulos de Hiragana de un solo golpe!')),
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
          ));
        },
      ),
    );
  }
}
