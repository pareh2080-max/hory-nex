import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/filieres.dart';
import '../../models/encadreur.dart';
import '../../providers.dart';

class EncadreurFormScreen extends ConsumerStatefulWidget {
  final Encadreur? encadreur;
  const EncadreurFormScreen({super.key, this.encadreur});

  @override
  ConsumerState<EncadreurFormScreen> createState() => _EncadreurFormScreenState();
}

class _EncadreurFormScreenState extends ConsumerState<EncadreurFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _tel = TextEditingController();
  final _whatsapp = TextEditingController();
  final _adresse = TextEditingController();
  final _email = TextEditingController();
  final _specialite = TextEditingController();
  final _matiere = TextEditingController();
  final _dispo = TextEditingController();
  String? _axe;
  String _statut = 'Actif';
  bool _saving = false;

  bool get _isEdit => widget.encadreur != null;

  @override
  void initState() {
    super.initState();
    final e = widget.encadreur;
    if (e != null) {
      _nom.text = e.nom;
      _prenom.text = e.prenom;
      _tel.text = e.telephone ?? '';
      _whatsapp.text = e.whatsapp ?? '';
      _adresse.text = e.adresse ?? '';
      _email.text = e.email ?? '';
      _specialite.text = e.specialite ?? '';
      _matiere.text = e.matiere ?? '';
      _dispo.text = e.disponibilite ?? '';
      _axe = e.axe;
      _statut = e.statut ?? 'Actif';
    }
  }

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _tel, _whatsapp, _adresse, _email,
        _specialite, _matiere, _dispo]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(encadreurRepoProvider);
    final draft = Encadreur(
      id: widget.encadreur?.id ?? '',
      matricule: widget.encadreur?.matricule ?? '',
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      telephone: _tel.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      adresse: _adresse.text.trim(),
      email: _email.text.trim(),
      specialite: _specialite.text.trim(),
      matiere: _matiere.text.trim(),
      axe: _axe,
      dateEmbauche: widget.encadreur?.dateEmbauche ?? DateTime.now().toIso8601String(),
      disponibilite: _dispo.text.trim(),
      statut: _statut,
      createdAt: widget.encadreur?.createdAt ?? '',
      updatedAt: '',
    );
    if (_isEdit) {
      await repo.update(draft);
    } else {
      await repo.create(draft);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier encadreur' : 'Nouvel encadreur'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref.read(encadreurRepoProvider).delete(widget.encadreur!.id);
                if (mounted) Navigator.of(context).pop(true);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            _f(_prenom, 'Prénom *', req: true),
            _f(_nom, 'Nom *', req: true),
            _f(_tel, 'Téléphone', kb: TextInputType.phone),
            _f(_whatsapp, 'WhatsApp', kb: TextInputType.phone),
            _f(_email, 'Email', kb: TextInputType.emailAddress),
            _f(_adresse, 'Adresse'),
            _f(_specialite, 'Spécialité'),
            _f(_matiere, 'Matière enseignée'),
            DropdownButtonFormField<String>(
              value: _axe,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Axe'),
              items: Filieres.axes
                  .map((a) => DropdownMenuItem(value: a, child: Text(a, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _axe = v),
            ),
            const SizedBox(height: 12),
            _f(_dispo, 'Disponibilité'),
            DropdownButtonFormField<String>(
              value: _statut,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: const ['Actif', 'Inactif', 'Congé']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _statut = v ?? 'Actif'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? '...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String label,
      {bool req = false, TextInputType? kb}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: kb,
        decoration: InputDecoration(labelText: label),
        validator: req
            ? (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null
            : null,
      ),
    );
  }
}
