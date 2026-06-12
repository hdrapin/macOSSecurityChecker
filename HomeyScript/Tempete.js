// 🌪️ Tempête (> 90 km/h)
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
