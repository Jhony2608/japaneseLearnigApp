import 'package:flutter/material.dart';
import 'package:japanese_learning_app/features/levels/presentation/screens/levels_map_screen.dart';
import 'package:japanese_learning_app/features/dictionary/presentation/screens/dictionary_screen.dart';
import 'package:japanese_learning_app/features/profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LevelsMapScreen(),
    const DictionaryScreen(),
    const SizedBox(), 
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Próximamente', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('La pasarela de pagos y tienda de vidas extra estará disponible en futuras actualizaciones.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(color: Color(0xFF78C6A3))),
            ),
          ],
        ),
      );
      return; 
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF78C6A3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Diccionario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
