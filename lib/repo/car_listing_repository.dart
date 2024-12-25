// car_listing_repository.dart
import 'dart:convert' show json;

import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';

class CarListingRepository {
  static const cacheValidityDuration = Duration(minutes: 15);
  final _isar = DatabaseService.instance;

  Future<void> invalidateCache() async {
    await _isar.writeTxn(() async {
      await _isar.carListingIsars.clear();
    });
  }

  Future<List<CarListing>> fetchCarListingsFromDb() async {
    final cars =
        await _isar.carListingIsars.where().sortByLastUpdated().findAll();

    return cars.map((e) => e.toCarListing()).toList();
  }

  Future<List<CarListing>> fetchFromNetwork(
      [final FilterIsar? searchValue]) async {
    final activeFilter = searchValue ?? await getActiveFilter();
    final hakuValue = activeFilter?.hakuValue;

    final url =
        'https://www.nettiauto.com/hakutulokset?haku=${hakuValue ?? ''}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch car listings');
    }

    final document = html.parse(response.body);
    final listings = document.querySelectorAll('.swiper-slider-custom-on-card');

    return listings.map((listing) {
      // Extract and parse the data-datalayer attribute
      final dataLayerStr = listing.attributes['data-datalayer'];
      Map<String, dynamic> dataLayer = {};

      if (dataLayerStr != null) {
        try {
          // Remove HTML entities and parse JSON
          final decodedStr = dataLayerStr
              .replaceAll('&quot;', '"')
              .replaceAll('\\u00f6', 'ö')
              .replaceAll('\\u00e4', 'ä');
          dataLayer = json.decode(decodedStr);
        } catch (e) {
          debugPrint('Failed to parse data-datalayer: $e');
        }
      }

      return CarListing(
        title: dataLayer['item_name'] ?? 'Unknown',
        filter: activeFilter?.hakuValue ?? 'Unknown',
        year: dataLayer['item_year_model']?.toString() ?? '',
        mileage: dataLayer['item_mileage']?.toString() ?? '',
        price: dataLayer['item_vehicle_price']?.toString() ?? 'N/A',
        location: dataLayer['item_list_location'] ?? 'Unknown',
        seller: dataLayer['item_seller'] ?? 'Unknown',
        detailPage: listing
                .querySelector('a.product-card-link__tricky-link')
                ?.attributes['href'] ??
            '',
        images: listing
            .querySelectorAll('.swiper-slide img')
            .map((img) => img.attributes['src'] ?? '')
            .toList(),
        fuel: dataLayer['item_fuel'] ?? 'Unknown',
        transmission: dataLayer['item_transmission'] ?? 'Unknown',
      );
    }).toList();
  }

  Future<FilterIsar?> getActiveFilter() async {
    return await _isar.filterIsars
        .where()
        .filter()
        .isActiveEqualTo(true)
        .findFirst();
  }

  Stream<List<CarListing>> watchCarListings() {
    return _isar.carListingIsars
        .where()
        .sortByLastUpdated()
        .watch(fireImmediately: true)
        .map((listings) => listings.map((e) => e.toCarListing()).toList());
  }
}
