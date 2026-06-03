const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

function readServiceAccount() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
    return JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8'));
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS && fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)) {
    return JSON.parse(fs.readFileSync(process.env.GOOGLE_APPLICATION_CREDENTIALS, 'utf8'));
  }
  throw new Error('Set FIREBASE_SERVICE_ACCOUNT_BASE64 atau GOOGLE_APPLICATION_CREDENTIALS dulu.');
}

const serviceAccount = readServiceAccount();
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: process.env.FIREBASE_PROJECT_ID || serviceAccount.project_id,
});

const users = [
  { email: 'demo@ecoshare.local', password: 'password', displayName: 'Dannn' },
  { email: 'naya@ecoshare.local', password: 'password', displayName: 'Naya Kitchen' },
  { email: 'raka@ecoshare.local', password: 'password', displayName: 'Raka Studio' },
];

async function upsertUser(item) {
  try {
    const existing = await admin.auth().getUserByEmail(item.email);
    await admin.auth().updateUser(existing.uid, {
      password: item.password,
      displayName: item.displayName,
      emailVerified: true,
      disabled: false,
    });
    console.log(`Updated Firebase user: ${item.email}`);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
    await admin.auth().createUser({
      email: item.email,
      password: item.password,
      displayName: item.displayName,
      emailVerified: true,
      disabled: false,
    });
    console.log(`Created Firebase user: ${item.email}`);
  }
}

(async () => {
  for (const user of users) await upsertUser(user);
  console.log('Done. Enable Email/Password provider in Firebase Authentication, then login from Flutter.');
  process.exit(0);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
