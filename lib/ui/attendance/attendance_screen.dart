import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/attendance.dart';
import '../../models/student.dart';
import '../../providers.dart';
import '../../repositories/attendance_repository.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _date = DateTime.now();
  List<Student> _students = [];
  final Map<String, AttendanceStatus> _statuses = {};
  AttendanceStats _stats = const AttendanceStats(0, 0, 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final students = await ref.read(studentRepoProvider).search(limit: 500);
    final existing = await ref.read(attendanceRepoProvider).forDate(_date);
    final stats = await ref.read(attendanceRepoProvider).statsForDate(_date);
    _statuses.clear();
    for (final a in existing) {
      _statuses[a.studentId] = a.statut;
    }
    if (!mounted) return;
    setState(() {
      _students = students;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _mark(Student s, AttendanceStatus status) async {
    setState(() => _statuses[s.id] = status);
    await ref.read(attendanceRepoProvider).mark(
          studentId: s.id,
          date: _date,
          statut: status,
          heure:
              '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
        );
    final stats = await ref.read(attendanceRepoProvider).statsForDate(_date);
    if (mounted) setState(() => _stats = stats);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      _date = picked;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Présences'),
        actions: [
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _statPill('Présents', _stats.present, AppColors.vert),
                _statPill('Absents', _stats.absent, AppColors.danger),
                _statPill('Retards', _stats.retard, AppColors.avertissement),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: _students.length,
                    itemBuilder: (_, i) {
                      final s = _students[i];
                      final st = _statuses[s.id];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.nomComplet,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(s.matricule,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.grisMoyen)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _choice('Présent', AttendanceStatus.present,
                                      st, AppColors.vert, s),
                                  _choice('Absent', AttendanceStatus.absent, st,
                                      AppColors.danger, s),
                                  _choice('Retard', AttendanceStatus.retard, st,
                                      AppColors.avertissement, s),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, int value, Color color) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 20)),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _choice(String label, AttendanceStatus status,
      AttendanceStatus? current, Color color, Student s) {
    final selected = current == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: color.withOpacity(.85),
        labelStyle: TextStyle(
            color: selected ? Colors.white : null,
            fontSize: 12,
            fontWeight: FontWeight.w600),
        onSelected: (_) => _mark(s, status),
      ),
    );
  }
}
