import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/data/filieres.dart';
import '../../core/data/haiti_locations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/student.dart';
import '../../providers.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final Student? student;
  const StudentFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _dateNaissance = TextEditingController();
  final _nif = TextEditingController();
  final _cin = TextEditingController();
  final _tel = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _adresse = TextEditingController();
  final _sectionCommunale = TextEditingController();
  final _ecole = TextEditingController();
  final _anneeScolaire = TextEditingController();
  final _nomParent = TextEditingController();
  final _telParent = TextEditingController();
  final _profession = TextEditingController();
  final _montant = TextEditingController();

  String? _sexe;
  String? _departement;
  String? _commune;
  String? _axe;
  String? _filiere;
  String? _photoPath;
  bool _saving = false;

  bool get _isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    if (s != null) {
      _nom.text = s.nom;
      _prenom.text = s.prenom;
      _dateNaissance.text = s.dateNaissance ?? '';
      _nif.text = s.nif ?? '';
      _cin.text = s.cin ?? '';
      _tel.text = s.telephone ?? '';
      _whatsapp.text = s.whatsapp ?? '';
      _email.text = s.email ?? '';
      _adresse.text = s.adresse ?? '';
      _sectionCommunale.text = s.sectionCommunale ?? '';
      _ecole.text = s.ecolePrecedente ?? '';
      _anneeScolaire.text = s.anneeScolaire ?? '';
      _nomParent.text = s.nomParent ?? '';
      _telParent.text = s.telParent ?? '';
      _profession.text = s.professionParent ?? '';
      _montant.text = s.montantPrepac == 0 ? '' : s.montantPrepac.toString();
      _sexe = s.sexe;
      _departement = s.departement;
      _commune = s.commune;
      _axe = s.axe;
      _filiere = s.filiere;
      _photoPath = s.photoPath;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nom, _prenom, _dateNaissance, _nif, _cin, _tel, _whatsapp, _email,
      _adresse, _sectionCommunale, _ecole, _anneeScolaire, _nomParent,
      _telParent, _profession, _montant
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      _dateNaissance.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(studentRepoProvider);
    final montant = double.tryParse(_montant.text.replaceAll(',', '.')) ?? 0;

    final draft = Student(
      id: widget.student?.id ?? '',
      matricule: widget.student?.matricule ?? '',
      photoPath: _photoPath,
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      sexe: _sexe,
      dateNaissance: _dateNaissance.text.trim(),
      nif: _nif.text.trim(),
      cin: _cin.text.trim(),
      telephone: _tel.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      email: _email.text.trim(),
      adresse: _adresse.text.trim(),
      departement: _departement,
      commune: _commune,
      sectionCommunale: _sectionCommunale.text.trim(),
      ecolePrecedente: _ecole.text.trim(),
      anneeScolaire: _anneeScolaire.text.trim(),
      dateInscription: widget.student?.dateInscription,
      nomParent: _nomParent.text.trim(),
      telParent: _telParent.text.trim(),
      professionParent: _profession.text.trim(),
      axe: _axe,
      filiere: _filiere,
      montantPrepac: montant,
      createdAt: widget.student?.createdAt ?? '',
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
    final communes = HaitiLocations.communesDe(_departement);
    final filieres = Filieres.filieresDe(_axe);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifier étudiant' : 'Inscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.grisClair,
                  backgroundImage:
                      (_photoPath != null && File(_photoPath!).existsSync())
                          ? FileImage(File(_photoPath!))
                          : null,
                  child: (_photoPath == null || !File(_photoPath!).existsSync())
                      ? const Icon(Icons.add_a_photo, color: AppColors.grisMoyen)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _section('Identité'),
            _field(_prenom, 'Prénom *', required: true),
            _field(_nom, 'Nom *', required: true),
            _dropdown('Sexe', _sexe, const ['Masculin', 'Féminin'],
                (v) => setState(() => _sexe = v)),
            TextFormField(
              controller: _dateNaissance,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),
            _field(_nif, 'NIF (optionnel)'),
            _field(_cin, 'CIN (optionnel)'),
            const SizedBox(height: 8),
            _section('Contact'),
            _field(_tel, 'Téléphone', keyboard: TextInputType.phone),
            _field(_whatsapp, 'WhatsApp', keyboard: TextInputType.phone),
            _field(_email, 'Email', keyboard: TextInputType.emailAddress),
            _field(_adresse, 'Adresse'),
            const SizedBox(height: 8),
            _section('Localisation'),
            _dropdown('Département', _departement, HaitiLocations.departements,
                (v) => setState(() {
                      _departement = v;
                      _commune = null;
                    })),
            _dropdown('Commune', _commune, communes,
                (v) => setState(() => _commune = v),
                enabled: _departement != null),
            _field(_sectionCommunale, 'Section communale (option)'),
            const SizedBox(height: 8),
            _section('Scolarité'),
            _field(_ecole, 'École précédente'),
            _field(_anneeScolaire, 'Année scolaire'),
            _dropdown('Axe PREPAC', _axe, Filieres.axes, (v) => setState(() {
                  _axe = v;
                  _filiere = null;
                })),
            _dropdown('Filière', _filiere, filieres,
                (v) => setState(() => _filiere = v),
                enabled: _axe != null),
            const SizedBox(height: 8),
            _section('Parent / Tuteur'),
            _field(_nomParent, 'Nom du parent'),
            _field(_telParent, 'Téléphone du parent', keyboard: TextInputType.phone),
            _field(_profession, 'Profession'),
            const SizedBox(height: 8),
            _section('Frais PREPAC'),
            _field(_montant, 'Montant PREPAC (HTG)',
                keyboard: TextInputType.number),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.bleuFonce,
                fontSize: 15)),
      );

  Widget _field(TextEditingController c, String label,
      {bool required = false, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null
            : null,
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
