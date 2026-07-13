# Compiler et installer HORY.NEX (téléphone + ordinateur)

Flutter n'est pas installé sur ton ordinateur — et ce n'est **pas nécessaire**.
Grâce à **GitHub Actions**, tout se compile **dans le cloud** :

- 📱 **`HORY.NEX.apk`** → pour le **téléphone Android**
- 💻 **`HORY.NEX-Windows.zip`** → pour l'**ordinateur Windows**

Tu suis ces étapes **une seule fois**. Ensuite, chaque modification renvoyée recompile tout automatiquement.

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
- Tu verras le job **« Build HORY.NEX »** avec deux tâches : **android** et **windows**.
- Rond jaune = en cours, rond vert = terminé. Ça prend environ **5 à 15 minutes**.

> Si rien ne démarre : onglet **Actions** → clique **Build HORY.NEX** à gauche →
> bouton **Run workflow**.

## Étape 5 — Télécharger les applications
1. Quand les ronds sont **verts**, clique sur le job terminé.
2. Descends jusqu'à la section **Artifacts**. Tu y trouves :
   - **HORY.NEX-APK** → le téléphone
   - **HORY.NEX-Windows** → l'ordinateur
   - **HORY.NEX-AAB** → (seulement si un jour tu publies sur Google Play)
3. Télécharge celui qu'il te faut et **décompresse le `.zip`**.

---

## 📱 Installer sur le TÉLÉPHONE (Android)
1. Copie le fichier **`HORY.NEX.apk`** sur le téléphone
   (câble USB, WhatsApp « à moi-même », email, ou Google Drive).
2. Sur le téléphone, ouvre le fichier `HORY.NEX.apk` (appli **Fichiers** ou **Téléchargements**).
3. Android affichera « Pour ta sécurité… » → autorise
   **« Installer des applications inconnues »** pour l'appli qui ouvre le fichier.
4. Appuie sur **Installer** → **Ouvrir**. C'est fait. ✅

## 💻 Installer sur l'ORDINATEUR (Windows)
1. Décompresse **`HORY.NEX-Windows.zip`** dans un dossier, par exemple
   `C:\HORY.NEX` (clic droit → **Extraire tout…**).
2. Ouvre ce dossier : tu y trouves **`hory_nex.exe`**.
3. Double-clique **`hory_nex.exe`** pour lancer l'application. ✅
4. Pour un accès rapide : clic droit sur `hory_nex.exe` →
   **Envoyer vers** → **Bureau (créer un raccourci)**.

   > 💡 Windows peut afficher un avertissement bleu « Windows a protégé votre ordinateur »
   > (car l'appli n'est pas signée par un éditeur payant). Clique **Informations complémentaires**
   > → **Exécuter quand même**. C'est normal pour une appli maison.
   > Garde **tous** les fichiers du dossier ensemble : `hory_nex.exe` a besoin des `.dll`
   > et du dossier `data` à côté de lui pour fonctionner.

---

## Premier démarrage (identique sur les deux)
- Compte administrateur par défaut créé automatiquement — voir **GUIDE_ADMINISTRATEUR.md**
  pour l'identifiant/mot de passe initial (à changer dès la première connexion).
- L'application fonctionne **100 % hors ligne** : étudiants, paiements, reçus PDF,
  présences, planning, rapports Excel/CSV… tout marche sans internet.

## Notes importantes
- **Google Drive (sauvegarde cloud)** : fonctionne sur **Android**. Sur **Windows**,
  la connexion Google n'est pas prise en charge par la bibliothèque utilisée —
  sur PC, fais tes sauvegardes en **copiant le fichier de base** (voir `INSTALLATION.md`).
  Tout le reste de l'application fonctionne normalement sur PC.
- **Même application, deux appareils** : les données ne sont **pas** synchronisées
  automatiquement entre le téléphone et le PC. Chaque appareil a sa propre base locale.
  Pour transférer, utilise la sauvegarde/restauration du fichier de base.
- À chaque correction renvoyée sur GitHub, de **nouvelles** applications sont recompilées.
