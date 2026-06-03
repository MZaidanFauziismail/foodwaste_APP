TRUNCATE TABLE notifications, messages, listings, users RESTART IDENTITY CASCADE;

INSERT INTO users (id, name, email, password_hash, avatar_url, radius_km, latitude, longitude) VALUES
(1, 'Demo User', 'demo@ecoshare.local', 'pbkdf2$120000$ecoshare_demo_salt$3bb3a5ed613f64638f2c2a0f995763d85840c8d876cbcd7a642ccb3dc27c24c8', NULL, 50, -6.2219, 106.6479),
(2, 'Naya Kitchen', 'naya@ecoshare.local', 'pbkdf2$120000$ecoshare_demo_salt$3bb3a5ed613f64638f2c2a0f995763d85840c8d876cbcd7a642ccb3dc27c24c8', NULL, 50, -6.2258, 106.6521),
(3, 'Raka Studio', 'raka@ecoshare.local', 'pbkdf2$120000$ecoshare_demo_salt$3bb3a5ed613f64638f2c2a0f995763d85840c8d876cbcd7a642ccb3dc27c24c8', NULL, 50, -6.2297, 106.6422);

INSERT INTO listings (
 id, user_id, title, description, type, category, condition, status, price, location_text, latitude, longitude, image_url, available_until,
 predicted_category, safety_label, safety_score, freshness_score, impact_meals, impact_water_liters, ai_notes, created_at
) VALUES
(1, 2, 'Roti tawar sealed', 'Masih segel, beli kemarin malam. Pickup area Alam Sutera.', 'free', 'food', 'good', 'available', NULL, 'Jalur Sutera Barat', -6.2258, 106.6521, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=900', now() + interval '2 days', 'food', 'safe', 94, 90, 4, 5000, 'Model mendeteksi listing makanan. Cantumkan waktu pembuatan, kondisi kemasan, dan aturan pickup.', now() - interval '2 hours'),
(2, 3, 'Lunch box reusable', 'Lunch box bersih, jarang dipakai. Cocok buat meal prep.', 'free', 'non_food', 'good', 'available', NULL, 'BSD Serpong', -6.2297, 106.6422, 'https://images.unsplash.com/photo-1604909052743-94e838986d24?w=900', now() + interval '3 days', 'non_food', 'safe', 96, 94, 0, 420, 'Model mendeteksi listing non-food untuk reuse, lend, sell, wanted, atau forum.', now() - interval '4 hours'),
(3, 2, 'Paket buah fresh', 'Ada apel dan jeruk, masih fresh. Ambil hari ini.', 'free', 'food', 'good', 'available', NULL, 'Gading Serpong', -6.2414, 106.6282, 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=900', now() + interval '1 day', 'food', 'safe', 99, 98, 4, 5000, 'Kata terkait segar/segel/baru meningkatkan confidence listing.', now() - interval '6 hours'),
(4, 3, 'Buku catatan aesthetic', 'Notebook masih bagus, beberapa halaman pertama terpakai.', 'sell', 'non_food', 'good', 'available', 12000, 'Alam Sutera', -6.2205, 106.6481, 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=900', now() + interval '7 days', 'non_food', 'safe', 94, 94, 0, 420, 'Model mendeteksi listing non-food untuk reuse, lend, sell, wanted, atau forum.', now() - interval '8 hours'),
(5, 2, 'Nasi box event sisa', 'Sisa event kantor, masih aman dan baru dibagikan siang ini.', 'free', 'food', 'good', 'available', NULL, 'Tangerang Selatan', -6.2360, 106.6390, 'https://images.unsplash.com/photo-1543352634-a1c51d9f1fa7?w=900', now() + interval '1 day', 'food', 'safe', 97, 94, 4, 5000, 'Model mendeteksi listing makanan. Cantumkan waktu pembuatan, kondisi kemasan, dan aturan pickup.', now() - interval '10 hours'),
(6, 3, 'Wanted: tote bag', 'Lagi cari tote bag polos untuk belanja tanpa plastik.', 'wanted', 'non_food', 'good', 'available', NULL, 'Sekitar Binus Alam Sutera', -6.2230, 106.6492, NULL, now() + interval '14 days', 'non_food', 'safe', 96, 94, 0, 420, 'Model mendeteksi listing non-food untuk reuse, lend, sell, wanted, atau forum.', now() - interval '12 hours');

INSERT INTO messages (id, listing_id, sender_id, receiver_id, body, created_at) VALUES
(1, 1, 1, 2, 'Hi, roti tawarnya masih available?', now() - interval '35 minutes'),
(2, 1, 2, 1, 'Masih, boleh pickup sore ini ya.', now() - interval '30 minutes');

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('listings_id_seq', (SELECT MAX(id) FROM listings));
SELECT setval('messages_id_seq', (SELECT MAX(id) FROM messages));


INSERT INTO notifications (id, user_id, actor_id, listing_id, type, title, body, is_read, created_at) VALUES
(1, 1, 2, 1, 'message', 'Chat baru dari Naya Kitchen', 'Masih, boleh pickup sore ini ya.', false, now() - interval '30 minutes'),
(2, 2, 1, 1, 'request', 'Request baru untuk Roti tawar sealed', 'Demo User tertarik dengan listing kamu.', false, now() - interval '35 minutes'),
(3, 3, NULL, NULL, 'system', 'Welcome to EcoShare', 'Share one item today and help reduce waste nearby.', true, now() - interval '1 day');

SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications));
