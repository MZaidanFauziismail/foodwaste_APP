import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class ApiService {
  // Android emulator: 10.0.2.2
  // Physical device: use --dart-define API_BASE_URL.
  static const String baseUrl = ApiConfig.apiBaseUrl;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static String? _token;

  // Offline demo mode.
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
          'description':
              'Extra rice box from lunch event. Still fresh and ready to pick up.',
          'category': 'free_food',
          'foodType': 'meal',
          'images': <String>[],
          'tags': ['rice', 'lunch', 'halal'],
          'quantity': 3,
          'unit': 'box',
          'price': 0,
          'expiresAt':
              DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
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
          'createdAt': DateTime.now()
              .subtract(const Duration(minutes: 35))
              .toIso8601String(),
        },
        {
          '_id': 'demo-listing-2',
          'title': 'Banana Cake Slices',
          'description':
              'Homemade banana cake, soft texture, available in several slices.',
          'category': 'for_sale',
          'foodType': 'snack',
          'images': <String>[],
          'tags': ['cake', 'banana', 'snack'],
          'quantity': 6,
          'unit': 'slice',
          'price': 8000,
          'expiresAt':
              DateTime.now().add(const Duration(days: 1)).toIso8601String(),
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
          'createdAt': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
        {
          '_id': 'demo-listing-3',
          'title': 'Clean Food Containers',
          'description':
              'Reusable food containers in good condition. Can be borrowed for events.',
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
          'createdAt': DateTime.now()
              .subtract(const Duration(hours: 5))
              .toIso8601String(),
        },
      ];

  static Future<bool> _isDemoMode() async {
    return (await getToken()) == demoToken;
  }

  static Future<void> _loadDemoState() async {
    if (_demoStateLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('demo_user');
      final listingsRaw = prefs.getString('demo_listings');

      if (userRaw != null && userRaw.isNotEmpty) {
        _demoUser = Map<String, dynamic>.from(
          jsonDecode(userRaw) as Map,
        );
      }

      if (listingsRaw != null && listingsRaw.isNotEmpty) {
        _demoListingsCache = (jsonDecode(listingsRaw) as List)
            .map(
              (item) => Map<String, dynamic>.from(item as Map),
            )
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

      await prefs.setString(
        'demo_user',
        jsonEncode(_demoUser),
      );

      await prefs.setString(
        'demo_listings',
        jsonEncode(_demoListings),
      );
    } catch (_) {
      // Demo data persistence failure should not crash the application.
    }
  }

  static List<String> _decodeStringList(dynamic value) {
    if (value == null) {
      return <String>[];
    }

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty) {
        return <String>[];
      }

      try {
        final decoded = jsonDecode(text);

        if (decoded is List) {
          return decoded
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList();
        }
      } catch (_) {
        // Continue with comma-separated parsing.
      }

      return text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  static String _localImageUrl(File file) {
    return 'file://${file.path}';
  }

  /// Membuat multipart file dengan MIME type gambar yang benar.
  ///
  /// Android terkadang mengirim file image picker sebagai
  /// application/octet-stream. Helper ini mendeteksi MIME type dari
  /// ekstensi dan header file sehingga backend menerima image/jpeg,
  /// image/png, image/webp, atau format gambar lain yang sesuai.
  static Future<http.MultipartFile> _createImageMultipart({
    required String fieldName,
    required File file,
  }) async {
    if (!await file.exists()) {
      throw ApiException(
        'Image file not found: ${file.path}',
        0,
      );
    }

    final randomAccessFile = await file.open();
    List<int> headerBytes = <int>[];

    try {
      headerBytes = await randomAccessFile.read(16);
    } finally {
      await randomAccessFile.close();
    }

    final detectedMimeType = lookupMimeType(
      file.path,
      headerBytes: headerBytes,
    );

    final mimeType =
        detectedMimeType != null && detectedMimeType.startsWith('image/')
            ? detectedMimeType
            : 'image/jpeg';

    final pathSegments = file.uri.pathSegments;

    String filename = pathSegments.isNotEmpty ? pathSegments.last : 'image.jpg';

    if (!filename.contains('.')) {
      final extension = _extensionFromMimeType(mimeType);
      filename = '$filename$extension';
    }

    return http.MultipartFile.fromPath(
      fieldName,
      file.path,
      filename: filename,
      contentType: MediaType.parse(mimeType),
    );
  }

  static String _extensionFromMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/gif':
        return '.gif';
      case 'image/heic':
        return '.heic';
      case 'image/heif':
        return '.heif';
      case 'image/jpeg':
      default:
        return '.jpg';
    }
  }

  static Future<Map<String, dynamic>> _demoListingsResponse({
    String category = 'all',
    String? search,
  }) async {
    await _loadDemoState();

    var items = List<Map<String, dynamic>>.from(_demoListings);

    if (category != 'all') {
      items = items.where((item) => item['category'] == category).toList();
    }

    final query = search?.trim().toLowerCase() ?? '';

    if (query.isNotEmpty) {
      items = items.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final description =
            (item['description'] ?? '').toString().toLowerCase();
        final tags =
            ((item['tags'] as List?) ?? const []).join(' ').toLowerCase();
        final categoryText = (item['category'] ?? '')
            .toString()
            .replaceAll('_', ' ')
            .toLowerCase();

        return title.contains(query) ||
            description.contains(query) ||
            tags.contains(query) ||
            categoryText.contains(query);
      }).toList();
    }

    items.sort(
      (first, second) {
        final secondDate =
            DateTime.tryParse('${second['createdAt']}') ?? DateTime(2000);

        final firstDate =
            DateTime.tryParse('${first['createdAt']}') ?? DateTime(2000);

        return secondDate.compareTo(firstDate);
      },
    );

    return {
      'success': true,
      'data': {
        'listings': items,
        'total': items.length,
      },
      'message': 'Offline demo listings loaded',
    };
  }

  static Future<String?> getToken() async {
    _token ??= await _storage.read(key: 'auth_token');
    return _token;
  }

  static Future<void> saveToken(String token) async {
    _token = token;

    await _storage.write(
      key: 'auth_token',
      value: token,
    );
  }

  static Future<void> clearToken() async {
    _token = null;

    await _storage.delete(
      key: 'auth_token',
    );
  }

  static Future<Map<String, String>> _headers({
    bool auth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Map<String, dynamic> _handle(http.Response response) {
    dynamic decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        response.body.isNotEmpty
            ? response.body
            : 'Server returned an invalid response',
        response.statusCode,
      );
    }

    final body =
        decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': body['data'],
        'message': body['message'],
      };
    }

    throw ApiException(
      body['message']?.toString() ?? 'Request failed',
      response.statusCode,
    );
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    if (email.trim().toLowerCase() == demoEmail && password == demoPassword) {
      await _loadDemoState();

      return {
        'success': true,
        'data': {
          'token': demoToken,
          'user': _demoUser,
        },
        'message': 'Logged in using offline demo mode',
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> getMe() async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      return {
        'success': true,
        'data': {
          'user': _demoUser,
        },
        'message': 'Offline demo user loaded',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _headers(),
    );

    return _handle(response);
  }

  // ── LISTINGS ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getListings({
    double? lat,
    double? lng,
    double radius = 10000,
    String category = 'all',
    String? search,
    int page = 1,
    String sort = 'distance',
  }) async {
    if (await _isDemoMode()) {
      return _demoListingsResponse(
        category: category,
        search: search,
      );
    }

    final uri = Uri.parse('$baseUrl/listings').replace(
      queryParameters: {
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        'radius': radius.toString(),
        if (category != 'all') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'limit': '50',
        'sort': sort,
      },
    );

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> getListing(
    String id,
  ) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      final listing = _demoListings.firstWhere(
        (item) => item['_id'] == id || item['id'] == id,
        orElse: () => _demoListings.first,
      );

      return {
        'success': true,
        'data': {
          'listing': listing,
        },
        'message': 'Offline demo listing loaded',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/listings/$id'),
      headers: await _headers(),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> createListing(
    Map<String, dynamic> data,
    List<File> images,
  ) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      final isFood =
          data['category'] == 'free_food' || data['category'] == 'for_sale';

      final listing = <String, dynamic>{
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

      final stats = Map<String, dynamic>.from(
        (_demoUser['stats'] as Map?) ?? {},
      );

      stats['totalShared'] = (stats['totalShared'] ?? 0) + 1;

      if (isFood) {
        stats['mealsaved'] =
            (stats['mealsaved'] ?? 0) + (listing['quantity'] as int);
      }

      _demoUser['stats'] = stats;

      await _saveDemoState();

      return {
        'success': true,
        'data': {
          'listing': listing,
        },
        'message': 'Demo listing created locally',
      };
    }

    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw ApiException(
        'Authentication token is missing. Please log in again.',
        401,
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/listings'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    for (final image in images) {
      request.files.add(
        await _createImageMultipart(
          fieldName: 'images',
          file: image,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handle(response);
  }

  static Future<Map<String, dynamic>> deleteListing(
    String id,
  ) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      _demoListings.removeWhere(
        (item) => item['_id'] == id || item['id'] == id,
      );

      await _saveDemoState();

      return {
        'success': true,
        'data': {
          'deletedId': id,
        },
        'message': 'Offline demo listing deleted',
      };
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/listings/$id'),
      headers: await _headers(),
    );

    return _handle(response);
  }

  // ── ML ────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRecommendations({
    String? listingId,
    String? title,
    List<String>? tags,
    String? category,
    String? description,
  }) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      final keywords =
          '${title ?? ''} ${(tags ?? []).join(' ')} ${description ?? ''}'
              .toLowerCase();

      final isBanana = keywords.contains('banana');
      final isRice = keywords.contains('rice') || keywords.contains('nasi');

      final baseIdeas = isBanana
          ? [
              {
                'title': 'Banana Pancakes',
                'difficulty': 'Easy',
                'time': '15 min',
              },
              {
                'title': 'Banana Bread Toast',
                'difficulty': 'Easy',
                'time': '12 min',
              },
            ]
          : isRice
              ? [
                  {
                    'title': 'Quick Fried Rice',
                    'difficulty': 'Easy',
                    'time': '15 min',
                  },
                  {
                    'title': 'Warm Rice Bowl',
                    'difficulty': 'Easy',
                    'time': '10 min',
                  },
                ]
              : [
                  {
                    'title': 'Simple Stir-fry',
                    'difficulty': 'Easy',
                    'time': '20 min',
                  },
                  {
                    'title': 'Warm Sharing Soup',
                    'difficulty': 'Easy',
                    'time': '25 min',
                  },
                ];

      return {
        'success': true,
        'data': {
          'recipes': baseIdeas.map((item) => item['title']).toList(),
          'cookingIdeas': baseIdeas,
          'similarListings': _demoListings
              .where((item) => item['_id'] != listingId)
              .take(6)
              .toList(),
          'tips': [
            'Check freshness, package it cleanly, and confirm pickup time before sharing.',
          ],
        },
        'message': 'Offline demo recommendations loaded',
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/ml/recommend'),
      headers: await _headers(),
      body: jsonEncode({
        'listingId': listingId,
        'title': title,
        'tags': tags,
        'category': category,
        'description': description,
      }),
    );

    return _handle(response);
  }

  // ── MAPS ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getNearbyListings(
    double lat,
    double lng, {
    double radius = 20000,
  }) async {
    if (await _isDemoMode()) {
      return _demoListingsResponse();
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/maps/nearby'
        '?lat=$lat'
        '&lng=$lng'
        '&radius=$radius',
      ),
      headers: await _headers(),
    );

    return _handle(response);
  }

  // ── MESSAGES ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getConversations() async {
    if (await _isDemoMode()) {
      return {
        'success': true,
        'data': {
          'conversations': <dynamic>[],
        },
        'message': 'Offline demo conversations',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations'),
      headers: await _headers(),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> getMessages(
    String conversationId,
  ) async {
    if (await _isDemoMode()) {
      return {
        'success': true,
        'data': {
          'messages': <dynamic>[],
        },
        'message': 'Offline demo messages',
      };
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/messages/conversations/$conversationId',
      ),
      headers: await _headers(),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> sendMessage(
    String recipientId,
    String content, {
    String? listingId,
  }) async {
    if (await _isDemoMode()) {
      return {
        'success': true,
        'data': {
          'message': {
            'content': content,
          },
        },
        'message': 'Offline demo message saved',
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: await _headers(),
      body: jsonEncode({
        'recipientId': recipientId,
        'content': content,
        'listingId': listingId,
      }),
    );

    return _handle(response);
  }

  // ── REQUESTS ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createRequest(
    String listingId, {
    String? message,
    int quantity = 1,
  }) async {
    if (await _isDemoMode()) {
      return {
        'success': true,
        'data': {
          'request': {
            'listingId': listingId,
            'message': message,
            'quantity': quantity,
          },
        },
        'message': 'Offline demo request created',
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/requests'),
      headers: await _headers(),
      body: jsonEncode({
        'listingId': listingId,
        'message': message,
        'quantity': quantity,
      }),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> getMyRequests() async {
    if (await _isDemoMode()) {
      return {
        'success': true,
        'data': {
          'requests': <dynamic>[],
        },
        'message': 'Offline demo requests',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/requests/my'),
      headers: await _headers(),
    );

    return _handle(response);
  }

  // ── USER ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data, {
    File? avatar,
  }) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      _demoUser.addAll(data);

      if (avatar != null) {
        _demoUser['avatar'] = _localImageUrl(avatar);
      }

      for (final item in _demoListings) {
        final owner = item['owner'];

        if (owner is Map &&
            (owner['_id'] == _demoUser['_id'] ||
                owner['id'] == _demoUser['_id'])) {
          item['owner'] = _demoUser;
        }
      }

      await _saveDemoState();

      return {
        'success': true,
        'data': {
          'user': _demoUser,
        },
        'message': 'Offline demo profile updated',
      };
    }

    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw ApiException(
        'Authentication token is missing. Please log in again.',
        401,
      );
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/users/profile'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (avatar != null) {
      request.files.add(
        await _createImageMultipart(
          fieldName: 'avatar',
          file: avatar,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handle(response);
  }

  static Future<Map<String, dynamic>> getUser(
    String userId,
  ) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      if (userId == _demoUser['_id']) {
        return {
          'success': true,
          'data': {
            'user': _demoUser,
          },
          'message': 'Offline demo user loaded',
        };
      }

      final listing = _demoListings.firstWhere(
        (item) {
          final owner = item['owner'];

          return owner is Map &&
              (owner['_id'] == userId || owner['id'] == userId);
        },
        orElse: () => {
          'owner': _demoUser,
        },
      );

      return {
        'success': true,
        'data': {
          'user': listing['owner'],
        },
        'message': 'Offline demo public user loaded',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: await _headers(auth: false),
    );

    return _handle(response);
  }

  static Future<Map<String, dynamic>> getUserListings(
    String userId,
  ) async {
    if (await _isDemoMode()) {
      await _loadDemoState();

      final listings = _demoListings.where((item) {
        final owner = item['owner'];

        return owner is Map &&
            (owner['_id'] == userId || owner['id'] == userId);
      }).toList();

      return {
        'success': true,
        'data': {
          'listings': listings,
        },
        'message': 'Offline demo user listings loaded',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/listings'),
      headers: await _headers(auth: false),
    );

    return _handle(response);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(
    this.message,
    this.statusCode,
  );

  @override
  String toString() => message;
}
