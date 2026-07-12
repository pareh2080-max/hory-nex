import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  List<File> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final dir = await getApplicationDocumentsDirectory();
    final recus = Directory('${dir.path}/recus');
    final files = recus.existsSync()
        ? recus.listSync().whereType<File>().where((f) => f.path.endsWith('.pdf')).toList()
        : <File>[];
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    if (!mounted) return;
    setState(() {
      _files = files;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reçus générés')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? const Center(child: Text('Aucun reçu généré pour le moment.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _files.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final f = _files[i];
                      final name = f.path.split(Platform.pathSeparator).last;
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf,
                              color: AppColors.danger, size: 32),
                          title: Text(name.replaceAll('.pdf', '')),
                          subtitle: Text(
                              'Modifié : ${f.statSync().modified.toString().split('.').first}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.print),
                                onPressed: () async {
                                  final bytes = await f.readAsBytes();
                                  await Printing.layoutPdf(onLayout: (_) async => bytes);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () =>
                                    Share.shareXFiles([XFile(f.path)]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
