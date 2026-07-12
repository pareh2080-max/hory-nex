# Guide administrateur — HORY.NEX

## 1. Rôles et permissions

| Rôle | Étudiants | Paiements | Encadreurs | Présences | Sauvegarde | Utilisateurs |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Administrateur** | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| **Caissier** | ✔ | ✔ | — | — | — | — |
| **Encadreur** | ✔ | — | — | ✔ | — | — |
| **Utilisateur** | consultation | — | — | — | — | — |

## 2. Premier démarrage
- Compte par défaut : **admin / admin123**.
- **Action prioritaire** : *Paramètres → Sécurité → Changer mon mot de passe*.

## 3. Gérer les utilisateurs
*Paramètres → Gérer les utilisateurs & rôles* :
- **Ajouter** un utilisateur (nom, identifiant, mot de passe, rôle).
- **Activer / désactiver** un compte via l'interrupteur.
Les mots de passe sont stockés **hachés (SHA-256 + sel)** — jamais en clair.

## 4. Sauvegarde & restauration Google Drive
*Module Sauvegarde Drive* :
- **Synchroniser avec Google Drive** : envoie la base complète (étudiants, paiements,
  présences, horaires, encadreurs, calendrier) sur votre Drive.
- **Restaurer depuis Google Drive** : en cas de changement de téléphone, réinstallez
  l'app, connectez-vous, puis restaurez — toutes les données reviennent.

> ⚠️ La restauration **remplace** la base locale par celle du cloud. Sauvegardez
> avant de restaurer si le téléphone contient des données plus récentes.

**Bonne pratique** : effectuez une sauvegarde à la fin de chaque journée de travail.

## 5. Rapports & exports
Module **Rapports** : générez les rapports **journalier / hebdomadaire / mensuel /
annuel**, des **paiements**, **présences**, **étudiants** et **encadreurs**, exportables
en **PDF, Excel et CSV** pour l'archivage ou l'envoi à la direction.

## 6. Reçus
Chaque paiement peut produire un **reçu PDF officiel** (logo, QR Code, code-barres,
nom du caissier, signature numérique) partageable par WhatsApp, Email, Bluetooth ou
imprimable.

## 7. Sécurité des données
- Base **SQLite locale** : fonctionne 100 % hors ligne.
- Mots de passe chiffrés.
- Sauvegarde chiffrée côté Google (transport HTTPS + espace privé du compte).
- Aucune donnée personnelle n'est envoyée à des tiers.

## 8. Performance
La base est **indexée** (nom, matricule, département, filière, dates) : les recherches
et les rapports restent rapides même avec **plusieurs milliers d'étudiants**.

## 9. Maintenance
- Mettez à jour Flutter : `flutter upgrade`.
- Recompilez : `flutter build appbundle --release`.
- Les migrations de base sont gérées dans `DatabaseHelper` (`onUpgrade`) : incrémentez
  `dbVersion` pour toute évolution du schéma.
