# Guide d'installation & de compilation — HORY.NEX

## 1. Installer les outils

1. **Flutter SDK** (≥ 3.19) : https://docs.flutter.dev/get-started/install/windows
2. **Android Studio** (SDK + plateforme Android + un émulateur ou un téléphone en mode développeur).
3. Vérifier l'environnement :
   ```bash
   flutter doctor
   ```
   Toutes les lignes Android doivent être ✔.

## 2. Préparer le projet

Depuis le dossier `hory_nex/` :

```bash
flutter create --platforms=android --org com.horynex .
flutter pub get
```

> `flutter create` génère les dossiers `android/` (Gradle, MainActivity, icônes)
> **sans écraser** votre code `lib/`. Le fichier `AndroidManifest.xml` fourni (permissions
> Internet, caméra, Bluetooth) est conservé.

### Version minimale d'Android
Le scanner QR (`mobile_scanner`) exige `minSdkVersion 21`.
Ouvrez `android/app/build.gradle` et vérifiez :

```gradle
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
}
```

## 3. Configuration Google Drive (obligatoire pour la sauvegarde cloud)

1. Rendez-vous sur https://console.cloud.google.com/ → créez un projet.
2. **API & Services → Bibliothèque** → activez **Google Drive API**.
3. **Écran de consentement OAuth** → type *Externe* → renseignez le nom de l'app.
4. **Identifiants → Créer un identifiant → ID client OAuth → Android**.
   - *Nom du package* : `com.horynex`
   - *Empreinte SHA-1* : obtenez-la avec :
     ```bash
     cd android
     ./gradlew signingReport
     ```
     (copiez la SHA-1 de la variante `debug`, puis `release` pour la production).
5. Aucune clé à coller dans le code : `google_sign_in` utilise l'empreinte SHA-1 + le
   package pour l'authentification. Ajoutez simplement votre compte de test dans
   l'écran de consentement tant que l'app n'est pas vérifiée.

> Sans cette étape, tous les modules fonctionnent hors ligne ; seule la synchronisation
> Google Drive affichera une erreur de connexion.

## 4. Compiler

```bash
# APK de test rapide
flutter build apk --release

# AAB pour Google Play
flutter build appbundle --release
```

Sorties :
- `build/app/outputs/flutter-apk/app-release.apk` → renommez en **HORY.NEX.apk**
- `build/app/outputs/bundle/release/app-release.aab`

### Signature pour Google Play
1. Créez une clé :
   ```bash
   keytool -genkey -v -keystore hory-nex.jks -keyalg RSA -keysize 2048 -validity 10000 -alias horynex
   ```
2. Créez `android/key.properties` :
   ```properties
   storePassword=VOTRE_MDP
   keyPassword=VOTRE_MDP
   keyAlias=horynex
   storeFile=../hory-nex.jks
   ```
3. Configurez la signature dans `android/app/build.gradle` (bloc `signingConfigs`).

## 5. Icône de l'application (optionnel)
```bash
flutter pub add dev:flutter_launcher_icons
# placez assets/images/logo.png (1024x1024)
flutter pub run flutter_launcher_icons
```

## Dépannage
- **Échec `flutter pub get`** : lancez `flutter clean` puis réessayez.
- **Erreur `minSdk`** : passez `minSdkVersion` à 21.
- **Google Sign-In « 10 / DEVELOPER_ERROR »** : SHA-1 non déclarée ou package incorrect.
