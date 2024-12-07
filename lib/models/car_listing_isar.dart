import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'car_listing_isar.g.dart';

@collection
@JsonSerializable()
class CarListingIsar {
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

  CarListingIsar({
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

  factory CarListingIsar.fromJson(Map<String, dynamic> json) =>
      _$CarListingIsarFromJson(json);

  Map<String, dynamic> toJson() => _$CarListingIsarToJson(this);

  factory CarListingIsar.fromCarListing(CarListing listing) {
    return CarListingIsar(
      title: listing.title,
      year: listing.year,
      mileage: listing.mileage,
      fuel: listing.fuel,
      transmission: listing.transmission,
      price: listing.price,
      location: listing.location,
      seller: listing.seller,
      filter: listing.filter,
      images: listing.images,
      detailPage: listing.detailPage,
      lastUpdated: DateTime.now(),
    );
  }

  CarListing toCarListing() {
    return CarListing(
      title: title,
      year: year,
      mileage: mileage,
      fuel: fuel,
      transmission: transmission,
      price: price,
      location: location,
      seller: seller,
      filter: filter,
      images: images,
      detailPage: detailPage,
    );
  }
}
