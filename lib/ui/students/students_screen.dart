import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student.dart';
import '../../providers.dart';
import 'student_form_screen.dart';
import 'student_detail_screen.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchCtrl = TextEditingController();
  List<Student> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(studentRepoProvider);
    final list = await repo.search(query: _searchCtrl.text, limit: 200);
    if (!mounted) return;
    setState(() {
      _students = list;
      _loading = false;
    });
  }

  Future<void> _openForm([Student? student]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StudentFormScreen(student: student)),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Étudiants')),
      floatingActionButton: (user?.canManageStudents ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.person_add),
              label: const Text('Inscrire'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Rechercher (nom, matricule, téléphone)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('Aucun étudiant.'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                          itemCount: _students.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _tile(_students[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Student s) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.bleuFonce.withOpacity(.1),
          backgroundImage: (s.photoPath != null && File(s.photoPath!).existsSync())
              ? FileImage(File(s.photoPath!))
              : null,
          child: (s.photoPath == null || !File(s.photoPath!).existsSync())
              ? Text(
                  s.prenom.isNotEmpty ? s.prenom[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppColors.bleuFonce, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(s.nomComplet,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${s.matricule} · ${s.filiere ?? s.axe ?? "—"}\n${s.commune ?? ""} ${s.departement != null ? "(${s.departement})" : ""}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => StudentDetailScreen(studentId: s.id)),
          );
          _load();
        },
      ),
    );
  }
}
