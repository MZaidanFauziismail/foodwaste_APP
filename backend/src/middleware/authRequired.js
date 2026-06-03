const { query } = require('../db');
const { verifyToken } = require('../utils/token');
const { verifyFirebaseIdToken, isFirebaseConfigured } = require('../services/firebaseService');

function firebaseName(decoded) {
  if (decoded.name && String(decoded.name).trim()) return String(decoded.name).trim();
  if (decoded.email) return String(decoded.email).split('@')[0];
  return 'EcoShare User';
}

async function loadLocalUser(decoded) {
  const result = await query(
    `SELECT id, name, email, avatar_url, radius_km, latitude, longitude, created_at
     FROM users
     WHERE id = $1`,
    [decoded.sub]
  );
  if (result.rowCount === 0) throw new Error('User tidak ditemukan.');
  return result.rows[0];
}

async function loadOrCreateFirebaseUser(decoded) {
  const uid = decoded.uid;
  const email = String(decoded.email || `${uid}@firebase.local`).toLowerCase();
  const name = firebaseName(decoded);
  const avatar = decoded.picture || null;

  const byUid = await query(
    `SELECT id, name, email, avatar_url, radius_km, latitude, longitude, created_at
     FROM users
     WHERE firebase_uid = $1`,
    [uid]
  );
  if (byUid.rowCount > 0) return byUid.rows[0];

  const byEmail = await query(
    `UPDATE users
     SET firebase_uid = $1,
         auth_provider = 'firebase',
         avatar_url = COALESCE(avatar_url, $2),
         updated_at = now()
     WHERE lower(email) = lower($3)
     RETURNING id, name, email, avatar_url, radius_km, latitude, longitude, created_at`,
    [uid, avatar, email]
  );
  if (byEmail.rowCount > 0) return byEmail.rows[0];

  const created = await query(
    `INSERT INTO users (name, email, password_hash, firebase_uid, auth_provider, avatar_url, latitude, longitude)
     VALUES ($1, $2, 'firebase-auth', $3, 'firebase', $4, $5, $6)
     RETURNING id, name, email, avatar_url, radius_km, latitude, longitude, created_at`,
    [name, email, uid, avatar, -6.2219, 106.6479]
  );
  return created.rows[0];
}

async function authRequired(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ message: 'Token tidak ada.' });

  try {
    const decoded = verifyToken(token);
    req.user = await loadLocalUser(decoded);
    req.authProvider = 'local';
    return next();
  } catch (localError) {
    if (!isFirebaseConfigured()) {
      return res.status(401).json({ message: localError.message || 'Autentikasi gagal.' });
    }
  }

  try {
    const decoded = await verifyFirebaseIdToken(token);
    req.user = await loadOrCreateFirebaseUser(decoded);
    req.firebaseUser = decoded;
    req.authProvider = 'firebase';
    return next();
  } catch (firebaseError) {
    return res.status(401).json({ message: firebaseError.message || 'Firebase authentication gagal.' });
  }
}

module.exports = authRequired;
