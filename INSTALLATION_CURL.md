# macOS Security Checker - Installation par Curl

Installation rapide et facile du macOS Security Checker en une seule commande!

## 🚀 Installation Ultra-Rapide (30 secondes)

```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash
```

**C'est tout!** L'application est installée et prête à utiliser.

### Utilisation Immédiate

```bash
# Exécuter l'audit en anglais (défaut)
macos-security-checker

# Audit en français
macos-security-checker --lang fr

# Obtenir de l'aide
macos-security-checker --help

# Exporter en JSON
macos-security-checker --json > audit.json
```

---

## 📦 Installation Interactive (avec options)

Pour plus d'options (choix entre script et binaire compilé):

```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/install.sh | bash
```

Cette version vous propose:
- **Option 1**: Script direct (28 KB, aucune compilation)
- **Option 2**: Binaire compilé (2x plus rapide)

---

## 🔍 Qu'est-ce qui se passe lors de l'installation?

### Installation Script (quick-install.sh):
1. ✅ Vérifie macOS (11.0+ required)
2. ✅ Télécharge le script depuis GitHub (28 KB)
3. ✅ Copie dans `/usr/local/bin/macos-security-checker`
4. ✅ Rend exécutable
5. ✅ Prêt à utiliser!

### Installation Interactive (install.sh):
1. ✅ Même vérifications que quick-install
2. ✅ Vous propose le choix: script ou binaire
3. ✅ Télécharge la version sélectionnée
4. ✅ Installation complète
5. ✅ Affiche les commandes de démarrage

---

## 📋 Prérequis

### Système
- macOS 11.0 ou plus récent (Big Sur+)
- Processeur: Intel ou Apple Silicon (M1/M2/M3+)
- RAM: Minimal (< 50 MB d'utilisation)
- Disque: 28 KB (script) ou 500 KB (binaire)

### Outils requis
- `curl` (pré-installé sur macOS)
- `bash` (pré-installé sur macOS)

**Aucune dépendance externe!** Swift est optionnel (pour la compilation).

---

## 💻 Commandes Détaillées

### Installation Ultra-Rapide

```bash
# Copier-coller cette commande exactement:
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash
```

Options de curl expliquées:
- `-f`: Fail si erreur HTTP
- `-s`: Silencieux (pas de barre de progression)
- `-S`: Montre les erreurs même en mode silencieux
- `-L`: Suit les redirects
- `| bash`: Exécute le script téléchargé

### Installation Interactive

```bash
# Avec choix entre script et binaire:
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/install.sh | bash
```

Pendant l'exécution, vous serez invité à choisir:
```
Installation Options:
   1. Script (28 KB) - Direct execution, no compilation
   2. Binary (optimized) - Pre-compiled, faster

Choose installation method (1 or 2) [default: 1]:
```

---

## 🛠️ Dépannage d'Installation

### Erreur: "curl: command not found"
```bash
# curl devrait être pré-installé, mais si absent:
# Télécharger manuellement depuis GitHub:
# https://github.com/hdrapin/macOSSecurityChecker/releases
```

### Erreur: "Permission denied"
```bash
# Le script demande sudo pour /usr/local/bin
# Vous devrez entrer votre mot de passe macOS
```

### Erreur: "macOS version not supported"
```bash
# Vous avez besoin de macOS 11.0 ou plus récent
# Mettez à jour votre système ou utilisez une méthode d'installation alternative
```

### Erreur: "Cannot find command after installation"
```bash
# Rafraîchir votre shell:
source ~/.zprofile
# ou
source ~/.bash_profile
```

### Vérifier l'installation

```bash
# Vérifier que la commande existe:
which macos-security-checker

# Vérifier la version:
macos-security-checker --version

# Afficher l'aide:
macos-security-checker --help
```

---

## 🔄 Mise à Jour

### Mettre à jour vers une nouvelle version

```bash
# Réinstaller avec la dernière version:
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash

# Le nouveau script remplace l'ancien automatiquement
```

---

## 📍 Emplacements d'Installation

Après installation via curl, le fichier est situé à:

```bash
# Script location:
/usr/local/bin/macos-security-checker

# Accès depuis n'importe où dans le terminal:
macos-security-checker
macos-security-checker --lang fr
macos-security-checker --json
```

---

## 🌍 Utilisation Multilingue

Après installation, vous pouvez utiliser:

```bash
# English (défaut)
macos-security-checker

# Français
macos-security-checker --lang fr

# Anglais explicite
macos-security-checker --lang en

# Avec d'autres options
macos-security-checker --lang fr --json
macos-security-checker --lang en --verbose
macos-security-checker --lang fr --csv
```

---

## 📊 Formats de Sortie

Après installation, tous les formats de sortie sont disponibles:

```bash
# Texte formaté avec couleurs
macos-security-checker

# JSON pour programmation
macos-security-checker --json > audit.json

# CSV pour feuille de calcul
macos-security-checker --csv > audit.csv

# Mode détaillé
macos-security-checker --verbose

# Français + JSON
macos-security-checker --lang fr --json
```

---

## 🔒 Sécurité et Confidentialité

### Installation Sûre
✅ Script téléchargé directement depuis GitHub  
✅ Exécution transparente (vous voyez ce qui se passe)  
✅ Pas de données collectées  
✅ Pas de connexions externes après installation  

### Privacy
✅ **Audit local uniquement** - Aucune donnée envoyée  
✅ **Read-only** - Aucune modification système  
✅ **No telemetry** - Aucun suivi  
✅ **Open source** - Code visible et vérifiable  

---

## 📚 Prochaines Étapes

### 1. Exécution Immédiate
```bash
macos-security-checker
```

### 2. Lire la Documentation Complète
```bash
# Voir le README complet:
cat $(which macos-security-checker | xargs dirname)/../README.md
# ou visiter: https://github.com/hdrapin/macOSSecurityChecker
```

### 3. Mettre en Place des Audits Réguliers
```bash
# Audit hebdomadaire (example avec cron):
# Ajoutez à votre crontab:
0 2 * * 1 macos-security-checker --json >> ~/security_audits.json
```

### 4. Explorer les Options
```bash
macos-security-checker --help
macos-security-checker --version
```

---

## 🆘 Support et Aide

### Aide Rapide
```bash
macos-security-checker --help
```

### Problèmes d'Installation
- Documentation complète: https://github.com/hdrapin/macOSSecurityChecker
- Signaler un bug: https://github.com/hdrapin/macOSSecurityChecker/issues
- Discussions: https://github.com/hdrapin/macOSSecurityChecker/discussions

### Mise en Œuvre Alternative
Si l'installation par curl n'est pas disponible, téléchargez directement:
https://github.com/hdrapin/macOSSecurityChecker/releases

---

## 📝 Scripts d'Installation Disponibles

### quick-install.sh (Recommandé)
- Ultra-rapide (30 secondes)
- Minimal output
- Installation script uniquement
- Parfait pour la plupart des utilisateurs

```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash
```

### install.sh (Avancé)
- Installation interactive
- Choix: script ou binaire compilé
- Vérifications détaillées
- Idéal pour utilisateurs avancés

```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/install.sh | bash
```

### Installation Manuelle
```bash
# Télécharger le script
curl -o macos-security-checker \
  https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/macOSSecurityChecker.release.swift

# Rendre exécutable
chmod +x macos-security-checker

# Installer système-wide (optionnel)
sudo mv macos-security-checker /usr/local/bin/
```

---

**Prêt à auditer votre Mac?** 🚀

```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash
macos-security-checker
```

---

**Dernière mise à jour:** Mai 2024  
**Version:** 2.0.1  
**Status:** Production Ready ✓
