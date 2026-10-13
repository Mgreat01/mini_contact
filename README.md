# Eli Contacts

Application Flutter simple en français pour enregistrer des contacts.

## Fonctionnalités

- Ajout et modification : nom, téléphone, e-mail facultatif.
- Validation du formulaire et recherche par nom, téléphone ou e-mail.
- Liste triée par nom et suppression avec confirmation.
- Sauvegarde locale conservée entre les lancements.
- Interface Material 3 adaptée aux écrans mobiles et larges.

## Démarrer

Prérequis : Flutter avec Dart 3.12.2 ou ultérieur et les outils de la plateforme cible.

```sh
flutter pub get
flutter run -d chrome
# Ou, avec les outils Windows installés :
flutter run -d windows
# Pour Android, démarrer un émulateur ou connecter un appareil :
flutter run
```

## Architecture

```text
lib/
  main.dart                         # Initialisation et injection du dépôt
  app.dart                          # Application et thème
  features/contacts/
    domain/                         # Entité Contact et contrat du dépôt
    data/                           # Stockage local JSON / SharedPreferences
    presentation/                   # Liste et formulaire
test/                               # Tests du stockage et parcours utilisateur
```

Le domaine ne dépend pas de Flutter. La présentation utilise un contrat de dépôt,
injecté au démarrage, permettant de remplacer le stockage sans modifier les écrans.
L'état reste local aux écrans avec `setState` pour garder ce petit projet simple.

Les contacts sont propres à l'application, sans synchronisation avec le carnet
d'adresses du téléphone ni serveur. SharedPreferences convient à ce petit registre ;
les données ne sont pas chiffrées et peuvent disparaître lors de la désinstallation
ou de l'effacement des données du navigateur.

## Vérification

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

## Git

Branche principale : `main`. Commits courts suivant Conventional Commits :
`chore:` pour l'initialisation, `feat:` pour les fonctionnalités, `test:` pour les
tests et `docs:` pour la documentation. Aucun dépôt distant configuré.

Ces conventions sont une base proposée : aucun ancien projet Flutter avec un
historique Git n'était disponible dans les dossiers voisins inspectés.
