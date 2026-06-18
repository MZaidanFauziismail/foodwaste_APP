const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const { query } = require('../db/pool');
const { formatUser } = require('../utils/formatters');
const auth = require('../middleware/auth');
const { getFirebaseAdmin } = require('../config/firebaseAdmin');

const generateToken = (userId) => jwt.sign({ userId }, process.env.JWT_SECRET || 'sharebite_secret', {
  expiresIn: process.env.JWT_EXPIRES_IN || '7d',
});

router.post('/register', [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Valid email required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

    const { name, password, phone } = req.body;
    const email = String(req.body.email).trim().toLowerCase();

    const existing = await query('SELECT id FROM users WHERE email = $1 LIMIT 1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const { rows } = await query(
      `INSERT INTO users (name, email, password, phone)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [name.trim(), email, hashedPassword, phone || null],
    );

    const user = formatUser(rows[0], { includeEmail: true });
    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      data: { token, user },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/login', [
  body('email').isEmail().withMessage('Valid email required'),
  body('password').notEmpty().withMessage('Password required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

    const email = String(req.body.email).trim().toLowerCase();
    const { password } = req.body;
    const { rows } = await query('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
    const dbUser = rows[0];

    if (!dbUser || !(await bcrypt.compare(password, dbUser.password))) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
    if (!dbUser.is_active) {
      return res.status(403).json({ success: false, message: 'Account is inactive' });
    }

    const updated = await query(
      'UPDATE users SET last_seen = NOW(), updated_at = NOW() WHERE id = $1 RETURNING *',
      [dbUser.id],
    );

    const user = formatUser(updated.rows[0], { includeEmail: true });
    const token = generateToken(user._id);

    res.json({
      success: true,
      message: 'Login successful',
      data: { token, user },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});


router.post('/firebase', async (req, res) => {
  try {
    const idToken = String(req.body.idToken || req.body.token || '').trim();

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'Firebase ID token required',
      });
    }

    const firebaseAdmin = getFirebaseAdmin();
    const decoded = await firebaseAdmin.auth().verifyIdToken(idToken);

    const firebaseUid = decoded.uid;
    const email = String(decoded.email || '').trim().toLowerCase();
    const name = String(decoded.name || (email ? email.split('@')[0] : 'Google User')).trim();
    const avatar = decoded.picture || null;
    const emailVerified = decoded.email_verified === true;

    if (!firebaseUid || !email) {
      return res.status(400).json({
        success: false,
        message: 'Firebase account must have an email',
      });
    }

    const byFirebase = await query(
      'SELECT * FROM users WHERE firebase_uid = $1 LIMIT 1',
      [firebaseUid],
    );

    let dbUser = byFirebase.rows[0];

    if (!dbUser) {
      const byEmail = await query(
        'SELECT * FROM users WHERE email = $1 LIMIT 1',
        [email],
      );

      const emailUser = byEmail.rows[0];

      if (emailUser) {
        if (emailUser.firebase_uid && emailUser.firebase_uid !== firebaseUid) {
          return res.status(409).json({
            success: false,
            message: 'Email already linked to another Firebase account',
          });
        }

        const updated = await query(
          `UPDATE users
           SET firebase_uid = $1,
               auth_provider = CASE
                 WHEN auth_provider = 'local' THEN 'local_google'
                 ELSE auth_provider
               END,
               avatar = COALESCE(avatar, $2),
               is_verified = CASE WHEN $3::boolean THEN true ELSE is_verified END,
               last_seen = NOW(),
               updated_at = NOW()
           WHERE id = $4
           RETURNING *`,
          [firebaseUid, avatar, emailVerified, emailUser.id],
        );

        dbUser = updated.rows[0];
      } else {
        const dummyPassword = await bcrypt.hash(`firebase:${firebaseUid}:${email}`, 12);

        const created = await query(
          `INSERT INTO users (
             name, email, password, avatar, is_verified, firebase_uid, auth_provider, last_seen
           )
           VALUES ($1, $2, $3, $4, $5, $6, 'firebase_google', NOW())
           RETURNING *`,
          [name || 'Google User', email, dummyPassword, avatar, emailVerified, firebaseUid],
        );

        dbUser = created.rows[0];
      }
    } else {
      const updated = await query(
        `UPDATE users
         SET avatar = COALESCE(avatar, $1),
             is_verified = CASE WHEN $2::boolean THEN true ELSE is_verified END,
             last_seen = NOW(),
             updated_at = NOW()
         WHERE id = $3
         RETURNING *`,
        [avatar, emailVerified, dbUser.id],
      );

      dbUser = updated.rows[0];
    }

    if (!dbUser.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Account is inactive',
      });
    }

    const user = formatUser(dbUser, { includeEmail: true });
    const token = generateToken(user._id);

    res.json({
      success: true,
      message: 'Google login successful',
      data: { token, user },
    });
  } catch (err) {
    console.error('Firebase auth error:', err);

    const code = String(err.code || '');
    if (code.startsWith('auth/')) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Firebase token',
      });
    }

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});


router.get('/me', auth, async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
});

router.post('/refresh', auth, async (req, res) => {
  const token = generateToken(req.userId);
  res.json({ success: true, data: { token } });
});

module.exports = router;
