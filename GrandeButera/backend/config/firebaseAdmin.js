const admin = require('firebase-admin');

let initialized = false;

function getFirebaseAdmin() {
  if (initialized) return admin;

  try {
    admin.app();
    initialized = true;
    return admin;
  } catch (_) {
    // No Firebase app initialized yet
  }

  const encoded = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (!encoded) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_BASE64 is missing');
  }

  let serviceAccount;
  try {
    serviceAccount = JSON.parse(Buffer.from(encoded, 'base64').toString('utf8'));
  } catch (err) {
    throw new Error('Invalid FIREBASE_SERVICE_ACCOUNT_BASE64: ' + err.message);
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  initialized = true;
  return admin;
}

module.exports = { getFirebaseAdmin };
