import 'package:flutter/material.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diccionario', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFF78C6A3),
            labelColor: Color(0xFF78C6A3),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Hiragana'),
              Tab(text: 'Katakana'),
              Tab(text: 'Vocabulario'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHiraganaGrid(),
            const Center(child: Text('Lista de Katakana (Próximamente)')),
            const Center(child: Text('Glosario de Vocabulario (Próximamente)')),
          ],
        ),
      ),
    );
  }

  Widget _buildHiraganaGrid() {
    final hiraganaMap = {
      'Vocales': [
        {'char': 'あ', 'romaji': 'a'}, {'char': 'い', 'romaji': 'i'}, {'char': 'う', 'romaji': 'u'}, {'char': 'え', 'romaji': 'e'}, {'char': 'お', 'romaji': 'o'},
      ],
      'Fila K': [
        {'char': 'か', 'romaji': 'ka'}, {'char': 'き', 'romaji': 'ki'}, {'char': 'く', 'romaji': 'ku'}, {'char': 'け', 'romaji': 'ke'}, {'char': 'こ', 'romaji': 'ko'},
      ],
      'Fila S': [
        {'char': 'さ', 'romaji': 'sa'}, {'char': 'し', 'romaji': 'shi'}, {'char': 'す', 'romaji': 'su'}, {'char': 'せ', 'romaji': 'se'}, {'char': 'そ', 'romaji': 'so'},
      ],
      'Fila T': [
        {'char': 'た', 'romaji': 'ta'}, {'char': 'ち', 'romaji': 'chi'}, {'char': 'つ', 'romaji': 'tsu'}, {'char': 'て', 'romaji': 'te'}, {'char': 'と', 'romaji': 'to'},
      ],
      'Fila N': [
        {'char': 'な', 'romaji': 'na'}, {'char': 'に', 'romaji': 'ni'}, {'char': 'ぬ', 'romaji': 'nu'}, {'char': 'ね', 'romaji': 'ne'}, {'char': 'の', 'romaji': 'no'},
      ],
      'Fila H': [
        {'char': 'は', 'romaji': 'ha'}, {'char': 'ひ', 'romaji': 'hi'}, {'char': 'ふ', 'romaji': 'fu'}, {'char': 'へ', 'romaji': 'he'}, {'char': 'ほ', 'romaji': 'ho'},
      ],
      'Fila M': [
        {'char': 'ま', 'romaji': 'ma'}, {'char': 'み', 'romaji': 'mi'}, {'char': 'む', 'romaji': 'mu'}, {'char': 'め', 'romaji': 'me'}, {'char': 'も', 'romaji': 'mo'},
      ],
      'Fila Y': [
        {'char': 'や', 'romaji': 'ya'}, {'char': '', 'romaji': ''}, {'char': 'ゆ', 'romaji': 'yu'}, {'char': '', 'romaji': ''}, {'char': 'よ', 'romaji': 'yo'},
      ],
      'Fila R': [
        {'char': 'ら', 'romaji': 'ra'}, {'char': 'り', 'romaji': 'ri'}, {'char': 'る', 'romaji': 'ru'}, {'char': 'れ', 'romaji': 're'}, {'char': 'ろ', 'romaji': 'ro'},
      ],
      'Fila W/N': [
        {'char': 'わ', 'romaji': 'wa'}, {'char': '', 'romaji': ''}, {'char': 'を', 'romaji': 'wo'}, {'char': '', 'romaji': ''}, {'char': 'ん', 'romaji': 'n'},
      ],
    };

    final allItems = <Map<String, String>>[];
    for (final group in hiraganaMap.values) {
      allItems.addAll(group);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columnas (a, i, u, e, o)
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        if (item['char']!.isEmpty) {
          return const SizedBox(); // Hueco invisible para las sílabas que no existen (yi, ye, wi, wu, we)
        }
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['char']!,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                item['romaji']!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
