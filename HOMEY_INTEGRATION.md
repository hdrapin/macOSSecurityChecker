# 🏠 Intégration Homey Pro - macOS Security Checker

**Version:** 2.0.0  
**Date:** 9 juin 2026  
**Status:** ✅ **ACTIF ET OPÉRATIONNEL**

---

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Flows créés](#flows-créés)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Déclenchement automatique](#déclenchement-automatique)
- [Personnalisation](#personnalisation)
- [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Cette intégration automatise les alertes de sécurité macOS en créant des **5 flows Homey Pro** qui se déclenchent basés sur le score de sécurité.

### Bénéfices

✅ **Alertes en temps réel** - Notification immédiate lors d'une détection de risque  
✅ **Actions visuelles** - Activation de lumières pour signaler les alertes  
✅ **Automatisation complète** - Intégration transparent avec votre maison intelligente  
✅ **Sans configuration manuelle** - Flows créés via API (une seule fois)  

---

## 🔗 Flows créés

### 1️⃣ 🟢 **EXCELLENTE** (Score 9-10)

| Élément | Détail |
|---------|--------|
| **ID** | `ce6c9cc2-d93d-4e2f-be67-48729272fa0e` |
| **Trigger** | Démarrer un Flow (programmatic) |
| **Actions** | • Notification push positive<br>• Allume lumière Salon |
| **Message** | ✅ SÉCURITÉ MACOS EXCELLENTE! 🎉 |

### 2️⃣ 🟡 **BONNE** (Score 7-9)

| Élément | Détail |
|---------|--------|
| **ID** | `c03e3b80-ce09-4e1c-a332-652230c8e135` |
| **Trigger** | Démarrer un Flow |
| **Actions** | • Notification push standard |
| **Message** | ✅ Sécurité macOS BONNE - Bon niveau |

### 3️⃣ 🟠 **ATTENTION** (Score 5-7)

| Élément | Détail |
|---------|--------|
| **ID** | `81c2617f-640b-4b67-bb9b-44d2fd4803c3` |
| **Trigger** | Démarrer un Flow |
| **Actions** | • Notification push alerte<br>• Allume lumière Petit Salon |
| **Message** | ⚠️ ALERTE SÉCURITÉ MACOS - Protection insuffisante |

### 4️⃣ 🔴 **CRITIQUE** (Score < 5)

| Élément | Détail |
|---------|--------|
| **ID** | `832a8e34-a856-412f-826b-c15da3f5fcee` |
| **Trigger** | Démarrer un Flow |
| **Actions** | • Push notification critique<br>• Allume lumière Entrée<br>• Crée notification système |
| **Message** | 🚨 ALERTE CRITIQUE - Action immédiate requise! |

### 5️⃣ 🔄 **QUOTIDIENNE** (Vérification quotidienne)

| Élément | Détail |
|---------|--------|
| **ID** | `928b250e-ddc3-4ca7-8efb-771133a36122` |
| **Trigger** | Démarrer un Flow |
| **Actions** | • Notification rapport quotidien |
| **Message** | 📊 Scan sécurité macOS effectué |

---

## 📥 Installation

### Prérequis

✅ macOS 11.0+ (Big Sur ou plus récent)  
✅ Homey Pro actif et configuré  
✅ App Homey sur votre téléphone  
✅ Authentification Homey MCP configurée  

### Étapes

**Les flows ont déjà été créés !** ✅

Ils sont actuellement actifs dans votre Homey Pro. Pour vérifier :

1. Ouvrez **l'app Homey Pro**
2. Allez à **Automations**
3. Recherchez les 5 flows (filtrer par "Sécurité" ou "macOS")

---

## 🚀 Utilisation

### Méthode 1: Manuel depuis Homey

1. Ouvrez **Automations** dans Homey Pro
2. Sélectionnez un flow (ex: "🟢 Sécurité EXCELLENTE")
3. Cliquez sur le bouton **▶️ (Play)** pour déclencher

### Méthode 2: Via le macOS Security Checker

```bash
# Voir quel flow doit être déclenché
./macOSSecurityChecker-Homey.swift --homey

# Sortie exemple:
# 🟢 EXCELLENT
# 📊 Score: 8.5/10
# 🔗 Flow ID: ce6c9cc2-d93d-4e2f-be67-48729272fa0e
```

### Méthode 3: Intégration avec le script principal

Modifiez le script principal pour déclencher Homey après chaque scan :

```bash
# Exécuter le security checker et déclencher le flow
./macOSSecurityChecker.release.swift && ./macOSSecurityChecker-Homey.swift --homey
```

---

## 🔄 Déclenchement automatique

### Option 1: Cron Job (Quotidien à 9h)

```bash
# Éditer le crontab
crontab -e

# Ajouter cette ligne:
0 9 * * * /path/to/macOSSecurityChecker-Homey.swift --homey 2>&1 | logger -t security-checker
```

### Option 2: LaunchAgent (Arrière-plan)

1. Créer `/Library/LaunchAgents/com.macos.securitychecker.homey.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.macos.securitychecker.homey</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/macOSSecurityChecker-Homey.swift</string>
        <string>--homey</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer>
    <key>StandardErrorPath</key>
    <string>/var/log/security-checker.log</string>
    <key>StandardOutPath</key>
    <string>/var/log/security-checker.log</string>
</dict>
</plist>
```

2. Charger l'agent:
```bash
launchctl load /Library/LaunchAgents/com.macos.securitychecker.homey.plist
```

### Option 3: Apple Automation (Raccourcis)

1. Ouvrir **Automations** (macOS)
2. Créer une automatisation **horaire**
3. Sélectionner **9:00 du matin**
4. Ajouter action: **Exécuter un script shell**
5. Coller:
```bash
/path/to/macOSSecurityChecker-Homey.swift --homey
```

---

## 🎨 Personnalisation

### Ajouter des actions aux flows

Vous pouvez enrichir les flows directement dans Homey:

**Pour le flow CRITIQUE (🔴):**
```
Actions existantes:
✅ Notification push
✅ Allume Entrée
✅ Notification système

Ajouter:
+ Fermer les stores du jardin
+ Allumer toutes les lumières (mode alerte)
+ Annoncer sur Sonos: "Attention, problème de sécurité détecté"
```

**Pour le flow EXCELLENT (🟢):**
```
Actions existantes:
✅ Notification
✅ Allume Salon

Ajouter:
+ Jouer musique positive sur Sonos
+ Allumer pergola si > 18h
```

### Personnaliser les messages

1. Ouvrez un flow dans Homey
2. Cliquez sur la **Notification**
3. Modifiez le **texte** du message

---

## 🔧 Dépannage

### ❓ Les flows ne se déclenchent pas

**Vérifier:**
- [ ] Les 5 flows apparaissent dans **Automations**
- [ ] Tous les flows sont **activés** (toggle vert)
- [ ] Essayer de déclencher manuellement (button ▶️)

**Solution:** Recharger Homey Pro:
```bash
# Via l'app: Paramètres → Redémarrer Homey
# Ou via SSH: reboot
```

### ❓ Notifications ne s'affichent pas

**Vérifier:**
- [ ] App Homey **connectée** à Homey Pro
- [ ] Notifications **autorisées** dans paramètres téléphone
- [ ] Version Homey à jour

**Solution:** Tester notification directement dans Homey

### ❓ Script Swift ne fonctionne pas

**Vérifier:**
```bash
# Rendre exécutable
chmod +x macOSSecurityChecker-Homey.swift

# Tester
./macOSSecurityChecker-Homey.swift --help
./macOSSecurityChecker-Homey.swift --homey
```

### ❓ Flow ID incorrect

Vérifier dans Homey Pro:
1. Ouvrir **Automations**
2. Cliquer sur un flow
3. Cliquer sur **⋯ (Menu)** → **ID du flow**
4. Comparer avec les IDs dans ce document

---

## 📊 Monitoring & Logs

### Voir les activations de flows

Dans **Homey Pro**:
1. Aller à **Automatisation**
2. Sélectionner un flow
3. Voir l'historique en bas

### Logs du script

```bash
# Afficher les logs
tail -f /var/log/security-checker.log

# Ou via syslog
log stream --predicate 'eventMessage contains "security-checker"'
```

---

## 🔐 Sécurité

✅ **Authentification MCP Homey** - Token géré par le système  
✅ **Communication HTTPS** - Chiffrement SSL/TLS  
✅ **Données locales uniquement** - Aucune données externes  
✅ **Pas de stockage cloud** - Données gardées sur Homey Pro  

---

## 📝 Roadmap

- [ ] Intégration avec caméras (enregistrement au déclenchement CRITIQUE)
- [ ] Rapport JSON envoyé à Homey
- [ ] Historique 30 jours dans Homey
- [ ] Intégration avec HomeKit
- [ ] Support IFTTT

---

## 📞 Support

### Ressources

- **Homey Developers**: https://developers.homey.app
- **macOS Security**: https://support.apple.com/security
- **Ce projet**: https://github.com/hdrapin/macOSSecurityChecker

### Signaler un problème

1. Vérifier [Dépannage](#dépannage)
2. Collecter les logs:
   ```bash
   ./macOSSecurityChecker-Homey.swift --homey 2>&1 > debug.log
   cat debug.log
   ```
3. Créer une issue sur GitHub

---

## 📄 Licence

**Apache License 2.0**  
Libre pour usage personnel et commercial

---

**Dernière mise à jour:** 9 juin 2026  
**Maintenu par:** hdrapin  
**Status:** Production ✅
