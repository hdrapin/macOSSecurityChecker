# macOS Security Checker v2.0 - Documentation Complète

[English Version Below](#english-version) | [Version Française](#version-française)

---

## Version Française

# 🔒 macOS Security Checker v2.0

Une **application de contrôle de sécurité macOS professionnelle** qui analyse **88 paramètres de sécurité** du système pour fournir une évaluation complète de votre configuration de sécurité.

**Version:** 2.0.0  
**Date:** Mai 2024  
**Compatible:** macOS 11.0+ (Big Sur à Tahoe)  
**Licence:** Apache License 2.0

## 📋 Table des matières
- [Caractéristiques principales](#caractéristiques-principales)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [88 Contrôles de sécurité](#88-contrôles-de-sécurité)
- [Format de sortie](#format-de-sortie)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Dépannage](#dépannage)
- [FAQ](#faq)

## ✨ Caractéristiques principales

### 🎯 88 Contrôles de sécurité
Analyse complète organisée en **9 catégories**:
- 🖥️ Informations système (5 contrôles)
- 🔥 Pare-feu et sécurité réseau (9 contrôles)
- 📱 Accès à distance (8 contrôles)
- 👤 Sécurité des comptes utilisateurs (6 contrôles)
- 🔍 Confidentialité et suivi (9 contrôles)
- ☁️ iCloud et authentification (8 contrôles)
- 🛡️ Chiffrement et sécurité de démarrage (9 contrôles)
- 🔄 Mises à jour système (5 contrôles)
- ⚙️ Fonctionnalités de sécurité avancées (6 contrôles)

### 🎨 Interface de terminal améliorée
- ✅ Détection automatique des couleurs ANSI
- ✅ Barres de progression visuelles
- ✅ Code couleur: Vert ✓ / Rouge ✗ / Jaune ⚠️
- ✅ Organisation par catégories
- ✅ Score de sécurité 0-10 avec indicateur visuel

### 📊 Formats de sortie multiples
- **Text**: Résultat formaté avec couleurs
- **JSON**: Pour intégration avec d'autres outils
- **CSV**: Pour analyse dans Excel/Sheets
- **HTML** (optionnel): Rapport visuel

### 🌐 Support Multilingue
- 🇫🇷 **Français** (par défaut ou avec --lang fr)
- 🇬🇧 **Anglais** (avec --lang en)

### ⚡ Performance
- ⏱️ Analyse complète en 4-5 secondes
- 💾 Minimal (< 50 MB RAM)
- 🚀 Pas de dépendances externes
- 🔐 Aucun appel réseau - audit local uniquement

## 🚀 Installation

### Méthode 1: Exécution directe (Recommandée)
```bash
# Cloner le dépôt
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker

# Rendre exécutable
chmod +x macOSSecurityChecker.release.swift

# Exécuter directement
./macOSSecurityChecker.release.swift
```

### Méthode 2: Compiler en binaire natif
```bash
# Utiliser le script de compilation
./BUILD_FOR_MACOS.sh

# Exécuter le binaire compilé
./build/macOSSecurityChecker
```

### Méthode 3: Installation système-wide
```bash
# Copier dans /usr/local/bin
sudo cp macOSSecurityChecker.release.swift /usr/local/bin/macos-security-checker
sudo chmod +x /usr/local/bin/macos-security-checker

# Utiliser depuis n'importe où
macos-security-checker --help
```

## 📖 Utilisation

### Commandes de base
```bash
# Audit complet (français)
./macOSSecurityChecker.release.swift

# Audit en anglais
./macOSSecurityChecker.release.swift --lang en

# Mode détaillé avec explications
./macOSSecurityChecker.release.swift --verbose

# Aide
./macOSSecurityChecker.release.swift --help

# Version
./macOSSecurityChecker.release.swift --version
```

### Formats de sortie
```bash
# Sortie JSON pour traitement automatique
./macOSSecurityChecker.release.swift --json > audit.json

# Sortie CSV pour feuille de calcul
./macOSSecurityChecker.release.swift --csv > audit.csv

# Sortie texte (défaut)
./macOSSecurityChecker.release.swift --text
```

### Options de langue
```bash
# Français (par défaut)
./macOSSecurityChecker.release.swift --lang fr

# Anglais
./macOSSecurityChecker.release.swift --lang en

# Français + JSON
./macOSSecurityChecker.release.swift --lang fr --json
```

## 🔒 88 Contrôles de sécurité

### 🖥️ Informations système (5)
| Contrôle | Source | Description |
|----------|--------|-------------|
| Modèle Mac | `sysctl` | Identifiant du modèle système |
| Version macOS | `sw_vers` | Version du système d'exploitation |
| Numéro de build | `sw_vers` | Identifiant de build complet |
| Processeur | `sysctl` | Type et nombre de cœurs |
| Mémoire système | `vm_stat` | RAM totale disponible |

### 🔥 Pare-feu et sécurité réseau (9)
| Contrôle | Statut | Description |
|----------|--------|-------------|
| Pare-feu activé | Dynamique | État du pare-feu macOS |
| Mode discrétion pare-feu | Dynamique | Mode furtif réseau |
| SSH distant activé | Dynamique | Accès SSH à distance |
| Partage d'écran | Dynamique | Partage d'écran Apple |
| Partage de fichiers SMB | Dynamique | Partage réseau Windows |
| Bluetooth activé | Dynamique | État Bluetooth |
| Bluetooth découvrable | Dynamique | Visibilité auprès des appareils |
| Réveil réseau | Dynamique | Wake-on-Network |
| Bonjour/mDNS | Dynamique | Découverte réseau local |

### 📱 Accès à distance (8)
Contrôles SSH, Apple Remote Desktop, Remote Events, AirDrop, Presse-papiers universel

### 👤 Sécurité des comptes (6)
Connexion auto, Compte invité, Commutation rapide, Politique de mot de passe, Limite d'essais échoués

### 🔍 Confidentialité et suivi (9)
Services de localisation, Safari, Siri, Spotlight, Indicateurs microphore/caméra

### ☁️ iCloud et authentification (8)
Authentification 2FA, Trousseau iCloud, Localiser mon Mac, Continuité, Jeton sécurisé, Touch ID

### 🛡️ Chiffrement et démarrage (9)
FileVault, Démarrage sécurisé, SIP, Volume système signé, Mot de passe firmware, Mode USB restreint

### 🔄 Mises à jour système (5)
Mises à jour automatiques, État des correctifs, XProtect, MRT, Mises à jour critiques

### ⚙️ Fonctionnalités avancées (6)
Protection mémoire noyau, Filtrage arguments boot, Gatekeeper, Versions XProtect/MRT, IPv6

## 📊 Format de sortie

### Sortie par défaut (Texte formaté)
```
╔═══════════════════════════════════════════════════════════════════╗
│  🔒 macOS SECURITY AUDIT REPORT v2.0.0 🔒                        │
│  MacBook Pro 16-inch M3 Max                                       │
│  macOS 15.1 (Sequoia)                                             │
│  Status: 75/88 checks passed (85.2%)                              │
│  Score: 8.5/10 - EXCELLENT                                        │
└═══════════════════════════════════════════════════════════════════┘

[███████████████████████████████████████░░░░░░░░░░] 85.2%

🔥 FIREWALL & NETWORK SECURITY (9/9 PASSED)
  ✓ Firewall Enabled                   ENABLED
  ✓ Firewall Stealth Mode              ENABLED
  ✗ SSH Enabled                        ENABLED (⚠️ review if needed)
  ...
```

### Sortie JSON
```json
{
  "metadata": {
    "timestamp": "2024-05-04T15:30:00Z",
    "version": "2.0.0",
    "score": 8.5,
    "riskLevel": "EXCELLENT",
    "passedChecks": 75,
    "totalChecks": 88
  },
  "system": {
    "macModel": "MacBook Pro 16-inch (M3 Max, 2024)",
    "osVersion": "15.1 (Sequoia)",
    "buildNumber": "24B80",
    "processor": "Apple M3 Max (12-core)",
    "memory": "36.0 GB"
  },
  "security": {
    "fileVault": true,
    "secureBoot": true,
    "systemIntegrityProtection": true,
    "sip": true
  },
  ...
}
```

### Sortie CSV
```csv
Catégorie,Contrôle,Statut,Détails
System,Mac Model,ENABLED,MacBook Pro 16-inch
Firewall,Firewall Enabled,ENABLED,
Privacy,Safari Privacy,ENABLED,
...
```

## 💡 Exemples d'utilisation

### Audit régulier
```bash
# Audit quotidien
0 2 * * * /path/to/macOSSecurityChecker.release.swift > /var/log/audit_$(date +\%Y\%m\%d).txt

# Audit hebdomadaire en JSON
0 8 * * 1 /path/to/macOSSecurityChecker.release.swift --lang fr --json > /var/log/audit_$(date +\%Y\%m\%d).json
```

### Intégration avec scripts
```bash
# Vérifier FileVault uniquement
RESULT=$(./macOSSecurityChecker.release.swift --json)
FILEVAULT=$(echo "$RESULT" | jq '.security.fileVault')
echo "FileVault: $FILEVAULT"

# Extraire le score de sécurité
./macOSSecurityChecker.release.swift --json | jq '.metadata.score'

# Obtenir les recommandations
./macOSSecurityChecker.release.swift --json | jq '.recommendations'
```

### Conformité et rapports
```bash
# Rapport détaillé en français
./macOSSecurityChecker.release.swift --verbose --lang fr > rapport_$(date +%Y%m%d).txt

# Rapport JSON pour analyse ultérieure
./macOSSecurityChecker.release.swift --json --lang fr | jq '.' > audit_$(date +%Y%m%d).json
```

## 🛠️ Dépannage

### Le script ne s'exécute pas
```bash
# Vérifier les permissions
chmod +x macOSSecurityChecker.release.swift

# Exécuter directement avec Swift
swift macOSSecurityChecker.release.swift

# Avec privilèges admin si nécessaire
sudo ./macOSSecurityChecker.release.swift
```

### Certains contrôles affichent "Unknown"
```bash
# Certains contrôles nécessitent les privilèges admin
sudo ./macOSSecurityChecker.release.swift

# Ou avec les options souhaitées
sudo ./macOSSecurityChecker.release.swift --lang fr --json
```

### Pas de couleur dans le terminal
```bash
# Force le support des couleurs
TERM=xterm-256color ./macOSSecurityChecker.release.swift

# Ou utiliser le format CSV/JSON
./macOSSecurityChecker.release.swift --json
```

## ❓ FAQ

**Q: Est-ce que cet outil modifie mon système?**  
A: Non, c'est un outil de lecture seule. Il analyse uniquement, ne modifie jamais.

**Q: Est-ce que cela nécessite une connexion Internet?**  
A: Non, c'est complètement local. Tous les contrôles se font sur votre Mac.

**Q: Tous les contrôles nécessitent-ils sudo?**  
A: Non, la plupart fonctionnent sans. Certains contrôles avancés nécessitent sudo.

**Q: Est-ce compatible avec Tahoe (macOS 16)?**  
A: Oui, fully compatible.

**Q: Puis-je l'utiliser en production?**  
A: Oui, c'est entièrement sûr. Pas de modifications, audit local uniquement.

## 📞 Support

- 📖 **Documentation**: Voir README.md
- 🐛 **Issues**: Signaler sur GitHub
- ❓ **Questions**: Vérifier les documents existants
- 🔐 **Sécurité**: Rapporter les problèmes de sécurité aux mainteneurs

---

## English Version

# 🔒 macOS Security Checker v2.0

A **professional macOS security control application** that analyzes **88 system security parameters** to provide a comprehensive assessment of your security configuration.

**Version:** 2.0.0  
**Date:** May 2024  
**Compatible:** macOS 11.0+ (Big Sur to Tahoe)  
**License:** Apache License 2.0

## 📋 Table of Contents
- [Key Features](#key-features)
- [Installation](#installation-1)
- [Usage](#usage)
- [88 Security Controls](#88-security-controls)
- [Output Format](#output-format)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting-1)
- [FAQ](#faq-1)

## ✨ Key Features

### 🎯 88 Security Controls
Comprehensive analysis organized in **9 categories**:
- 🖥️ System Information (5 controls)
- 🔥 Firewall and network security (9 controls)
- 📱 Remote access (8 controls)
- 👤 User account security (6 controls)
- 🔍 Privacy and tracking (9 controls)
- ☁️ iCloud and authentication (8 controls)
- 🛡️ Encryption and boot security (9 controls)
- 🔄 System updates (5 controls)
- ⚙️ Advanced security features (6 controls)

### 🎨 Enhanced Terminal Interface
- ✅ Automatic ANSI color detection
- ✅ Visual progress bars
- ✅ Color coding: Green ✓ / Red ✗ / Yellow ⚠️
- ✅ Category-based organization
- ✅ Security score 0-10 with visual indicator

### 📊 Multiple Output Formats
- **Text**: Formatted output with colors
- **JSON**: For integration with other tools
- **CSV**: For analysis in Excel/Sheets
- **HTML** (optional): Visual report

### 🌐 Multilingual Support
- 🇬🇧 **English** (default or --lang en)
- 🇫🇷 **French** (--lang fr)

### ⚡ Performance
- ⏱️ Complete analysis in 4-5 seconds
- 💾 Minimal (< 50 MB RAM)
- 🚀 No external dependencies
- 🔐 No network calls - local audit only

## 🚀 Installation

### Method 1: Direct Execution (Recommended)
```bash
# Clone repository
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker

# Make executable
chmod +x macOSSecurityChecker.release.swift

# Run directly
./macOSSecurityChecker.release.swift
```

### Method 2: Compile to Native Binary
```bash
# Use compilation script
./BUILD_FOR_MACOS.sh

# Run compiled binary
./build/macOSSecurityChecker
```

### Method 3: System-wide Installation
```bash
# Copy to /usr/local/bin
sudo cp macOSSecurityChecker.release.swift /usr/local/bin/macos-security-checker
sudo chmod +x /usr/local/bin/macos-security-checker

# Use from anywhere
macos-security-checker --help
```

## 📖 Usage

### Basic Commands
```bash
# Full audit (English)
./macOSSecurityChecker.release.swift

# Audit in French
./macOSSecurityChecker.release.swift --lang fr

# Detailed mode with explanations
./macOSSecurityChecker.release.swift --verbose

# Help
./macOSSecurityChecker.release.swift --help

# Version
./macOSSecurityChecker.release.swift --version
```

### Output Formats
```bash
# JSON output for automated processing
./macOSSecurityChecker.release.swift --json > audit.json

# CSV output for spreadsheet
./macOSSecurityChecker.release.swift --csv > audit.csv

# Text output (default)
./macOSSecurityChecker.release.swift --text
```

### Language Options
```bash
# English (default)
./macOSSecurityChecker.release.swift --lang en

# French
./macOSSecurityChecker.release.swift --lang fr

# French + JSON
./macOSSecurityChecker.release.swift --lang fr --json
```

## 🔒 88 Security Controls

### 🖥️ System Information (5)
| Control | Source | Description |
|---------|--------|-------------|
| Mac Model | `sysctl` | System model identifier |
| macOS Version | `sw_vers` | Operating system version |
| Build Number | `sw_vers` | Full build identifier |
| Processor | `sysctl` | Type and core count |
| System Memory | `vm_stat` | Total available RAM |

### 🔥 Firewall and Network Security (9)
| Control | Status | Description |
|---------|--------|-------------|
| Firewall Enabled | Dynamic | macOS firewall state |
| Firewall Stealth Mode | Dynamic | Network stealth mode |
| SSH Remote | Dynamic | Remote SSH access |
| Screen Sharing | Dynamic | Apple screen sharing |
| SMB File Sharing | Dynamic | Windows network share |
| Bluetooth | Dynamic | Bluetooth state |
| Bluetooth Discoverable | Dynamic | Visibility to devices |
| Wake on Network | Dynamic | Wake-on-Network |
| Bonjour/mDNS | Dynamic | Local network discovery |

### 📱 Remote Access (8)
SSH controls, Apple Remote Desktop, Remote Events, AirDrop, Universal Clipboard

### 👤 User Account Security (6)
Auto-login, Guest account, Fast user switching, Password policy, Failed login limit

### 🔍 Privacy and Tracking (9)
Location services, Safari, Siri, Spotlight, Microphone/Camera indicators

### ☁️ iCloud and Authentication (8)
Two-factor authentication, iCloud Keychain, Find My Mac, Continuity, Secure Token, Touch ID

### 🛡️ Encryption and Boot (9)
FileVault, Secure Boot, SIP, Signed System Volume, Firmware password, USB Restricted Mode

### 🔄 System Updates (5)
Auto updates, Patch status, XProtect, MRT, Critical updates

### ⚙️ Advanced Features (6)
Kernel memory protection, Boot args filtering, Gatekeeper, XProtect/MRT versions, IPv6

## 📊 Output Format

### Default Output (Formatted Text)
```
╔═══════════════════════════════════════════════════════════════════╗
│  🔒 macOS SECURITY AUDIT REPORT v2.0.0 🔒                        │
│  MacBook Pro 16-inch M3 Max                                       │
│  macOS 15.1 (Sequoia)                                             │
│  Status: 75/88 checks passed (85.2%)                              │
│  Score: 8.5/10 - EXCELLENT                                        │
└═══════════════════════════════════════════════════════════════════┘

[███████████████████████████████████████░░░░░░░░░░] 85.2%

🔥 FIREWALL & NETWORK SECURITY (9/9 PASSED)
  ✓ Firewall Enabled                   ENABLED
  ✓ Firewall Stealth Mode              ENABLED
  ✗ SSH Enabled                        ENABLED (⚠️ review if needed)
  ...
```

### JSON Output
```json
{
  "metadata": {
    "timestamp": "2024-05-04T15:30:00Z",
    "version": "2.0.0",
    "score": 8.5,
    "riskLevel": "EXCELLENT",
    "passedChecks": 75,
    "totalChecks": 88
  },
  "system": {
    "macModel": "MacBook Pro 16-inch (M3 Max, 2024)",
    "osVersion": "15.1 (Sequoia)",
    "buildNumber": "24B80",
    "processor": "Apple M3 Max (12-core)",
    "memory": "36.0 GB"
  },
  ...
}
```

### CSV Output
```csv
Category,Control,Status,Details
System,Mac Model,ENABLED,MacBook Pro 16-inch
Firewall,Firewall Enabled,ENABLED,
Privacy,Safari Privacy,ENABLED,
...
```

## 💡 Usage Examples

### Regular Auditing
```bash
# Daily audit
0 2 * * * /path/to/macOSSecurityChecker.release.swift > /var/log/audit_$(date +\%Y\%m\%d).txt

# Weekly audit in JSON
0 8 * * 1 /path/to/macOSSecurityChecker.release.swift --lang en --json > /var/log/audit_$(date +\%Y\%m\%d).json
```

### Script Integration
```bash
# Check FileVault only
RESULT=$(./macOSSecurityChecker.release.swift --json)
FILEVAULT=$(echo "$RESULT" | jq '.security.fileVault')
echo "FileVault: $FILEVAULT"

# Extract security score
./macOSSecurityChecker.release.swift --json | jq '.metadata.score'

# Get recommendations
./macOSSecurityChecker.release.swift --json | jq '.recommendations'
```

### Compliance and Reporting
```bash
# Detailed report in English
./macOSSecurityChecker.release.swift --verbose --lang en > report_$(date +%Y%m%d).txt

# JSON report for later analysis
./macOSSecurityChecker.release.swift --json --lang en | jq '.' > audit_$(date +%Y%m%d).json
```

## 🛠️ Troubleshooting

### Script Won't Execute
```bash
# Check permissions
chmod +x macOSSecurityChecker.release.swift

# Run directly with Swift
swift macOSSecurityChecker.release.swift

# With admin privileges if needed
sudo ./macOSSecurityChecker.release.swift
```

### Some Controls Show "Unknown"
```bash
# Some controls require admin privileges
sudo ./macOSSecurityChecker.release.swift

# Or with desired options
sudo ./macOSSecurityChecker.release.swift --lang en --json
```

### No Colors in Terminal
```bash
# Force color support
TERM=xterm-256color ./macOSSecurityChecker.release.swift

# Or use JSON/CSV format
./macOSSecurityChecker.release.swift --json
```

## ❓ FAQ

**Q: Does this tool modify my system?**  
A: No, it's read-only only. It analyzes, never modifies.

**Q: Does this require internet?**  
A: No, it's completely local. All checks are on your Mac.

**Q: Do all controls require sudo?**  
A: No, most work without. Some advanced controls require sudo.

**Q: Is it compatible with Tahoe (macOS 16)?**  
A: Yes, fully compatible.

**Q: Can I use it in production?**  
A: Yes, completely safe. No modifications, local audit only.

## 📞 Support

- 📖 **Documentation**: See README.md
- 🐛 **Issues**: Report on GitHub
- ❓ **Questions**: Check existing documentation
- 🔐 **Security**: Report security issues to maintainers

---

**Last Updated:** May 2024  
**Status:** Production Ready ✓  
**Repository:** https://github.com/hdrapin/macOSSecurityChecker
