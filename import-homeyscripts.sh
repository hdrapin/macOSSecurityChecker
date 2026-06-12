#!/bin/bash

# ===============================================
# Homey HomeyScripts Auto-Import Tool
# Importe automatiquement les 10 scripts météo
# ===============================================

# Configuration
HOMEY_IP="${1:-192.168.0.220}"
HOMEY_TOKEN="${2:-9fcc1931-d40d-47f3-bb16-73f2b5af2a51:a1450379-8d7d-4dea-bc98-155457f6ba8d:727b0b4e7e6a0f8603ba5c0c662143204029bd96}"
HOMEY_URL="http://$HOMEY_IP"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🏠 Homey HomeyScripts Auto-Import Tool  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Homey IP: $HOMEY_IP"
echo "  Token: ${HOMEY_TOKEN:0:20}..."
echo ""

# Fonction pour créer un script
create_script() {
    local name="$1"
    local code="$2"

    echo -n "📝 Création: $name ... "

    # Créer le payload JSON
    local payload=$(cat <<EOF
{
  "name": "$name",
  "code": $(echo "$code" | jq -Rs .)
}
EOF
)

    # Envoyer la requête
    local response=$(curl -s -X POST "$HOMEY_URL/api/manager/homerules/scripts" \
        -H "Authorization: Bearer $HOMEY_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>&1)

    # Vérifier la réponse
    if echo "$response" | grep -q '"id"'; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ ERREUR${NC}"
        echo "  Réponse: $response"
        return 1
    fi
}

# Compter les succès
success=0
total=10

echo -e "${YELLOW}Importation des scripts...${NC}\n"

# SCRIPT 1
create_script "🌧️ Alerte Pluie — Pluviomètre actif" 'return {
  name: "🌧️ Alerte Pluie — Pluviomètre actif",
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: "d231a357-6f3a-49f0-b524-d9957f6a0301"
      });
      if (!pluviometre) {
        console.error("Pluviomètre non trouvé");
        return false;
      }
      const pluieActuelle = pluviometre.capabilitiesObj["measure_rain"]?.value || 0;
      if (pluieActuelle > 0.1) {
        await Homey.notifications.createNotification({
          excerpt: `🌧️ Pluie détectée au jardin ! Intensité : ${pluieActuelle.toFixed(1)} mm`
        });
        console.log(`[Pluie] Alerte déclenchée : ${pluieActuelle} mm`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Pluie Alerte:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 2
create_script "🌦️ Pluie légère (< 2 mm/h)" 'return {
  name: "🌦️ Pluie légère (< 2 mm/h)",
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: "d231a357-6f3a-49f0-b524-d9957f6a0301"
      });
      if (!pluviometre) return false;
      const pluie1h = pluviometre.capabilitiesObj["measure_rain.1h"]?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj["measure_rain.24h"]?.value || 0;
      if (pluie1h >= 0.1 && pluie1h < 2) {
        await Homey.notifications.createNotification({
          excerpt: `🌦️ Pluie légère — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });
        console.log(`[Pluie] Légère : ${pluie1h} mm/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Pluie Légère:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 3
create_script "🌧️ Pluie modérée (2–5 mm/h)" 'return {
  name: "🌧️ Pluie modérée (2–5 mm/h)",
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: "d231a357-6f3a-49f0-b524-d9957f6a0301"
      });
      if (!pluviometre) return false;
      const pluie1h = pluviometre.capabilitiesObj["measure_rain.1h"]?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj["measure_rain.24h"]?.value || 0;
      if (pluie1h >= 2 && pluie1h < 5) {
        await Homey.notifications.createNotification({
          excerpt: `🌧️ Pluie modérée — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });
        console.log(`[Pluie] Modérée : ${pluie1h} mm/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Pluie Modérée:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 4
create_script "⛈️ Pluie forte (5–10 mm/h)" 'return {
  name: "⛈️ Pluie forte (5–10 mm/h)",
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: "d231a357-6f3a-49f0-b524-d9957f6a0301"
      });
      if (!pluviometre) return false;
      const pluie1h = pluviometre.capabilitiesObj["measure_rain.1h"]?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj["measure_rain.24h"]?.value || 0;
      if (pluie1h >= 5 && pluie1h < 10) {
        await Homey.notifications.createNotification({
          excerpt: `⛈️ Pluie forte — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });
        console.log(`[Pluie] Forte : ${pluie1h} mm/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Pluie Forte:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 5
create_script "🚨 Pluie très forte / Orage (> 10 mm/h)" 'return {
  name: "🚨 Pluie très forte / Orage (> 10 mm/h)",
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: "d231a357-6f3a-49f0-b524-d9957f6a0301"
      });
      if (!pluviometre) return false;
      const pluie1h = pluviometre.capabilitiesObj["measure_rain.1h"]?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj["measure_rain.24h"]?.value || 0;
      if (pluie1h >= 10) {
        await Homey.notifications.createNotification({
          excerpt: `🚨 DÉLUGE — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });
        console.log(`[Pluie] DÉLUGE : ${pluie1h} mm/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Déluge:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 6
create_script "☀️ Fin de pluie — sortie possible" 'return {
  name: "☀️ Fin de pluie — sortie possible",
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: "d231a357-6f3a-49f0-b524-d9957f6a0301"
      });
      if (!pluviometre) return false;
      const pluie24h = pluviometre.capabilitiesObj["measure_rain.24h"]?.value || 0;
      if (pluie24h < 1) {
        await Homey.notifications.createNotification({
          excerpt: `☀️ Fin de pluie ! Cumul 24h : ${pluie24h.toFixed(1)} mm. Vous pouvez sortir sans finir comme une éponge.`
        });
        console.log(`[Pluie] Fin détectée`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Fin Pluie:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 7
create_script "💨 Vent modéré (30–50 km/h)" 'return {
  name: "💨 Vent modéré (30–50 km/h)",
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: "0417d1d3-ac30-4d27-bd6d-3d576e39641d"
      });
      if (!anemometre) return false;
      const gust = Math.round(anemometre.capabilitiesObj["measure_gust_strength"]?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj["measure_wind_strength"]?.value || 0);
      if (gust >= 30 && gust < 50) {
        await Homey.notifications.createNotification({
          excerpt: `💨 Vent modéré — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });
        console.log(`[Vent] Modéré : ${gust} km/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Vent Modéré:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 8
create_script "🌬️ Vent fort (50–70 km/h)" 'return {
  name: "🌬️ Vent fort (50–70 km/h)",
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: "0417d1d3-ac30-4d27-bd6d-3d576e39641d"
      });
      if (!anemometre) return false;
      const gust = Math.round(anemometre.capabilitiesObj["measure_gust_strength"]?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj["measure_wind_strength"]?.value || 0);
      if (gust >= 50 && gust < 70) {
        await Homey.notifications.createNotification({
          excerpt: `🌬️ Vent fort — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });
        console.log(`[Vent] Fort : ${gust} km/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Vent Fort:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 9
create_script "🚨 Vent violent (70–90 km/h)" 'return {
  name: "🚨 Vent violent (70–90 km/h)",
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: "0417d1d3-ac30-4d27-bd6d-3d576e39641d"
      });
      if (!anemometre) return false;
      const gust = Math.round(anemometre.capabilitiesObj["measure_gust_strength"]?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj["measure_wind_strength"]?.value || 0);
      if (gust >= 70 && gust < 90) {
        await Homey.notifications.createNotification({
          excerpt: `🚨 Vent violent — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });
        console.log(`[Vent] Violent : ${gust} km/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Vent Violent:", err);
      return false;
    }
  }
};' && ((success++))

# SCRIPT 10
create_script "🌪️ Tempête (> 90 km/h)" 'return {
  name: "🌪️ Tempête (> 90 km/h)",
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: "0417d1d3-ac30-4d27-bd6d-3d576e39641d"
      });
      if (!anemometre) return false;
      const gust = Math.round(anemometre.capabilitiesObj["measure_gust_strength"]?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj["measure_wind_strength"]?.value || 0);
      if (gust >= 90) {
        await Homey.notifications.createNotification({
          excerpt: `🌪️ TEMPÊTE — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });
        console.log(`[Vent] TEMPÊTE : ${gust} km/h`);
        return true;
      }
      return false;
    } catch (err) {
      console.error("Erreur script Tempête:", err);
      return false;
    }
  }
};' && ((success++))

# Résumé
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📊 RÉSUMÉ${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

if [ $success -eq $total ]; then
    echo -e "${GREEN}✅ Succès: $success/$total scripts importés${NC}"
    echo ""
    echo -e "${GREEN}Les HomeyScripts sont maintenant disponibles dans Homey !${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Résultat: $success/$total scripts importés${NC}"
    echo -e "${RED}❌ $((total - success)) scripts en erreur${NC}"
    echo ""
    echo "Vérifiez:"
    echo "  1. L'adresse IP du Homey: $HOMEY_IP"
    echo "  2. Le token d'authentification"
    echo "  3. Que Homey Pro est accessible sur le réseau"
    exit 1
fi
