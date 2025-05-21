class SaloonListItem {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String? website;
  final String openingTime;
  final String closingTime;
  final int ownerId;
  double rating;
  int totalReviews;

  SaloonListItem({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    this.website,
    required this.openingTime,
    required this.closingTime,
    required this.ownerId,
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  factory SaloonListItem.fromJson(Map<String, dynamic> json) {
    return SaloonListItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      ownerId: json['owner_id'],
      // Rating and totalReviews might come from a different endpoint or property
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
