# HORY.NEX

Application Android professionnelle de gestion complète d'une organisation **PREPAC** en Haïti.
100 % hors ligne (SQLite) avec synchronisation et restauration via **Google Drive**.

> Développée en **Flutter / Dart**, architecture **MVVM** + **Riverpod**, **Material Design 3**
> (mode clair & sombre), couleurs bleu foncé / vert / blanc / gris clair.

---

## ✨ Fonctionnalités

| Module | Contenu |
|---|---|
| 🏠 Tableau de bord | Totaux étudiants/encadreurs, présences & paiements du jour, encaissé, reste à payer, rapports hebdo/mensuel, communes, graphique 7 jours |
| 👨‍🎓 Étudiants | Fiche d'inscription complète, photo, matricule auto, 10 départements + communes d'Haïti, recherche instantanée, QR Code |
| 👨‍🏫 Encadreurs | Fiche complète (spécialité, matière, axe, disponibilité, statut) |
| 📚 Filières | 3 axes PREPAC (Scientifique, Agro-médical, Sciences humaines) |
| 💰 Paiements | Montant PREPAC, payé, solde, modes (Espèces/MonCash/NatCash/Virement/Chèque), historique, statut |
| 🧾 Reçus | PDF avec logo, QR Code, code-barres, signature — Imprimer / Partager / WhatsApp / Email / Bluetooth |
| 📅 Présences | Marquage quotidien (présent/absent/retard), statistiques |
| 🗓 Horaire | Planning hebdomadaire avec **glisser-déposer** |
| 🗓 Calendrier | Événements (cours, examens, réunions, paiements, vacances, rappels) |
| 📄 Rapports | Étudiants & paiements exportables en **PDF / Excel / CSV** |
| ☁ Sauvegarde Drive | Sauvegarde & restauration complète de la base |
| ⚙ Paramètres | Thème, mot de passe chiffré, gestion des utilisateurs & rôles |

### Sécurité
Connexion multi-rôles (**Administrateur, Caissier, Encadreur, Utilisateur**), permissions
différenciées, mots de passe hachés (SHA-256 + sel aléatoire par utilisateur).

---

## 🚀 Démarrage rapide

> Prérequis : [Flutter SDK](https://docs.flutter.dev/get-started/install) (≥ 3.19) + Android SDK.

```bash
# 1. Générer les dossiers de plateforme (Android) sans écraser le code source
flutter create --platforms=android --org com.horynex .

# 2. Installer les dépendances
flutter pub get

# 3. Lancer sur un appareil/émulateur connecté
flutter run

# 4. Lancer les tests
flutter test
```

### Compiler les livrables

```bash
# APK (renommé HORY.NEX.apk)
flutter build apk --release
#  -> build/app/outputs/flutter-apk/app-release.apk

# AAB (Google Play)
flutter build appbundle --release
#  -> build/app/outputs/bundle/release/app-release.aab
```

Après compilation, renommez l'APK : `HORY.NEX.apk`.

---

## 🔐 Première connexion

| Identifiant | Mot de passe |
|---|---|
| `admin` | `admin123` |

**Changez ce mot de passe immédiatement** dans *Paramètres → Sécurité*.

---

## 📂 Structure du projet

```
lib/
├── main.dart                 # Point d'entrée (init DB, admin, prefs)
├── app.dart                  # MaterialApp + thème
├── providers.dart            # Providers Riverpod (repos, auth, thème)
├── core/
│   ├── theme/                # Couleurs + thème Material 3
│   ├── data/                 # Départements/communes d'Haïti, filières
│   ├── db/                   # DatabaseHelper (schéma SQLite + index)
│   ├── security/             # Hachage des mots de passe
│   └── utils/                # Formatage (monnaie, dates)
├── models/                   # Student, Encadreur, Payment, Attendance, ...
├── repositories/             # Accès aux données (CRUD, recherche, stats)
├── services/                 # PDF reçus, rapports, Google Drive
└── ui/                       # Écrans par module (MVVM)
test/                         # Tests unitaires
```

---

## ⚠️ Points nécessitant votre configuration

- **Google Drive** : nécessite un identifiant OAuth Android. Voir [INSTALLATION.md](INSTALLATION.md).
- **Icône & logo** : un logo vectoriel intégré est fourni ; pour une vraie icône
  d'application, placez `logo.png` dans `assets/images/` et utilisez
  [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons).

Voir aussi : [GUIDE_UTILISATEUR.md](GUIDE_UTILISATEUR.md) · [GUIDE_ADMINISTRATEUR.md](GUIDE_ADMINISTRATEUR.md)
