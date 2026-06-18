const { initializeApp, cert, getApps, getApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

let app = null;

function loadServiceAccount() {
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

  return serviceAccount;
}

function getFirebaseAdmin() {
  if (!app) {
    if (getApps().length > 0) {
      app = getApp();
    } else {
      app = initializeApp({
        credential: cert(loadServiceAccount()),
      });
    }
  }

  return {
    auth: () => getAuth(app),
  };
}

module.exports = { getFirebaseAdmin };
