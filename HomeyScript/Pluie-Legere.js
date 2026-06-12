// 🌦️ Pluie légère (< 2 mm/h)
// Déclenche: Pluie 1h > 0.1 mm et < 2 mm/h

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
