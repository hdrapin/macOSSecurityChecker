#!/bin/bash

# Apple News Scraper - Setup macOS Production

set -e

echo "🚀 Apple News Scraper - Installation macOS"
echo "=============================================="

# Déterminer le répertoire du projet
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="$PROJECT_DIR/venv"

echo "📁 Répertoire projet: $PROJECT_DIR"

# 1. Créer l'environnement virtuel Python
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Création de l'environnement virtuel Python..."
    python3 -m venv "$VENV_DIR"
    chmod -R u+rwx "$VENV_DIR"
else
    echo "✅ Environnement virtuel existe déjà"
fi

# 2. Activer et installer les dépendances
echo "📥 Installation des dépendances..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel > /dev/null 2>&1
pip install -r "$PROJECT_DIR/requirements.txt"

# 3. Créer les répertoires de sortie
echo "📂 Création des répertoires..."
mkdir -p "/Users/nburma/Documents/Hauteville-House/NEWS"
mkdir -p "/Users/nburma/Documents/Hauteville-House/NEWS/LOGS"
mkdir -p "$PROJECT_DIR/Cache"

# 4. Vérifier que le fichier de configuration production existe
if [ ! -f "$PROJECT_DIR/Pref.md" ]; then
    echo "⚠️  Copie de Pref.prod.md vers Pref.md..."
    cp "$PROJECT_DIR/Pref.prod.md" "$PROJECT_DIR/Pref.md"
fi

# 5. Créer le script wrapper
echo "🔧 Création du script wrapper..."
cat > "$PROJECT_DIR/run_scraper.sh" << 'WRAPPER_EOF'
#!/bin/bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$PROJECT_DIR"
source venv/bin/activate
python apple_news_scraper/main.py
WRAPPER_EOF
chmod +x "$PROJECT_DIR/run_scraper.sh"

# 6. Créer le LaunchAgent
echo "⚙️  Configuration du LaunchAgent..."
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCHAGENT_FILE="$LAUNCHAGENT_DIR/com.hdrapin.apple-news.plist"

mkdir -p "$LAUNCHAGENT_DIR"

cat > "$LAUNCHAGENT_FILE" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.hdrapin.apple-news</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$PROJECT_DIR/run_scraper.sh</string>
    </array>

    <key>WorkingDirectory</key>
    <string>$PROJECT_DIR</string>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>14</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>$PROJECT_DIR/LaunchAgent.log</string>

    <key>StandardErrorPath</key>
    <string>$PROJECT_DIR/LaunchAgent.log</string>

    <key>RunAtLoad</key>
    <false/>

    <key>StartInterval</key>
    <integer>86400</integer>
</dict>
</plist>
PLIST_EOF

chmod 644 "$LAUNCHAGENT_FILE"

echo "✅ LaunchAgent installé: $LAUNCHAGENT_FILE"

# 7. Charger le LaunchAgent
echo "🎯 Chargement du LaunchAgent..."
launchctl load "$LAUNCHAGENT_FILE"

# 8. Test rapide
echo ""
echo "🧪 Test du scraper..."
source "$VENV_DIR/bin/activate"
cd "$PROJECT_DIR"
python apple_news_scraper/main.py

echo ""
echo "✅ Installation complète!"
echo ""
echo "📋 Résumé:"
echo "  • Projet: $PROJECT_DIR"
echo "  • venv: $VENV_DIR"
echo "  • LaunchAgent: $LAUNCHAGENT_FILE"
echo "  • News output: /Users/nburma/Documents/Hauteville-House/NEWS/"
echo "  • Logs: $PROJECT_DIR/LaunchAgent.log"
echo ""
echo "🚀 Le script s'exécutera automatiquement chaque jour à 14h00"
echo ""
echo "Commandes utiles:"
echo "  • Test manuel: $PROJECT_DIR/run_scraper.sh"
echo "  • Voir les logs: tail -f $PROJECT_DIR/LaunchAgent.log"
echo "  • Désactiver: launchctl unload $LAUNCHAGENT_FILE"
echo "  • Activer: launchctl load $LAUNCHAGENT_FILE"
echo "  • Statut: launchctl list | grep apple-news"
