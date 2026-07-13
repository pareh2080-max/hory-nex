import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/payment.dart';
import '../../providers.dart';
import '../../repositories/payment_repository.dart';
import '../students/student_detail_screen.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _search = TextEditingController();
  List<PaymentWithStudent> _items = [];
  double _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(paymentRepoProvider);
    final items = await repo.recent(query: _search.text);
    final total = await repo.totalEncaisse();
    if (!mounted) return;
    setState(() {
      _items = items;
      _total = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bleuFonce,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total encaissé',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(Formatters.money(_total),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => _load(),
              decoration: const InputDecoration(
                hintText: 'Rechercher un paiement...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('Aucun paiement.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final it = _items[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.vert,
                                child: Icon(Icons.attach_money, color: Colors.white),
                              ),
                              title: Text(it.studentNom,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  '${it.payment.recuNumero} · ${it.payment.mode.label}\n${Formatters.dateTime(it.payment.datePaiement)}'),
                              isThreeLine: true,
                              trailing: Text(Formatters.money(it.payment.montant),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.vert)),
                              onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => StudentDetailScreen(
                                        studentId: it.payment.studentId)));
                                _load();
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
