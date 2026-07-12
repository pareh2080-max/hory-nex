# Compiler HORY.NEX en ligne (sans installer Flutter)

Grâce à **GitHub Actions**, l'APK et l'AAB se compilent tout seuls dans le cloud.
Tu n'installes **rien** sur ton ordinateur. Suis ces étapes une seule fois.

---

## Étape 1 — Créer un compte GitHub (gratuit)
1. Va sur https://github.com
2. Clique **Sign up**, crée un compte (email + mot de passe). C'est gratuit.

## Étape 2 — Créer un dépôt (repository)
1. En haut à droite, clique **+** → **New repository**.
2. **Repository name** : `hory-nex`
3. Laisse **Public** (ou Private, au choix).
4. Clique **Create repository**.

## Étape 3 — Envoyer le code (par le navigateur, sans logiciel)
1. Sur la page du dépôt, clique le lien **« uploading an existing file »**
   (ou bouton **Add file → Upload files**).
2. Ouvre le dossier **`hory_nex`** sur ton ordinateur.
3. **Sélectionne TOUT ce qui est à l'intérieur** (Ctrl+A) — y compris les dossiers
   `lib`, `test`, `android`, `assets`, `.github`, et les fichiers `pubspec.yaml`, etc.
4. **Glisse-dépose** le tout dans la page GitHub.

   > ⚠️ Important : envoie **le contenu** du dossier `hory_nex`, pas le dossier lui-même.
   > Le fichier `pubspec.yaml` doit se retrouver à la racine du dépôt.
   > Le dossier `.github` (qui contient la recette de compilation) doit bien être envoyé.

5. En bas, clique **Commit changes**.

## Étape 4 — Lancer la compilation
- La compilation démarre **automatiquement** après l'envoi.
- Clique l'onglet **Actions** en haut du dépôt.
- Tu verras un job **« Build HORY.NEX »** avec un rond jaune (en cours) puis vert (terminé).
- Ça prend environ **5 à 10 minutes**.

> Si rien ne démarre : dans l'onglet **Actions**, clique **Build HORY.NEX** à gauche,
> puis le bouton **Run workflow**.

## Étape 5 — Télécharger l'APK
1. Quand le rond est **vert**, clique dessus.
2. Descends jusqu'à la section **Artifacts**.
3. Télécharge **HORY.NEX-APK** (et **HORY.NEX-AAB** pour Google Play).
4. Décompresse le `.zip` : tu obtiens **`HORY.NEX.apk`**.
5. Copie-le sur ton téléphone Android et installe-le
   (autorise « Installer des applications inconnues » si demandé).

---

## Rappels
- **Google Drive** : la sauvegarde cloud nécessite en plus la config OAuth
  (voir `INSTALLATION.md`). Tout le reste fonctionne hors ligne dès l'installation.
- **Google Play** : pour publier, l'AAB doit être **signé** (voir `INSTALLATION.md`,
  section signature). L'APK non signé s'installe très bien à la main pour tester.
- À chaque modification renvoyée sur GitHub, une nouvelle APK est recompilée automatiquement.
