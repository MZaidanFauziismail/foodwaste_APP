const fs = require('fs');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const multer = require('multer');
const path = require('path');

const config = require('./config');
const { query, transaction } = require('./db');
const authRequired = require('./middleware/authRequired');
const { notFound, errorHandler } = require('./middleware/errorHandler');
const { hashPassword, verifyPassword } = require('./utils/password');
const { signToken } = require('./utils/token');
const { toNumber, distanceKm } = require('./utils/geo');
const { predictListing } = require('./services/mlService');
const { sendPushToUser } = require('./services/firebaseService');

fs.mkdirSync(path.join(config.uploadDir, 'listings'), { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(config.uploadDir, 'listings')),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname || '').toLowerCase() || '.jpg';
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 4 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) return cb(new Error('File harus berupa gambar.'));
    cb(null, true);
  },
});

const app = express();

app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors({ origin: config.corsOrigin === '*' ? true : config.corsOrigin, credentials: true }));
app.use(morgan(config.env === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, limit: 400, standardHeaders: true, legacyHeaders: false }));
app.use('/uploads', express.static(config.uploadDir));

app.get('/', (req, res) => {
  res.json({ message: 'EcoShare API is running', health: '/health', api: '/api' });
});

app.get('/health', async (req, res, next) => {
  try {
    await query('SELECT 1');
    res.json({ ok: true, service: 'ecoshare-backend', database: 'connected' });
  } catch (error) {
    next(error);
  }
});

const api = express.Router();

function publicUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    avatar_url: row.avatar_url,
    radius_km: row.radius_km,
    latitude: row.latitude === null ? null : Number(row.latitude),
    longitude: row.longitude === null ? null : Number(row.longitude),
  };
}

function normalizeListing(row, currentUserId = null, lat = null, lng = null) {
  const distance = distanceKm(lat, lng, row.latitude, row.longitude);
  return {
    id: row.id,
    user_id: row.user_id,
    owner_name: row.owner_name,
    title: row.title,
    description: row.description,
    type: row.type,
    category: row.category,
    condition: row.condition,
    status: row.status,
    price: row.price === null ? null : Number(row.price),
    location_text: row.location_text,
    latitude: row.latitude === null ? null : Number(row.latitude),
    longitude: row.longitude === null ? null : Number(row.longitude),
    distance_km: distance,
    image_url: row.image_url,
    available_until: row.available_until,
    predicted_category: row.predicted_category,
    safety_score: row.safety_score === null ? null : Number(row.safety_score),
    freshness_score: row.freshness_score === null ? null : Number(row.freshness_score),
    impact_meals: row.impact_meals === null ? 0 : Number(row.impact_meals),
    impact_water_liters: row.impact_water_liters === null ? 0 : Number(row.impact_water_liters),
    ai_notes: row.ai_notes,
    created_at: row.created_at,
    is_mine: currentUserId !== null && Number(row.user_id) === Number(currentUserId),
  };
}

function requireString(value, name, min = 1) {
  const text = String(value || '').trim();
  if (text.length < min) {
    const error = new Error(`${name} wajib diisi minimal ${min} karakter.`);
    error.statusCode = 400;
    throw error;
  }
  return text;
}

async function notifyUser({ userId, actorId = null, listingId = null, type = 'general', title, body }, client = null) {
  const db = client || { query };
  await db.query(
    `INSERT INTO notifications (user_id, actor_id, listing_id, type, title, body)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [userId, actorId, listingId, type, title, body]
  );
  await sendPushToUser(userId, {
    title,
    body,
    data: { type, listing_id: listingId || '', actor_id: actorId || '' },
  }, db);
}

api.post('/auth/register', async (req, res, next) => {
  try {
    const name = requireString(req.body.name, 'Nama', 2);
    const email = requireString(req.body.email, 'Email', 5).toLowerCase();
    const password = requireString(req.body.password, 'Password', 6);

    const exists = await query('SELECT id FROM users WHERE lower(email) = lower($1)', [email]);
    if (exists.rowCount > 0) return res.status(409).json({ message: 'Email sudah terdaftar.' });

    const result = await query(
      `INSERT INTO users (name, email, password_hash, latitude, longitude)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, email, avatar_url, radius_km, latitude, longitude`,
      [name, email, hashPassword(password), toNumber(req.body.latitude) || -6.2219, toNumber(req.body.longitude) || 106.6479]
    );
    const user = publicUser(result.rows[0]);
    res.status(201).json({ token: signToken({ sub: user.id, email: user.email }), user });
  } catch (error) {
    next(error);
  }
});

api.post('/auth/login', async (req, res, next) => {
  try {
    const email = requireString(req.body.email, 'Email', 5).toLowerCase();
    const password = String(req.body.password || '');
    const result = await query(
      `SELECT id, name, email, password_hash, avatar_url, radius_km, latitude, longitude
       FROM users
       WHERE lower(email) = lower($1)`,
      [email]
    );
    if (result.rowCount === 0 || !verifyPassword(password, result.rows[0].password_hash)) {
      return res.status(401).json({ message: 'Email atau password salah.' });
    }
    const user = publicUser(result.rows[0]);
    res.json({ token: signToken({ sub: user.id, email: user.email }), user });
  } catch (error) {
    next(error);
  }
});

api.get('/auth/me', authRequired, (req, res) => {
  res.json({ user: publicUser(req.user) });
});

api.patch('/auth/me', authRequired, async (req, res, next) => {
  try {
    const latitude = toNumber(req.body.latitude);
    const longitude = toNumber(req.body.longitude);
    const radiusKm = req.body.radius_km === undefined ? null : Math.round(toNumber(req.body.radius_km) || req.user.radius_km);
    const result = await query(
      `UPDATE users
       SET latitude = COALESCE($1, latitude),
           longitude = COALESCE($2, longitude),
           radius_km = COALESCE($3, radius_km),
           updated_at = now()
       WHERE id = $4
       RETURNING id, name, email, avatar_url, radius_km, latitude, longitude`,
      [latitude, longitude, radiusKm, req.user.id]
    );
    res.json({ user: publicUser(result.rows[0]) });
  } catch (error) {
    next(error);
  }
});

api.post('/device/fcm-token', authRequired, async (req, res, next) => {
  try {
    const fcmToken = requireString(req.body.fcm_token, 'FCM token', 10);
    await query('UPDATE users SET fcm_token = $1, updated_at = now() WHERE id = $2', [fcmToken, req.user.id]);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

api.post('/ml/predict', authRequired, (req, res, next) => {
  try {
    const ml = predictListing({
      title: req.body.title,
      description: req.body.description,
      category: req.body.category,
      type: req.body.type,
    });
    res.json({ ml });
  } catch (error) {
    next(error);
  }
});

api.get('/listings', authRequired, async (req, res, next) => {
  try {
    const category = req.query.category && req.query.category !== 'all' ? String(req.query.category) : null;
    const type = req.query.type && req.query.type !== 'all' ? String(req.query.type) : null;
    const q = req.query.q ? `%${String(req.query.q).trim()}%` : null;
    const lat = toNumber(req.query.lat);
    const lng = toNumber(req.query.lng);
    const radius = toNumber(req.query.radius);

    const filters = ['l.status = $1'];
    const params = ['available'];
    if (category) {
      params.push(category);
      filters.push(`l.category = $${params.length}`);
    }
    if (type) {
      params.push(type);
      filters.push(`l.type = $${params.length}`);
    }
    if (q) {
      params.push(q);
      filters.push(`(l.title ILIKE $${params.length} OR l.description ILIKE $${params.length} OR l.location_text ILIKE $${params.length})`);
    }

    const result = await query(
      `SELECT l.*, u.name AS owner_name
       FROM listings l
       JOIN users u ON u.id = l.user_id
       WHERE ${filters.join(' AND ')}
       ORDER BY l.created_at DESC
       LIMIT 100`,
      params
    );

    let listings = result.rows.map((row) => normalizeListing(row, req.user.id, lat, lng));
    if (radius && lat !== null && lng !== null) {
      listings = listings.filter((item) => item.distance_km === null || item.distance_km <= radius);
    }
    listings.sort((a, b) => (a.distance_km ?? 999999) - (b.distance_km ?? 999999));
    res.json({ listings });
  } catch (error) {
    next(error);
  }
});


api.get('/my-listings', authRequired, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT l.*, u.name AS owner_name
       FROM listings l
       JOIN users u ON u.id = l.user_id
       WHERE l.user_id = $1
       ORDER BY l.created_at DESC
       LIMIT 100`,
      [req.user.id]
    );
    res.json({ listings: result.rows.map((row) => normalizeListing(row, req.user.id, req.user.latitude, req.user.longitude)) });
  } catch (error) {
    next(error);
  }
});

api.get('/listings/:id', authRequired, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT l.*, u.name AS owner_name
       FROM listings l
       JOIN users u ON u.id = l.user_id
       WHERE l.id = $1`,
      [req.params.id]
    );
    if (result.rowCount === 0) return res.status(404).json({ message: 'Listing tidak ditemukan.' });
    res.json({ listing: normalizeListing(result.rows[0], req.user.id) });
  } catch (error) {
    next(error);
  }
});

api.post('/listings', authRequired, upload.single('image'), async (req, res, next) => {
  try {
    const title = requireString(req.body.title, 'Judul', 3);
    const description = String(req.body.description || '').trim();
    const type = ['free', 'sell', 'lend', 'wanted', 'forum'].includes(req.body.type) ? req.body.type : 'free';
    const category = ['food', 'non_food'].includes(req.body.category) ? req.body.category : 'food';
    const locationText = requireString(req.body.location_text, 'Lokasi', 2);
    const latitude = toNumber(req.body.latitude) ?? req.user.latitude;
    const longitude = toNumber(req.body.longitude) ?? req.user.longitude;
    const price = type === 'sell' ? toNumber(req.body.price) : null;
    const ml = predictListing({ title, description, category, type });
    const imageUrl = req.file
      ? `${config.publicBaseUrl}/uploads/listings/${req.file.filename}`
      : String(req.body.image_url || '').trim() || null;

    const result = await query(
      `INSERT INTO listings (
         user_id, title, description, type, category, condition, status, price,
         location_text, latitude, longitude, image_url, available_until,
         predicted_category, safety_score, freshness_score, impact_meals,
         impact_water_liters, ai_notes
       )
       VALUES ($1,$2,$3,$4,$5,$6,'available',$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
       RETURNING *`,
      [
        req.user.id,
        title,
        description,
        type,
        category,
        req.body.condition || 'good',
        price,
        locationText,
        latitude,
        longitude,
        imageUrl,
        req.body.available_until || null,
        ml.predicted_category,
        ml.safety_score,
        ml.freshness_score,
        ml.impact_meals,
        ml.impact_water_liters,
        ml.notes.join(' '),
      ]
    );

    const joined = await query(
      `SELECT l.*, u.name AS owner_name FROM listings l JOIN users u ON u.id = l.user_id WHERE l.id = $1`,
      [result.rows[0].id]
    );
    res.status(201).json({ listing: normalizeListing(joined.rows[0], req.user.id) });
  } catch (error) {
    next(error);
  }
});

api.post('/listings/:id/request', authRequired, async (req, res, next) => {
  try {
    const listing = await query('SELECT id, user_id, title FROM listings WHERE id = $1', [req.params.id]);
    if (listing.rowCount === 0) return res.status(404).json({ message: 'Listing tidak ditemukan.' });
    const item = listing.rows[0];
    if (Number(item.user_id) === Number(req.user.id)) return res.status(400).json({ message: 'Ini listing kamu sendiri.' });
    const message = String(req.body.message || 'Hi, aku tertarik dengan listing ini.').trim();

    await transaction(async (client) => {
      await client.query(
        `INSERT INTO messages (listing_id, sender_id, receiver_id, body)
         VALUES ($1, $2, $3, $4)`,
        [item.id, req.user.id, item.user_id, message]
      );
      await notifyUser({
        userId: item.user_id,
        actorId: req.user.id,
        listingId: item.id,
        type: 'request',
        title: `Request baru untuk ${item.title}`,
        body: `${req.user.name} tertarik dengan listing kamu.`,
      }, client);
      await client.query(
        `INSERT INTO messages (listing_id, sender_id, receiver_id, body)
         VALUES ($1, $2, $3, $4)`,
        [item.id, item.user_id, req.user.id, 'Hi! Thanks ya, aku cek dulu dan kabarin kamu.']
      );
      await notifyUser({
        userId: req.user.id,
        actorId: item.user_id,
        listingId: item.id,
        type: 'message',
        title: `Balasan dari pemilik ${item.title}`,
        body: 'Hi! Thanks ya, aku cek dulu dan kabarin kamu.',
      }, client);
    });

    res.status(201).json({ ok: true });
  } catch (error) {
    next(error);
  }
});

api.get('/messages/conversations', authRequired, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT m.*, l.title AS listing_title,
              CASE WHEN m.sender_id = $1 THEN m.receiver_id ELSE m.sender_id END AS other_user_id,
              u.name AS other_user_name
       FROM messages m
       JOIN listings l ON l.id = m.listing_id
       JOIN users u ON u.id = CASE WHEN m.sender_id = $1 THEN m.receiver_id ELSE m.sender_id END
       WHERE m.sender_id = $1 OR m.receiver_id = $1
       ORDER BY m.created_at ASC`,
      [req.user.id]
    );
    const map = new Map();
    for (const row of result.rows) {
      const key = `${row.listing_id}-${row.other_user_id}`;
      map.set(key, {
        listing_id: row.listing_id,
        listing_title: row.listing_title,
        other_user_id: row.other_user_id,
        other_user_name: row.other_user_name,
        last_message: row.body,
        updated_at: row.created_at,
      });
    }
    res.json({ conversations: [...map.values()].sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at)) });
  } catch (error) {
    next(error);
  }
});

api.get('/messages/:listingId/:otherUserId', authRequired, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT id, listing_id, sender_id, receiver_id, body, created_at
       FROM messages
       WHERE listing_id = $1
         AND ((sender_id = $2 AND receiver_id = $3) OR (sender_id = $3 AND receiver_id = $2))
       ORDER BY created_at ASC`,
      [req.params.listingId, req.user.id, req.params.otherUserId]
    );
    res.json({ messages: result.rows });
  } catch (error) {
    next(error);
  }
});

api.post('/messages/:listingId/:otherUserId', authRequired, async (req, res, next) => {
  try {
    const body = requireString(req.body.body, 'Pesan', 1);
    const listing = await query('SELECT id, title FROM listings WHERE id = $1', [req.params.listingId]);
    if (listing.rowCount === 0) return res.status(404).json({ message: 'Listing tidak ditemukan.' });
    await transaction(async (client) => {
      await client.query(
        `INSERT INTO messages (listing_id, sender_id, receiver_id, body)
         VALUES ($1, $2, $3, $4)`,
        [req.params.listingId, req.user.id, req.params.otherUserId, body]
      );
      await notifyUser({
        userId: req.params.otherUserId,
        actorId: req.user.id,
        listingId: req.params.listingId,
        type: 'message',
        title: `Pesan baru dari ${req.user.name}`,
        body: body.length > 120 ? `${body.slice(0, 120)}…` : body,
      }, client);
    });
    res.status(201).json({ ok: true });
  } catch (error) {
    next(error);
  }
});


api.get('/notifications', authRequired, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT n.id, n.type, n.title, n.body, n.is_read, n.created_at,
              n.listing_id, n.actor_id, u.name AS actor_name, l.title AS listing_title
       FROM notifications n
       LEFT JOIN users u ON u.id = n.actor_id
       LEFT JOIN listings l ON l.id = n.listing_id
       WHERE n.user_id = $1
       ORDER BY n.created_at DESC
       LIMIT 50`,
      [req.user.id]
    );
    const unread = await query('SELECT COUNT(*)::int AS total FROM notifications WHERE user_id = $1 AND is_read = false', [req.user.id]);
    res.json({ notifications: result.rows, unread: unread.rows[0].total });
  } catch (error) {
    next(error);
  }
});

api.patch('/notifications/read', authRequired, async (req, res, next) => {
  try {
    await query('UPDATE notifications SET is_read = true WHERE user_id = $1', [req.user.id]);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

api.patch('/listings/:id/status', authRequired, async (req, res, next) => {
  try {
    const status = ['available', 'reserved', 'completed', 'cancelled'].includes(req.body.status) ? req.body.status : null;
    if (!status) return res.status(400).json({ message: 'Status tidak valid.' });
    const result = await query(
      `UPDATE listings SET status = $1 WHERE id = $2 AND user_id = $3 RETURNING *`,
      [status, req.params.id, req.user.id]
    );
    if (result.rowCount === 0) return res.status(404).json({ message: 'Listing tidak ditemukan atau bukan milik kamu.' });
    const joined = await query(
      `SELECT l.*, u.name AS owner_name FROM listings l JOIN users u ON u.id = l.user_id WHERE l.id = $1`,
      [req.params.id]
    );
    res.json({ listing: normalizeListing(joined.rows[0], req.user.id) });
  } catch (error) {
    next(error);
  }
});

api.get('/community', authRequired, async (req, res, next) => {
  try {
    const members = await query('SELECT COUNT(*)::int AS total FROM users');
    const available = await query("SELECT COUNT(*)::int AS total FROM listings WHERE status = 'available'");
    const recent = await query(
      `SELECT l.title, u.name AS owner_name, l.category
       FROM listings l
       JOIN users u ON u.id = l.user_id
       WHERE l.status = 'available'
       ORDER BY l.created_at DESC
       LIMIT 6`
    );
    res.json({
      total_members: members.rows[0].total,
      available_listings: available.rows[0].total,
      recent_listings: recent.rows,
    });
  } catch (error) {
    next(error);
  }
});

api.get('/impact', authRequired, async (req, res, next) => {
  try {
    const mine = await query(
      `SELECT COALESCE(SUM(impact_meals), 0)::int AS meals,
              COALESCE(SUM(impact_water_liters), 0)::int AS water,
              COUNT(*)::int AS total_listings
       FROM listings
       WHERE user_id = $1`,
      [req.user.id]
    );
    const people = await query(
      `SELECT COUNT(DISTINCT CASE WHEN sender_id = $1 THEN receiver_id ELSE sender_id END)::int AS total
       FROM messages
       WHERE sender_id = $1 OR receiver_id = $1`,
      [req.user.id]
    );
    const meals = mine.rows[0].meals;
    const badges = [];
    if (mine.rows[0].total_listings > 0) badges.push('First listing');
    if (meals >= 3) badges.push('Food Waste Hero');
    if (people.rows[0].total >= 1) badges.push('Community Connector');
    res.json({
      impact: {
        people_shared_with: people.rows[0].total,
        meals_saved: meals,
        water_not_wasted_liters: mine.rows[0].water,
      },
      badges,
    });
  } catch (error) {
    next(error);
  }
});

api.get('/ml/metrics', authRequired, (req, res) => {
  const metricsPath = path.resolve(__dirname, 'ml_model/metrics.json');
  res.json(JSON.parse(fs.readFileSync(metricsPath, 'utf8')));
});

app.use('/api', api);
app.use(notFound);
app.use(errorHandler);

module.exports = app;
