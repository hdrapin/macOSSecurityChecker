// 🌧️ Alerte Pluie — Pluviomètre actif
// Déclenche: Pluie instantanée > 0.1 mm

return {
  name: '🌧️ Alerte Pluie — Pluviomètre actif',
  async run() {
    try {
      const pluviometre = await Homey.devices.getDevice({
        id: 'd231a357-6f3a-49f0-b524-d9957f6a0301'
      });

      if (!pluviometre) {
        console.error('Pluviomètre non trouvé');
        return false;
      }

      const pluieActuelle = pluviometre.capabilitiesObj['measure_rain']?.value || 0;

      if (pluieActuelle > 0.1) {
        await Homey.notifications.createNotification({
          excerpt: `🌧️ Pluie détectée au jardin ! Intensité : ${pluieActuelle.toFixed(1)} mm`
        });

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
