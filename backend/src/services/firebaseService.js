const fs = require('fs');
const admin = require('firebase-admin');
const config = require('../config');

let initialized = false;

function getServiceAccount() {
  if (config.firebaseServiceAccountBase64) {
    const raw = Buffer.from(config.firebaseServiceAccountBase64, 'base64').toString('utf8');
    return JSON.parse(raw);
  }
  if (config.googleApplicationCredentials && fs.existsSync(config.googleApplicationCredentials)) {
    return JSON.parse(fs.readFileSync(config.googleApplicationCredentials, 'utf8'));
  }
  return null;
}

function initFirebaseAdmin() {
  if (initialized) return admin;
  if (admin.apps.length > 0) {
    initialized = true;
    return admin;
  }

  const serviceAccount = getServiceAccount();
  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: config.firebaseProjectId || serviceAccount.project_id,
    });
    initialized = true;
    return admin;
  }

  if (config.firebaseProjectId) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: config.firebaseProjectId,
    });
    initialized = true;
    return admin;
  }

  return null;
}

function isFirebaseConfigured() {
  return Boolean(config.firebaseProjectId || config.firebaseServiceAccountBase64 || config.googleApplicationCredentials);
}

async function verifyFirebaseIdToken(token) {
  const firebaseAdmin = initFirebaseAdmin();
  if (!firebaseAdmin) throw new Error('Firebase Admin belum dikonfigurasi di backend.');
  return firebaseAdmin.auth().verifyIdToken(token);
}

async function sendPushToUser(userId, payload, db) {
  if (!config.firebaseMessagingEnabled) return;
  const firebaseAdmin = initFirebaseAdmin();
  if (!firebaseAdmin) return;

  const result = await db.query('SELECT fcm_token FROM users WHERE id = $1', [userId]);
  const token = result.rows[0]?.fcm_token;
  if (!token) return;

  try {
    await firebaseAdmin.messaging().send({
      token,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: Object.fromEntries(
        Object.entries(payload.data || {}).map(([key, value]) => [key, String(value ?? '')])
      ),
      android: {
        priority: 'high',
        notification: {
          channelId: 'ecoshare_messages',
        },
      },
    });
  } catch (error) {
    console.warn('FCM send failed:', error.message);
  }
}

module.exports = {
  initFirebaseAdmin,
  isFirebaseConfigured,
  verifyFirebaseIdToken,
  sendPushToUser,
};
