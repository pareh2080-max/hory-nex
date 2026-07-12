import 'package:flutter/material.dart';
import '../../core/data/filieres.dart';
import '../../core/theme/app_colors.dart';

class FilieresScreen extends StatelessWidget {
  const FilieresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filières PREPAC')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: Filieres.axes.map((axe) {
          final items = Filieres.filieresDe(axe);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book, color: AppColors.vert),
              title: Text(axe,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${items.length} filières'),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: items
                  .map((f) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.circle, size: 8),
                        title: Text(f),
                      ))
                  .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
