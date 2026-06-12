// ===============================================
// HOMEY SCRIPTS - MÉTÉO
// Copier-coller chaque script dans la section HomeyScript de Homey
// ===============================================

// ==============================================================
// SCRIPT 1: 🌧️ Alerte Pluie — Pluviomètre actif
// ==============================================================
// Déclenche: Pluie instantanée > 0.1 mm
// Actions: Notification mobile + Notification Homey

return {
  name: '🌧️ Alerte Pluie — Pluviomètre actif',
  async run() {
    try {
      // Récupérer le pluviomètre
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) {
        console.error('Pluviomètre non trouvé');
        return false;
      }

      const pluieActuelle = pluviometre.capabilitiesObj['measure_rain']?.value || 0;

      if (pluieActuelle > 0.1) {
        // Envoyer notification mobile
        await Homey.users.getUserByEmail(Homey.user.email)
          .then(user => Homey.notifications.createNotification({
            excerpt: `🌧️ Pluie détectée au jardin ! Intensité : ${pluieActuelle.toFixed(1)} mm`
          }));

        // Logs
        console.log(`[Pluie] Alerte déclenchée : ${pluieActuelle} mm`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Pluie Alerte:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 2: 🌦️ Pluie légère (< 2 mm/h)
// ==============================================================
// Déclenche: Pluie 1h > 0.1 mm et < 2 mm/h
// Actions: Notification mobile + Notification Homey

return {
  name: '🌦️ Pluie légère (< 2 mm/h)',
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) return false;

      const pluie1h = pluviometre.capabilitiesObj['measure_rain.1h']?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj['measure_rain.24h']?.value || 0;

      if (pluie1h >= 0.1 && pluie1h < 2) {
        await Homey.notifications.createNotification({
          excerpt: `🌦️ Pluie légère — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });

        console.log(`[Pluie] Légère : ${pluie1h} mm/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Pluie Légère:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 3: 🌧️ Pluie modérée (2–5 mm/h)
// ==============================================================
// Déclenche: Pluie 1h >= 2 mm/h et < 5 mm/h

return {
  name: '🌧️ Pluie modérée (2–5 mm/h)',
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) return false;

      const pluie1h = pluviometre.capabilitiesObj['measure_rain.1h']?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj['measure_rain.24h']?.value || 0;

      if (pluie1h >= 2 && pluie1h < 5) {
        await Homey.notifications.createNotification({
          excerpt: `🌧️ Pluie modérée — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });

        console.log(`[Pluie] Modérée : ${pluie1h} mm/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Pluie Modérée:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 4: ⛈️ Pluie forte (5–10 mm/h)
// ==============================================================
// Déclenche: Pluie 1h >= 5 mm/h et < 10 mm/h

return {
  name: '⛈️ Pluie forte (5–10 mm/h)',
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) return false;

      const pluie1h = pluviometre.capabilitiesObj['measure_rain.1h']?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj['measure_rain.24h']?.value || 0;

      if (pluie1h >= 5 && pluie1h < 10) {
        await Homey.notifications.createNotification({
          excerpt: `⛈️ Pluie forte — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });

        console.log(`[Pluie] Forte : ${pluie1h} mm/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Pluie Forte:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 5: 🚨 Pluie très forte / Orage (> 10 mm/h)
// ==============================================================
// Déclenche: Pluie 1h >= 10 mm/h

return {
  name: '🚨 Pluie très forte / Orage (> 10 mm/h)',
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) return false;

      const pluie1h = pluviometre.capabilitiesObj['measure_rain.1h']?.value || 0;
      const pluie24h = pluviometre.capabilitiesObj['measure_rain.24h']?.value || 0;

      if (pluie1h >= 10) {
        await Homey.notifications.createNotification({
          excerpt: `🚨 DÉLUGE — ${pluie1h.toFixed(1)} mm/h | Cumul 24h : ${pluie24h.toFixed(1)} mm`
        });

        console.log(`[Pluie] DÉLUGE : ${pluie1h} mm/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Déluge:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 6: ☀️ Fin de pluie — sortie possible
// ==============================================================
// Déclenche: Pluie 24h < 1 mm pendant 5 minutes

return {
  name: '☀️ Fin de pluie — sortie possible',
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) return false;

      const pluie24h = pluviometre.capabilitiesObj['measure_rain.24h']?.value || 0;

      if (pluie24h < 1) {
        await Homey.notifications.createNotification({
          excerpt: `☀️ Fin de pluie ! Cumul 24h : ${pluie24h.toFixed(1)} mm. Vous pouvez sortir sans finir comme une éponge.`
        });

        console.log(`[Pluie] Fin détectée`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Fin Pluie:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 7: 💨 Vent modéré (30–50 km/h)
// ==============================================================
// Déclenche: Rafales >= 30 km/h et < 50 km/h

return {
  name: '💨 Vent modéré (30–50 km/h)',
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: '0417d1d3-ac30-4d27-bd6d-3d576e39641d'
      });

      if (!anemometre) return false;

      const gust = Math.round(anemometre.capabilitiesObj['measure_gust_strength']?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj['measure_wind_strength']?.value || 0);

      if (gust >= 30 && gust < 50) {
        await Homey.notifications.createNotification({
          excerpt: `💨 Vent modéré — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });

        console.log(`[Vent] Modéré : ${gust} km/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Vent Modéré:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 8: 🌬️ Vent fort (50–70 km/h)
// ==============================================================
// Déclenche: Rafales >= 50 km/h et < 70 km/h

return {
  name: '🌬️ Vent fort (50–70 km/h)',
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: '0417d1d3-ac30-4d27-bd6d-3d576e39641d'
      });

      if (!anemometre) return false;

      const gust = Math.round(anemometre.capabilitiesObj['measure_gust_strength']?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj['measure_wind_strength']?.value || 0);

      if (gust >= 50 && gust < 70) {
        await Homey.notifications.createNotification({
          excerpt: `🌬️ Vent fort — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });

        console.log(`[Vent] Fort : ${gust} km/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Vent Fort:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 9: 🚨 Vent violent (70–90 km/h)
// ==============================================================
// Déclenche: Rafales >= 70 km/h et < 90 km/h

return {
  name: '🚨 Vent violent (70–90 km/h)',
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: '0417d1d3-ac30-4d27-bd6d-3d576e39641d'
      });

      if (!anemometre) return false;

      const gust = Math.round(anemometre.capabilitiesObj['measure_gust_strength']?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj['measure_wind_strength']?.value || 0);

      if (gust >= 70 && gust < 90) {
        await Homey.notifications.createNotification({
          excerpt: `🚨 Vent violent — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });

        console.log(`[Vent] Violent : ${gust} km/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Vent Violent:', err);
      return false;
    }
  }
};

// ==============================================================
// SCRIPT 10: 🌪️ Tempête (> 90 km/h)
// ==============================================================
// Déclenche: Rafales >= 90 km/h

return {
  name: '🌪️ Tempête (> 90 km/h)',
  async run() {
    try {
      const anemometre = await Homey.devices.getDevice({
        id: '0417d1d3-ac30-4d27-bd6d-3d576e39641d'
      });

      if (!anemometre) return false;

      const gust = Math.round(anemometre.capabilitiesObj['measure_gust_strength']?.value || 0);
      const wind = Math.round(anemometre.capabilitiesObj['measure_wind_strength']?.value || 0);

      if (gust >= 90) {
        await Homey.notifications.createNotification({
          excerpt: `🌪️ TEMPÊTE — Rafales : ${gust} km/h | Vent moyen : ${wind} km/h`
        });

        console.log(`[Vent] TEMPÊTE : ${gust} km/h`);
        return true;
      }

      return false;
    } catch (err) {
      console.error('Erreur script Tempête:', err);
      return false;
    }
  }
};

// ===============================================
// INSTRUCTIONS D'UTILISATION
// ===============================================
/*
1. Ouvrir Homey Pro → Automations → HomeyScript
2. Créer un nouveau script pour chaque flow météo
3. Copier-coller le code correspondant (commençant par "return {" jusqu'à "};")
4. Donner au script le nom exact (ex: "🌧️ Alerte Pluie — Pluviomètre actif")
5. Sauvegarder
6. Chaque script s'exécutera indépendamment et enverra une notification Homey

NOTES:
- Les scripts lisent les données directement du capteur Netatmo (pluviomètre + anémomètre)
- Chaque script gère sa propre logique de seuil
- Les notifications sont créées dans la timeline Homey
*/
