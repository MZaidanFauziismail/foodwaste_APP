function toNumber(value) {
  if (value === null || value === undefined || value === '') return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function distanceKm(lat1, lon1, lat2, lon2) {
  const aLat = toNumber(lat1);
  const aLon = toNumber(lon1);
  const bLat = toNumber(lat2);
  const bLon = toNumber(lon2);
  if ([aLat, aLon, bLat, bLon].some((v) => v === null)) return null;
  const earth = 6371;
  const dLat = deg2rad(bLat - aLat);
  const dLon = deg2rad(bLon - aLon);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(deg2rad(aLat)) * Math.cos(deg2rad(bLat)) * Math.sin(dLon / 2) ** 2;
  return earth * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

function deg2rad(deg) {
  return deg * Math.PI / 180;
}

module.exports = { toNumber, distanceKm };
