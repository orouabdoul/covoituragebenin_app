# MINIZON

Application Flutter de covoiturage au Benin, avec des parcours dedies aux
passagers et aux conducteurs.

## Prerequis

- Flutter compatible avec le SDK Dart `^3.13.1`
- Android Studio ou Xcode selon la plateforme ciblee
- Un projet Firebase configure pour les notifications push

## Installation

```bash
flutter pub get
flutter analyze
flutter test
```

Pour lancer l'application sur un appareil ou un emulateur :

```bash
flutter run
```

## Organisation

Le code applicatif se trouve dans `lib/app` et conserve une organisation
modulaire basee sur GetX :

- `core/` : constantes, controleurs globaux, services et utilitaires
- `data/` : modeles, providers et repositories
- `modules/` : ecrans fonctionnels avec `bindings/`, `controllers/` et `views/`
- `routes/` : noms de routes et declaration des pages GetX

Les fonctionnalites principales sont regroupees dans :

- `modules/auth/` et `modules/onboarding/` pour l'acces a l'application
- `modules/principal/passager/` pour le parcours passager
- `modules/principal/driver/` pour le parcours conducteur
- `modules/widgets/` pour les composants d'interface reutilisables

## Demarrage

L'application commence par la route splash. Celle-ci verifie l'onboarding et
la session utilisateur avant de rediriger vers le parcours d'inscription ou le
dashboard correspondant au role de l'utilisateur.

Les dependances globales et les services sont initialises dans `lib/main.dart`.
Les routes sont centralisees dans `lib/app/routes/app_routes.dart` et
`lib/app/routes/app_pages.dart`.

## Tests

Les tests du dossier `test/` verifient les contrats de routage essentiels.
Les ecrans qui necessitent Firebase, SharedPreferences ou un backend doivent
etre testes avec des dependances simulees avant d'etre integres a des tests
widget de demarrage.
