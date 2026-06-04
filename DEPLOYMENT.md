# Guide de Déploiement - Apple News Scraper

## 📋 Prérequis

- macOS 10.14+ (Sierra ou plus récent)
- Python 3.9+
- Git (pour cloner le repository)
- Répertoire de sortie créé: `/Users/nburma/Documents/Hauteville-House/`

## 🚀 Déploiement en Production

### Étape 1: Cloner ou télécharger le projet

```bash
# Option 1: Via Git (recommandé)
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker
git checkout claude/apple-tech-news-scraper-HblN6

# Option 2: Via téléchargement ZIP
# Extraire dans: /Users/nburma/Documents/Projects/appleNewsScrapper/
```

### Étape 2: Exécuter le script d'installation

```bash
cd /Users/nburma/Documents/Projects/appleNewsScrapper/
chmod +x setup_macos.sh
./setup_macos.sh
```

Le script va:
- ✅ Créer un environnement virtuel Python
- ✅ Installer les dépendances
- ✅ Créer les répertoires de sortie
- ✅ Configurer le LaunchAgent macOS
- ✅ Tester l'installation
- ✅ Activer l'exécution quotidienne

### Étape 3: Vérifier l'installation

```bash
# Voir le statut du LaunchAgent
launchctl list | grep apple-news

# Voir les logs
tail -f /Users/nburma/Documents/Projects/appleNewsScrapper/LaunchAgent.log
```

## ⚙️ Configuration

### Fichier Pref.md

Le fichier `Pref.md` contient la configuration de production:

```markdown
RESSOURCES_PATH: /Users/nburma/Documents/Hauteville-House/RESSOURCES.md
NEWS_DIR: /Users/nburma/Documents/Hauteville-House/NEWS/
LOGS_DIR: /Users/nburma/Documents/Hauteville-House/NEWS/LOGS/
CACHE_DIR: /Users/nburma/Documents/Projects/appleNewsScrapper/Cache/
```

**Ne pas modifier les chemins** - ils doivent correspondre à votre structure exacte.

### Fichier RESSOURCES.md

Assurez-vous que `/Users/nburma/Documents/Hauteville-House/RESSOURCES.md` contient:

```markdown
## Tableau de traçabilité des sources consultées

|**Titre**|**URL**|**Date**|
|---|---|---|
|Source Name|`[https://example.com/feed/](https://example.com/feed/)`|2026-06-04|
```

## 🎯 Exécution

### Automatique (LaunchAgent)

Le script s'exécute automatiquement **chaque jour à 14h00 UTC**.

Les fichiers générés:
- `NEWS/04-06-2026.md` - Articles du jour
- `NEWS/LOGS/04-06-2026.md` - Logs détaillés

### Manuel

```bash
# Exécution directe
/Users/nburma/Documents/Projects/appleNewsScrapper/run_scraper.sh

# Ou depuis le projet
cd /Users/nburma/Documents/Projects/appleNewsScrapper/
python apple_news_scraper/main.py
```

### Forcer une exécution immédiate

```bash
# Forcer le LaunchAgent à s'exécuter maintenant
launchctl start com.hdrapin.apple-news
```

## 📊 Vérifier les résultats

```bash
# Voir les articles du jour
cat /Users/nburma/Documents/Hauteville-House/NEWS/$(date +%d-%m-%Y).md

# Voir les logs détaillés
cat /Users/nburma/Documents/Hauteville-House/NEWS/LOGS/$(date +%d-%m-%Y).md

# Voir les logs d'exécution du LaunchAgent
tail -100 /Users/nburma/Documents/Projects/appleNewsScrapper/LaunchAgent.log
```

## 🔧 Maintenance

### Voir le statut

```bash
launchctl list | grep apple-news
```

Output:
```
- 0 com.hdrapin.apple-news
```

- `0` = exécution réussie
- nombre positif = PID en cours d'exécution
- `-1` = erreur

### Logs système macOS

```bash
# Voir les logs système pour le LaunchAgent
log stream --predicate 'process == "launchd"' --level debug | grep apple-news

# Ou dans Console.app: Spotlight → Console
```

### Désactiver temporairement

```bash
launchctl unload ~/Library/LaunchAgents/com.hdrapin.apple-news.plist
```

### Réactiver

```bash
launchctl load ~/Library/LaunchAgents/com.hdrapin.apple-news.plist
```

### Désinstaller complètement

```bash
# Désactiver
launchctl unload ~/Library/LaunchAgents/com.hdrapin.apple-news.plist

# Supprimer le fichier
rm ~/Library/LaunchAgents/com.hdrapin.apple-news.plist

# Supprimer le projet (optionnel)
rm -rf /Users/nburma/Documents/Projects/appleNewsScrapper/
```

## 🐛 Troubleshooting

### LaunchAgent ne s'exécute pas

```bash
# Vérifier les erreurs
log stream --predicate 'eventMessage contains "apple-news"' --level debug

# Vérifier les chemins dans Pref.md
cat /Users/nburma/Documents/Projects/appleNewsScrapper/Pref.md

# Tester manuellement
/Users/nburma/Documents/Projects/appleNewsScrapper/run_scraper.sh
```

### Erreur: "ModuleNotFoundError: feedparser"

```bash
# Réinstaller les dépendances
cd /Users/nburma/Documents/Projects/appleNewsScrapper/
source venv/bin/activate
pip install -r requirements.txt
```

### Aucun article trouvé

```bash
# Vérifier les sources
cat /Users/nburma/Documents/Hauteville-House/RESSOURCES.md

# Tester le chargement des sources
cd /Users/nburma/Documents/Projects/appleNewsScrapper/
python3 << 'EOF'
import sys
sys.path.insert(0, '.')
from apple_news_scraper.sources import SourcesLoader
from pathlib import Path
loader = SourcesLoader(Path("RESSOURCES.md"))
sources = loader.load()
for s in sources:
    print(f"{s.name}: {s.url}")
EOF
```

### Permission denied sur run_scraper.sh

```bash
chmod +x /Users/nburma/Documents/Projects/appleNewsScrapper/run_scraper.sh
```

## 📈 Performance

- **Première exécution**: ~60 secondes (téléchargement complet)
- **Exécutions suivantes**: ~15-20 secondes (cache + ETags)
- **Cache**: 6 heures TTL

## ✅ Checklist de déploiement

- [ ] Répertoire `/Users/nburma/Documents/Hauteville-House/` existe
- [ ] Fichier `RESSOURCES.md` est à jour
- [ ] Script `setup_macos.sh` est exécutable
- [ ] Installation complétée sans erreurs
- [ ] Test manuel réussi: `run_scraper.sh`
- [ ] LaunchAgent chargé: `launchctl list | grep apple-news`
- [ ] Fichiers générés dans `NEWS/`
- [ ] Logs disponibles dans `NEWS/LOGS/`

## 📞 Support

En cas de problème:

1. Vérifier les logs: `tail -f /Users/nburma/Documents/Projects/appleNewsScrapper/LaunchAgent.log`
2. Vérifier les chemins dans `Pref.md`
3. Tester manuellement: `./run_scraper.sh`
4. Vérifier les permissions des répertoires
