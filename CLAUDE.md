# CLAUDE.md

Ce fichier guide Claude Code (et tout contributeur) lors de développements Swift / frameworks Apple sur ce dépôt. Il combine le contexte spécifique au projet et les règles générales à respecter pour tout code Swift destiné à l'écosystème Apple (macOS, et par extension iOS/iPadOS si le projet évolue).

## Vue d'ensemble du projet

**macOS Security Checker** est un outil en ligne de commande écrit en Swift (scripts exécutables via `#!/usr/bin/swift`, sans dépendance externe) qui audite 88 paramètres de sécurité macOS répartis en 9 catégories (pare-feu, accès distant, comptes, vie privée, iCloud, chiffrement/boot, mises à jour, fonctionnalités avancées, informations système).

- Langage : Swift 5.5+
- Plateforme : macOS 11.0 → 16.0 (Tahoe)
- Aucune dépendance tierce, uniquement `Foundation` et les commandes système (`sysctl`, `fdesetup`, `csrutil`, `spctl`, etc.) invoquées via `Process`
- Sortie : terminal coloré (ANSI), JSON, CSV — bilingue EN/FR
- Fichier principal de production : `macOSSecurityChecker.release.swift`
- Voir `FILES_GUIDE.md` pour la carte complète du dépôt et `CODE_DOCUMENTATION.md` pour l'architecture détaillée.

Ce projet est un outil **en lecture seule** : il ne doit jamais modifier l'état système de l'utilisateur. Toute contribution doit préserver cette invariance.

## Commandes utiles

```bash
# Exécution directe (sans compilation)
./macOSSecurityChecker.release.swift
./macOSSecurityChecker.release.swift --lang fr
./macOSSecurityChecker.release.swift --json
./macOSSecurityChecker.release.swift --csv

# Compilation en binaire natif
./BUILD_FOR_MACOS.sh
./build/macOSSecurityChecker

# Tests
swift macOSSecurityChecker-Tests.swift
```

Ces scripts nécessitent macOS + toolchain Swift ; ils ne s'exécutent pas dans un environnement Linux headless. En environnement CI/Linux, se limiter à la relecture statique, `swiftc -parse` pour la validation syntaxique, et ne pas prétendre avoir exécuté l'outil.

## Conventions de code Swift

Respecter les **Swift API Design Guidelines** officielles (swift.org) :

- **Clarté au point d'usage** prime sur la brièveté : `checkFirewallStatus()` plutôt que `checkFW()`.
- **Nommage** : `UpperCamelCase` pour types/protocoles, `lowerCamelCase` pour propriétés/fonctions/cas d'énumération. Les noms de méthodes sans effet de bord se lisent comme un nom (`x.distance(to: y)`), celles avec effet de bord comme un verbe impératif (`x.sort()`), avec un variant `-ed`/`-ing` pour la version non-mutante (`sorted()`).
- **Booléens et méthodes d'assertion** se lisent comme des affirmations : `isEmpty`, `firewallEnabled`, pas `checkFirewall`.
- Éviter les abréviations sauf conventions établies (`URL`, `id`). Ne pas préfixer les types avec des acronymes façon Objective-C.
- Utiliser `struct` par défaut pour les modèles de données (voir `SecurityCheck`, `EnhancedSecurityCheck`) ; réserver `class` aux cas nécessitant identité de référence ou héritage (ex. `SecurityChecker`, `TerminalColors`).
- Marquer `final` les classes qui ne sont pas conçues pour être sous-classées.
- Utiliser `enum` avec valeurs associées pour représenter les erreurs (`LocalizedError`, comme `ShellError`), jamais de codes d'erreur numériques bruts.
- Préférer l'immutabilité (`let`) par défaut ; `var` uniquement quand la mutation est nécessaire.
- Utiliser `guard` pour les sorties anticipées plutôt que des `if` imbriqués.
- Documenter les API publiques avec des commentaires `///` (Markup Swift), mais ne pas commenter l'évident — un commentaire n'a de valeur que s'il explique un *pourquoi* non trivial (contournement, contrainte système, comportement de plateforme surprenant).
- Ranger le code avec des `// MARK: -` pour la navigation Xcode, comme déjà pratiqué dans `macOSSecurityChecker-UI-Enhanced.swift`.

## Frameworks et API Apple

- Préférer les API Apple natives et documentées (`Foundation`, `Security`, `SystemConfiguration`, `IOKit`, `LocalAuthentication`, `SwiftUI`/`AppKit` si une interface graphique est ajoutée) plutôt que des solutions maison ou des bibliothèques tierces non nécessaires — ce projet reste volontairement sans dépendances externes.
- Ne jamais utiliser d'API privées ou non documentées d'Apple (`_private`, symboles non exposés dans les headers publics). Cela viole les règles de l'App Store et rend le code fragile entre versions de macOS.
- Vérifier la disponibilité des API avec `@available` / `#available` plutôt que de supposer une version minimale de macOS.
- Pour toute interaction avec des commandes système (`Process`/`NSTask`), toujours :
  - Valider et échapper les arguments — ne jamais interpoler d'entrée utilisateur non validée dans une commande shell (risque d'injection).
  - Gérer explicitement les codes de sortie non nuls et le contenu de `stderr`.
  - Documenter pourquoi l'API publique Swift/Foundation ne suffit pas et qu'un appel shell est nécessaire.
- Utiliser `Result` ou `throws`/`try` pour la gestion d'erreurs, pas de `try!` ou de force-unwrap (`!`) en dehors de cas où l'invariant est garanti et documenté.

## Sécurité et confidentialité (règles Apple)

Ce projet traite intrinsèquement de données sensibles (statut FileVault, TCC, comptes, iCloud). S'aligner sur les principes Apple :

- **Minimisation des données** : ne lire que ce qui est strictement nécessaire à l'affichage du rapport ; ne jamais transmettre, journaliser ou persister de données sensibles en dehors de la session locale de l'utilisateur, sauf demande explicite (export JSON/CSV).
- **Transparence** : toute nouvelle vérification ajoutée doit être documentée (à quoi elle sert, quelle commande/API elle utilise) dans `CODE_DOCUMENTATION.md`.
- **Pas d'élévation de privilèges cachée** : ne jamais exécuter de commande `sudo`/AppleScript avec droits admin sans consentement explicite et visible de l'utilisateur.
- Si une interface graphique (SwiftUI/AppKit) est introduite à l'avenir et doit accéder à des ressources protégées par TCC (localisation, contacts, disque complet, etc.), ajouter la clé `NSUsageDescription` correspondante dans `Info.plist` avec un texte clair expliquant l'usage — obligatoire pour la conformité App Store.
- Respecter l'**App Sandbox** et les entitlements minimaux nécessaires si le projet est un jour distribué via le Mac App Store ou notarié.
- Ne jamais désactiver de mécanismes de sécurité macOS (SIP, Gatekeeper, FileVault) par le code — l'outil est un auditeur passif, pas un outil de modification.

## Human Interface Guidelines (HIG)

Bien que le projet soit actuellement une CLI, toute future interface graphique doit respecter les [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines) :

- **Clarté** : hiérarchie visuelle nette, texte lisible, usage cohérent de la couleur (le mapping vert/rouge/jaune déjà utilisé dans le terminal doit être repris de façon cohérente en GUI — succès/alerte/erreur).
- **Cohérence** : réutiliser les composants système standard (SwiftUI `List`, `Form`, `NavigationStack`, contrôles natifs) plutôt que des widgets custom, sauf besoin fonctionnel réel.
- **Feedback** : toute action longue (scan de sécurité complet) doit fournir un indicateur de progression clair.
- **Accessibilité** : support de VoiceOver, Dynamic Type, contrastes suffisants (WCAG/Apple), navigation clavier complète sur macOS. Ne jamais transmettre une information uniquement par la couleur (toujours doubler d'une icône/texte, comme le fait déjà la sortie terminal avec ✓/✗).
- **Adaptabilité** : respecter le mode clair/sombre du système (`prefersColorScheme` dynamique, pas de couleurs codées en dur qui cassent en dark mode).
- **Localisation** : toute chaîne visible à l'utilisateur doit passer par le mécanisme de traduction existant (voir `LOCALIZATION.md`), pas de texte en dur non traduit.

## Tests

- Ajouter/étendre les tests dans `macOSSecurityChecker-Tests.swift` pour toute nouvelle vérification de sécurité ou tout changement de logique de parsing de sortie shell.
- Un test doit couvrir : le cas nominal, un cas où la commande système échoue/renvoie une sortie vide, et un cas de sortie inattendue (format changé entre versions de macOS).
- Ne pas supposer que l'environnement d'exécution est toujours macOS avec les bons privilèges ; les tests doivent isoler la logique de parsing de l'appel `Process` réel quand c'est possible.

## Git & contributions

- Commits clairs et descriptifs, en anglais ou français de façon cohérente avec l'historique du fichier modifié.
- Ne jamais committer de données de scan réelles (sorties JSON/CSV contenant des informations système d'une machine identifiable).
- Mettre à jour la documentation correspondante (`README.md`, `CODE_DOCUMENTATION.md`, `LOCALIZATION.md`, `CHANGES_SUMMARY.md`) quand un changement modifie le comportement observable de l'outil.
- Ne pas introduire de dépendances externes (SwiftPM, CocoaPods, etc.) sans justification forte : la simplicité "zéro dépendance, exécution directe via `swift`" est une contrainte de conception assumée du projet.

## Ce qu'il ne faut jamais faire

- Utiliser des API privées Apple ou contourner des mécanismes de sécurité du système.
- Exécuter des commandes destructrices ou modifiant l'état système depuis cet outil.
- Coder en dur des secrets, tokens ou identifiants.
- Ignorer les erreurs de `Process` (code de sortie, `stderr`) silencieusement.
- Ajouter du texte visible utilisateur non localisé.
