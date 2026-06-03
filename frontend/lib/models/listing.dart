class Listing {
  const Listing({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.category,
    required this.status,
    required this.locationText,
    this.ownerName,
    this.description,
    this.condition,
    this.price,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.imageUrl,
    this.availableUntil,
    this.predictedCategory,
    this.safetyScore,
    this.freshnessScore,
    this.impactMeals = 0,
    this.impactWaterLiters = 0,
    this.aiNotes,
    this.isMine = false,
  });

  final int id;
  final int userId;
  final String? ownerName;
  final String title;
  final String? description;
  final String type;
  final String category;
  final String? condition;
  final String status;
  final double? price;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String? imageUrl;
  final DateTime? availableUntil;
  final String? predictedCategory;
  final double? safetyScore;
  final double? freshnessScore;
  final double impactMeals;
  final double impactWaterLiters;
  final String? aiNotes;
  final bool isMine;

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: (json['id'] as num).toInt(),
        userId: (json['user_id'] as num).toInt(),
        ownerName: json['owner_name'],
        title: json['title'] ?? '',
        description: json['description'],
        type: json['type'] ?? 'free',
        category: json['category'] ?? 'food',
        condition: json['condition'],
        status: json['status'] ?? 'available',
        price: (json['price'] as num?)?.toDouble(),
        locationText: json['location_text'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        imageUrl: json['image_url'],
        availableUntil: json['available_until'] == null ? null : DateTime.tryParse(json['available_until'].toString()),
        predictedCategory: json['predicted_category'],
        safetyScore: (json['safety_score'] as num?)?.toDouble(),
        freshnessScore: (json['freshness_score'] as num?)?.toDouble(),
        impactMeals: (json['impact_meals'] as num?)?.toDouble() ?? 0,
        impactWaterLiters: (json['impact_water_liters'] as num?)?.toDouble() ?? 0,
        aiNotes: json['ai_notes'],
        isMine: json['is_mine'] == true,
      );

  String get typeLabel {
    switch (type) {
      case 'sell':
        return 'Sell';
      case 'lend':
        return 'Borrow';
      case 'wanted':
        return 'Wanted';
      case 'forum':
        return 'Forum';
      default:
        return 'Free';
    }
  }

  String get categoryLabel => category == 'food' ? 'Food' : 'Non-food';
}
