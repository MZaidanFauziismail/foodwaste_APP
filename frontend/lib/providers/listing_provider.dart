import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/listing.dart';

class ListingProvider extends ChangeNotifier {
  ListingProvider(this._api);

  final ApiClient _api;
  List<Listing> listings = [];
  bool loading = false;
  String category = 'all';
  String type = 'all';
  String query = '';
  String? error;

  void setToken(String? token) => _api.setToken(token);

  Future<void> fetch({double? lat, double? lng, int radius = 50}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _api.get('/listings', query: {
        'category': category,
        'type': type,
        'q': query,
        'lat': lat,
        'lng': lng,
        'radius': radius,
      });
      listings = (data['listings'] as List).map((x) => Listing.fromJson(Map<String, dynamic>.from(x))).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  Future<Listing> detail(int id) async {
    final data = await _api.get('/listings/$id');
    return Listing.fromJson(Map<String, dynamic>.from(data['listing']));
  }

  Future<Listing> create({
    required String title,
    required String description,
    required String type,
    required String category,
    required String locationText,
    required String latitude,
    required String longitude,
    String? price,
    DateTime? availableUntil,
    String? imageUrl,
  }) async {
    final data = await _api.multipart('/listings', fields: {
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'location_text': locationText,
      'latitude': latitude,
      'longitude': longitude,
      if (price != null && price.isNotEmpty) 'price': price,
      if (availableUntil != null) 'available_until': availableUntil.toIso8601String(),
      if (imageUrl != null && imageUrl.trim().isNotEmpty) 'image_url': imageUrl.trim(),
    });
    final listing = Listing.fromJson(data['listing']);
    listings.insert(0, listing);
    notifyListeners();
    return listing;
  }

  Future<Map<String, dynamic>> predict(String title, String description, String category, String type) async {
    final data = await _api.post('/ml/predict', body: {
      'title': title,
      'description': description,
      'category': category,
      'type': type,
    });
    return Map<String, dynamic>.from(data['ml']);
  }

  Future<void> requestListing(Listing listing, String message) async {
    await _api.post('/listings/${listing.id}/request', body: {'message': message});
    await fetch();
  }
}
