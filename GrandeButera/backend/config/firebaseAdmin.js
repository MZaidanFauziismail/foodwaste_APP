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

  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (!raw) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_BASE64 is missing');
  }

  let serviceAccount;
  try {
    const decoded = Buffer
      .from(String(raw).replace(/\s/g, ''), 'base64')
      .toString('utf8');

    serviceAccount = JSON.parse(decoded);
  } catch (err) {
    throw new Error('Invalid FIREBASE_SERVICE_ACCOUNT_BASE64: ' + err.message);
  }

  if (
    !serviceAccount.project_id ||
    !serviceAccount.client_email ||
    !serviceAccount.private_key
  ) {
    throw new Error(
      'FIREBASE_SERVICE_ACCOUNT_BASE64 must be Firebase Admin service account JSON, not google-services.json'
    );
  }

  serviceAccount.private_key = String(serviceAccount.private_key).replace(/\\n/g, '\n');

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  initialized = true;
  return admin;
}

module.exports = { getFirebaseAdmin };
