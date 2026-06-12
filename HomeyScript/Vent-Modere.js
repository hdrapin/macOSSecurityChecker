// 💨 Vent modéré (30–50 km/h)
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
