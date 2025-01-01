// car_listing_repository.dart
import 'dart:convert' show json;

import 'package:car_web_scrapepr/models/car_listing_isar.dart';
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
      await _isar.carListings.clear();
    });
  }

  Future<List<CarListing>> fetchCarListingsFromDb() async {
    final cars =
        await _isar.carListings.where().sortByLastUpdatedDesc().findAll();

    return cars.toList();
  }

  Future<DateTime?> _fetchCarUpdateTime(String detailPage) async {
    try {
      final res =
          await http.get(Uri.parse('https://www.nettiauto.com$detailPage'));
      if (res.statusCode != 200) return null;

      final document = html.parse(res.body);

      // Look for the meta tag with update time first
      final metaTag =
          document.querySelector('meta[property="article:modified_time"]');
      if (metaTag != null) {
        final isoDate = metaTag.attributes['content'];
        if (isoDate != null) {
          return DateTime.parse(isoDate);
        }
      }

      // Fallback to visible date if meta tag not found
      final dateSpan =
          document.querySelector('.details-page-header__item_date');
      if (dateSpan == null) return null;

      final dateText = dateSpan.text;
      // Extract both date and time if available
      // Format could be like "Päivitetty 27.12.2024 15:30"
      final dateTimeParts = dateText.replaceAll('Päivitetty ', '').split(' ');
      if (dateTimeParts.isEmpty) return null;

      final dateParts = dateTimeParts[0].split('.');
      if (dateParts.length != 3) return null;

      final time =
          dateTimeParts.length > 1 ? dateTimeParts[1].split(':') : ['0', '0'];

      return DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(time[0]), // hour
        int.parse(time[1]), // minute
      );
    } catch (e) {
      debugPrint('Failed to fetch update time: $e');
      return null;
    }
  }

  Future<List<CarListing>> fetchFromNetwork(
      [final FilterIsar? searchValue]) async {
    final activeFilter = searchValue ?? await getActiveFilter();
    final hakuValue = activeFilter?.hakuValue;

    final url =
        'https://www.nettiauto.com/hakutulokset?haku=${hakuValue ?? ''}&sortCol=dateCreated&ord=desc&latest=new';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch car listings');
    }

    // Get existing listings and find the highest order index
    final existingListings = await DatabaseService.getExistingListings();
    final existingUrls = existingListings.map((e) => e.detailPage).toSet();
    final lastOrderIndex = existingListings.isEmpty
        ? 0
        : existingListings
            .map((e) => e.orderIndex)
            .reduce((max, value) => value > max ? value : max);

    var orderIndex = lastOrderIndex + 1; // Start from next available number

    final document = html.parse(res.body);
    final listings = document.querySelectorAll('.swiper-slider-custom-on-card');

    final cars = <CarListing>[];

    for (final listing in listings) {
      final dataLayerStr = listing.attributes['data-datalayer'];
      Map<String, dynamic> dataLayer = {};

      if (dataLayerStr != null) {
        try {
          final decodedStr = dataLayerStr
              .replaceAll('&quot;', '"')
              .replaceAll('\\u00f6', 'ö')
              .replaceAll('\\u00e4', 'ä');
          dataLayer = json.decode(decodedStr);

          final position = dataLayer['position'] as int? ?? orderIndex;
          orderIndex = position;
        } catch (e) {
          debugPrint('Failed to parse data-datalayer: $e');
        }
      }

      final detailPage = listing
              .querySelector('a.product-card-link__tricky-link')
              ?.attributes['href'] ??
          '';

      // Skip fetching details if car already exists
      if (existingUrls.contains(detailPage)) {
        continue;
      }

      final updateTime = await _fetchCarUpdateTime(detailPage);
      if (updateTime == null) continue;

      cars.add(CarListing(
        title: dataLayer['item_name'] ?? 'Unknown',
        filter: activeFilter?.hakuValue ?? 'Unknown',
        year: dataLayer['item_year_model']?.toString() ?? '',
        mileage: dataLayer['item_mileage']?.toString() ?? '',
        price: dataLayer['item_vehicle_price']?.toString() ?? 'N/A',
        location: dataLayer['item_list_location'] ?? 'Unknown',
        seller: dataLayer['item_seller'] ?? 'Unknown',
        detailPage: detailPage,
        images: listing
            .querySelectorAll('.swiper-slide img')
            .map((img) => img.attributes['src'] ?? '')
            .toList(),
        fuel: dataLayer['item_fuel'] ?? 'Unknown',
        transmission: dataLayer['item_transmission'] ?? 'Unknown',
        lastUpdated: updateTime,
        orderIndex: orderIndex++,
      ));
    }

    return cars;
  }

  Future<FilterIsar?> getActiveFilter() async {
    return await _isar.filterIsars
        .where()
        .filter()
        .isActiveEqualTo(true)
        .findFirst();
  }

  Stream<List<CarListing>> watchCarListings() {
    return _isar.carListings
        .where()
        .sortByLastUpdatedDesc()
        .watch(fireImmediately: true);
  }

  Future<List<CarListing>> fetchPagedListings({
    required int page,
    required int pageSize,
  }) async {
    final isar = DatabaseService.instance;
    final skip = page * pageSize;

    final listings = await isar.carListings
        .where()
        .sortByOrderIndex()
        .offset(skip)
        .limit(pageSize)
        .findAll();

    return listings;
  }

  Future<int> getTotalListings() async {
    return DatabaseService.instance.carListings.count();
  }

  Stream<int> watchTotalListings() {
    return DatabaseService.instance.carListings
        .where()
        .sortByLastUpdatedDesc()
        .watch(fireImmediately: true)
        .map((event) => event.length);
  }
}
