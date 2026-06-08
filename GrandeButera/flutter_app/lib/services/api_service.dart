import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  // Android emulator: 10.0.2.2 | Physical device: use --dart-define API_BASE_URL.
  static const String baseUrl = ApiConfig.apiBaseUrl;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static String? _token;

  // Offline demo mode. This keeps the app usable when the Node/Docker backend is not running.
  static const String demoEmail = 'demo@sharebite.app';
  static const String demoPassword = 'password123';
  static const String demoToken = 'demo_offline_token';

  static bool _demoStateLoaded = false;

  static Map<String, dynamic> _demoUser = {
    '_id': 'demo-user-1',
    'name': 'Demo User',
    'email': demoEmail,
    'bio': 'Sharing food and useful items around the neighborhood.',
    'avatar': null,
    'isVerified': true,
    'badges': ['Demo'],
    'stats': {
      'totalShared': 12,
      'totalReceived': 5,
      'mealsaved': 28,
      'rating': 4.8,
      'ratingCount': 9,
    },
    'location': {
      'type': 'Point',
      'coordinates': [106.8456, -6.2088],
      'address': 'Jakarta, Indonesia',
    },
  };

  static List<Map<String, dynamic>>? _demoListingsCache;

  static List<Map<String, dynamic>> get _demoListings {
    _demoListingsCache ??= _buildDemoListings();
    return _demoListingsCache!;
  }

  static List<Map<String, dynamic>> _buildDemoListings() => [
        {
          '_id': 'demo-listing-1',
          'title': 'Fresh Rice Box',
          'description': 'Extra rice box from lunch event. Still fresh and ready to pick up.',
          'category': 'free_food',
          'foodType': 'meal',
          'images': <String>[],
          'tags': ['rice', 'lunch', 'halal'],
          'quantity': 3,
          'unit': 'box',
          'price': 0,
          'expiresAt': DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
          'isAvailable': true,
          'owner': _demoUser,
          'location': {
            'type': 'Point',
            'coordinates': [106.8456, -6.2088],
            'address': 'Central Jakarta',
            'neighborhood': 'Menteng',
          },
          'distance': 850,
          'dietaryInfo': ['Halal'],
          'allergens': <String>[],
          'viewCount': 42,
          'createdAt': DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
        },
        {
          '_id': 'demo-listing-2',
          'title': 'Banana Cake Slices',
          'description': 'Homemade banana cake, soft texture, available in several slices.',
          'category': 'for_sale',
          'foodType': 'snack',
          'images': <String>[],
          'tags': ['cake', 'banana', 'snack'],
          'quantity': 6,
          'unit': 'slice',
          'price': 8000,
          'expiresAt': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'isAvailable': true,
          'owner': _demoUser,
          'location': {
            'type': 'Point',
            'coordinates': [106.8272, -6.1754],
            'address': 'Tanah Abang, Jakarta',
            'neighborhood': 'Tanah Abang',
          },
          'distance': 1700,
          'dietaryInfo': <String>[],
          'allergens': ['Egg', 'Wheat'],
          'viewCount': 31,
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          '_id': 'demo-listing-3',
          'title': 'Clean Food Containers',
          'description': 'Reusable food containers in good condition. Can be borrowed for events.',
          'category': 'borrow',
          'images': <String>[],
          'tags': ['container', 'event', 'reusable'],
          'quantity': 10,
          'unit': 'pcs',
          'price': 0,
          'isAvailable': true,
          'owner': _demoUser,
          'location': {
            'type': 'Point',
            'coordinates': [106.7995, -6.2441],
            'address': 'South Jakarta',
            'neighborhood': 'Senayan',
          },
          'distance': 3200,
          'dietaryInfo': <String>[],
          'allergens': <String>[],
          'viewCount': 15,
          'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        },
      ];

  static Future<bool> _isDemoMode() async => (await getToken()) == demoToken;

  static Future<void> _loadDemoState() async {
    if (_demoStateLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('demo_user');
      final listingsRaw = prefs.getString('demo_listings');
      if (userRaw != null && userRaw.isNotEmpty) {
        _demoUser = Map<String, dynamic>.from(jsonDecode(userRaw) as Map);
      }
      if (listingsRaw != null && listingsRaw.isNotEmpty) {
        _demoListingsCache = (jsonDecode(listingsRaw) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (_) {
      // Keep seeded demo data if local cache cannot be read.
    }
    _demoStateLoaded = true;
  }

  static Future<void> _saveDemoState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('demo_user', jsonEncode(_demoUser));
      await prefs.setString('demo_listings', jsonEncode(_demoListings));
    } catch (_) {}
  }

  static List<String> _decodeStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return <String>[];
      try {
        final decoded = jsonDecode(text);
        if (decoded is List) return decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      } catch (_) {}
      return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return <String>[];
  }

  static String _localImageUrl(File file) => 'file://${file.path}';

  static Future<Map<String, dynamic>> _demoListingsResponse({String category = 'all', String? search}) async {
    await _loadDemoState();
    var items = List<Map<String, dynamic>>.from(_demoListings);
    if (category != 'all') {
      items = items.where((item) => item['category'] == category).toList();
    }
    final q = search?.trim().toLowerCase() ?? '';
    if (q.isNotEmpty) {
      items = items.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final desc = (item['description'] ?? '').toString().toLowerCase();
        final tags = ((item['tags'] as List?) ?? const []).join(' ').toLowerCase();
        final categoryText = (item['category'] ?? '').toString().replaceAll('_', ' ').toLowerCase();
        return title.contains(q) || desc.contains(q) || tags.contains(q) || categoryText.contains(q);
      }).toList();
    }
    items.sort((a, b) => (DateTime.tryParse('${b['createdAt']}') ?? DateTime(2000))
        .compareTo(DateTime.tryParse('${a['createdAt']}') ?? DateTime(2000)));
    return {
      'success': true,
      'data': {'listings': items, 'total': items.length},
      'message': 'Offline demo listings loaded',
    };
  }

  static Future<String?> getToken() async {
    _token ??= await _storage.read(key: 'auth_token');
    return _token;
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Map<String, dynamic> _handle(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return {'success': true, 'data': body['data'], 'message': body['message']};
    }
    throw ApiException(body['message'] ?? 'Request failed', res.statusCode);
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register(String name, String email, String password, {String? phone}) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: await _headers(auth: false),
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'phone': phone}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    if (email.trim().toLowerCase() == demoEmail && password == demoPassword) {
      await _loadDemoState();
      return {
        'success': true,
        'data': {'token': demoToken, 'user': _demoUser},
        'message': 'Logged in using offline demo mode',
      };
    }
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: await _headers(auth: false),
        body: jsonEncode({'email': email, 'password': password}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getMe() async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      return {'success': true, 'data': {'user': _demoUser}, 'message': 'Offline demo user loaded'};
    }
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: await _headers());
    return _handle(res);
  }

  // ── LISTINGS ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getListings({
    double? lat, double? lng, double radius = 10000,
    String category = 'all', String? search, int page = 1, String sort = 'distance',
  }) async {
    if (await _isDemoMode()) return _demoListingsResponse(category: category, search: search);
    final uri = Uri.parse('$baseUrl/listings').replace(queryParameters: {
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      'radius': radius.toString(),
      if (category != 'all') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page.toString(),
      'limit': '50',
      'sort': sort,
    });
    final res = await http.get(uri, headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getListing(String id) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      final listing = _demoListings.firstWhere(
        (item) => item['_id'] == id || item['id'] == id,
        orElse: () => _demoListings.first,
      );
      return {'success': true, 'data': {'listing': listing}, 'message': 'Offline demo listing loaded'};
    }
    final res = await http.get(Uri.parse('$baseUrl/listings/$id'), headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> createListing(Map<String, dynamic> data, List<File> images) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      final isFood = data['category'] == 'free_food' || data['category'] == 'for_sale';
      final listing = {
        '_id': 'demo-created-${DateTime.now().millisecondsSinceEpoch}',
        'title': data['title'] ?? 'New demo listing',
        'description': data['description'] ?? '',
        'category': data['category'] ?? 'free_food',
        'foodType': data['foodType'],
        'images': images.map(_localImageUrl).toList(),
        'tags': _decodeStringList(data['tags']),
        'quantity': int.tryParse('${data['quantity'] ?? 1}') ?? 1,
        'unit': data['unit'] ?? 'item',
        'price': double.tryParse('${data['price'] ?? 0}') ?? 0,
        'expiresAt': data['expiresAt'],
        'isAvailable': true,
        'owner': _demoUser,
        'location': {
          'type': 'Point',
          'coordinates': [
            double.tryParse('${data['lng'] ?? 106.8456}') ?? 106.8456,
            double.tryParse('${data['lat'] ?? -6.2088}') ?? -6.2088,
          ],
          'address': data['address'] ?? 'Demo location',
        },
        'distance': 0,
        'dietaryInfo': _decodeStringList(data['dietaryInfo']),
        'allergens': _decodeStringList(data['allergens']),
        'viewCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _demoListings.insert(0, listing);
      final stats = Map<String, dynamic>.from((_demoUser['stats'] as Map?) ?? {});
      stats['totalShared'] = (stats['totalShared'] ?? 0) + 1;
      if (isFood) stats['mealsaved'] = (stats['mealsaved'] ?? 0) + (listing['quantity'] as int);
      _demoUser['stats'] = stats;
      await _saveDemoState();
      return {'success': true, 'data': {'listing': listing}, 'message': 'Demo listing created locally'};
    }
    final token = await getToken();
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/listings'));
    req.headers['Authorization'] = 'Bearer $token';
    data.forEach((k, v) { if (v != null) req.fields[k] = v.toString(); });
    for (final img in images) {
      req.files.add(await http.MultipartFile.fromPath('images', img.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> deleteListing(String id) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      _demoListings.removeWhere((item) => item['_id'] == id || item['id'] == id);
      await _saveDemoState();
      return {'success': true, 'data': {'deletedId': id}, 'message': 'Offline demo listing deleted'};
    }
    final res = await http.delete(Uri.parse('$baseUrl/listings/$id'), headers: await _headers());
    return _handle(res);
  }

  // ── ML ────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRecommendations({
    String? listingId, String? title, List<String>? tags,
    String? category, String? description,
  }) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      final keywords = '${title ?? ''} ${(tags ?? []).join(' ')} ${description ?? ''}'.toLowerCase();
      final isBanana = keywords.contains('banana');
      final isRice = keywords.contains('rice') || keywords.contains('nasi');
      final baseIdeas = isBanana
          ? [
              {'title': 'Banana Pancakes', 'difficulty': 'Easy', 'time': '15 min'},
              {'title': 'Banana Bread Toast', 'difficulty': 'Easy', 'time': '12 min'},
            ]
          : isRice
              ? [
                  {'title': 'Quick Fried Rice', 'difficulty': 'Easy', 'time': '15 min'},
                  {'title': 'Warm Rice Bowl', 'difficulty': 'Easy', 'time': '10 min'},
                ]
              : [
                  {'title': 'Simple Stir-fry', 'difficulty': 'Easy', 'time': '20 min'},
                  {'title': 'Warm Sharing Soup', 'difficulty': 'Easy', 'time': '25 min'},
                ];
      return {
        'success': true,
        'data': {
          'recipes': baseIdeas.map((e) => e['title']).toList(),
          'cookingIdeas': baseIdeas,
          'similarListings': _demoListings.where((item) => item['_id'] != listingId).take(6).toList(),
          'tips': ['Check freshness, package it cleanly, and confirm pickup time before sharing.'],
        },
        'message': 'Offline demo recommendations loaded',
      };
    }
    final res = await http.post(Uri.parse('$baseUrl/ml/recommend'),
        headers: await _headers(),
        body: jsonEncode({'listingId': listingId, 'title': title, 'tags': tags,
            'category': category, 'description': description}));
    return _handle(res);
  }

  // ── MAPS ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getNearbyListings(double lat, double lng, {double radius = 20000}) async {
    if (await _isDemoMode()) return _demoListingsResponse();
    final res = await http.get(
        Uri.parse('$baseUrl/maps/nearby?lat=$lat&lng=$lng&radius=$radius'),
        headers: await _headers());
    return _handle(res);
  }

  // ── MESSAGES ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getConversations() async {
    if (await _isDemoMode()) return {'success': true, 'data': {'conversations': []}, 'message': 'Offline demo conversations'};
    final res = await http.get(Uri.parse('$baseUrl/messages/conversations'), headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getMessages(String convId) async {
    if (await _isDemoMode()) return {'success': true, 'data': {'messages': []}, 'message': 'Offline demo messages'};
    final res = await http.get(Uri.parse('$baseUrl/messages/conversations/$convId'), headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> sendMessage(String recipientId, String content, {String? listingId}) async {
    if (await _isDemoMode()) return {'success': true, 'data': {'message': {'content': content}}, 'message': 'Offline demo message saved'};
    final res = await http.post(Uri.parse('$baseUrl/messages'),
        headers: await _headers(),
        body: jsonEncode({'recipientId': recipientId, 'content': content, 'listingId': listingId}));
    return _handle(res);
  }

  // ── REQUESTS ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createRequest(String listingId, {String? message, int quantity = 1}) async {
    if (await _isDemoMode()) return {'success': true, 'data': {'request': {'listingId': listingId, 'message': message, 'quantity': quantity}}, 'message': 'Offline demo request created'};
    final res = await http.post(Uri.parse('$baseUrl/requests'),
        headers: await _headers(),
        body: jsonEncode({'listingId': listingId, 'message': message, 'quantity': quantity}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getMyRequests() async {
    if (await _isDemoMode()) return {'success': true, 'data': {'requests': []}, 'message': 'Offline demo requests'};
    final res = await http.get(Uri.parse('$baseUrl/requests/my'), headers: await _headers());
    return _handle(res);
  }

  // ── USER ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data, {File? avatar}) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      _demoUser.addAll(data);
      if (avatar != null) _demoUser['avatar'] = _localImageUrl(avatar);
      for (final item in _demoListings) {
        final owner = item['owner'];
        if (owner is Map && (owner['_id'] == _demoUser['_id'] || owner['id'] == _demoUser['_id'])) {
          item['owner'] = _demoUser;
        }
      }
      await _saveDemoState();
      return {'success': true, 'data': {'user': _demoUser}, 'message': 'Offline demo profile updated'};
    }
    final token = await getToken();
    final req = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/profile'));
    req.headers['Authorization'] = 'Bearer $token';
    data.forEach((k, v) { if (v != null) req.fields[k] = v.toString(); });
    if (avatar != null) {
      req.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getUser(String userId) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      if (userId == _demoUser['_id']) {
        return {'success': true, 'data': {'user': _demoUser}, 'message': 'Offline demo user loaded'};
      }
      final listing = _demoListings.firstWhere(
        (item) {
          final owner = item['owner'];
          return owner is Map && (owner['_id'] == userId || owner['id'] == userId);
        },
        orElse: () => {'owner': _demoUser},
      );
      return {'success': true, 'data': {'user': listing['owner']}, 'message': 'Offline demo public user loaded'};
    }
    final res = await http.get(Uri.parse('$baseUrl/users/$userId'), headers: await _headers(auth: false));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getUserListings(String userId) async {
    if (await _isDemoMode()) {
      await _loadDemoState();
      final listings = _demoListings.where((item) {
        final owner = item['owner'];
        return owner is Map && (owner['_id'] == userId || owner['id'] == userId);
      }).toList();
      return {'success': true, 'data': {'listings': listings}, 'message': 'Offline demo user listings loaded'};
    }
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/listings'), headers: await _headers(auth: false));
    return _handle(res);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
