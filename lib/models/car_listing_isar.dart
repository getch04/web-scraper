import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'car_listing_isar.g.dart';

@collection
@JsonSerializable()
class CarListing {
  Id id = Isar.autoIncrement;

  String title;
  String year;
  String mileage;
  String fuel;
  String transmission;
  String price;
  String location;
  String seller;
  String filter;
  List<String> images;
  String detailPage;
  DateTime lastUpdated;

  CarListing({
    required this.title,
    required this.year,
    required this.mileage,
    required this.fuel,
    required this.transmission,
    required this.price,
    required this.location,
    required this.seller,
    required this.filter,
    required this.images,
    required this.detailPage,
    required this.lastUpdated,
  });

  factory CarListing.fromJson(Map<String, dynamic> json) =>
      _$CarListingFromJson(json);

  Map<String, dynamic> toJson() => _$CarListingToJson(this);
}
