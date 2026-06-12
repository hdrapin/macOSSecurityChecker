// ☀️ Fin de pluie — sortie possible
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
