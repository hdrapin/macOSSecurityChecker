// 🚨 Pluie très forte / Orage (> 10 mm/h)
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
