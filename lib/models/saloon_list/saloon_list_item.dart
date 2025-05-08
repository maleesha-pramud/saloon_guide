import 'package:uuid/uuid.dart';

final String uuid = Uuid().v4();

class SaloonListItem {
  String id;
  String name;
  String address;
  double rating;
  int totalReviews;

  SaloonListItem({
    required this.name,
    required this.address,
    required this.rating,
    required this.totalReviews,
  }) : id = Uuid().v4();
}
