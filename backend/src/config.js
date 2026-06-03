const path = require('path');
require('dotenv').config();

const rootDir = path.resolve(__dirname, '..');

module.exports = {
  env: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 3000),
  databaseUrl: process.env.DATABASE_URL || 'postgres://ecoshare:ecoshare_password@localhost:5432/ecoshare_db',
  authSecret: process.env.AUTH_SECRET || 'dev_secret_change_me',
  publicBaseUrl: (process.env.PUBLIC_BASE_URL || 'http://localhost:3000').replace(/\/$/, ''),
  corsOrigin: process.env.CORS_ORIGIN || '*',
  uploadDir: path.resolve(rootDir, process.env.UPLOAD_DIR || 'uploads'),

  // Firebase Admin SDK is optional. When configured, Express can verify Firebase Auth ID tokens
  // and send Firebase Cloud Messaging push notifications.
  firebaseProjectId: process.env.FIREBASE_PROJECT_ID || '',
  firebaseServiceAccountBase64: process.env.FIREBASE_SERVICE_ACCOUNT_BASE64 || '',
  googleApplicationCredentials: process.env.GOOGLE_APPLICATION_CREDENTIALS || '',
  firebaseMessagingEnabled: String(process.env.FIREBASE_MESSAGING_ENABLED || 'false').toLowerCase() === 'true',
};
