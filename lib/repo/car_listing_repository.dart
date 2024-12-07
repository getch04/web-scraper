// car_listing_repository.dart
import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/services/database_service.dart';
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

  Future<List<CarListing>> fetchCarListings({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return _fetchAndUpdateCache();
    }

    final cachedListings =
        await _isar.carListingIsars.where().sortByLastUpdated().findAll();

    if (cachedListings.isNotEmpty) {
      final lastUpdated = cachedListings.first.lastUpdated;
      if (DateTime.now().difference(lastUpdated) < cacheValidityDuration) {
        return cachedListings.map((e) => e.toCarListing()).toList();
      }
    }

    return _fetchAndUpdateCache();
  }

  Future<void> _updateListings(List<CarListing> listings) async {
    await _isar.writeTxn(() async {
      for (var listing
          in listings.map((l) => CarListingIsar.fromCarListing(l))) {
        // Check if listing with same detailPage already exists
        final existingListing = await _isar.carListingIsars
            .filter()
            .detailPageEqualTo(listing.detailPage)
            .findFirst();

        if (existingListing != null) {
          // Update existing listing with new data
          listing.id = existingListing.id;
        }

        await _isar.carListingIsars.put(listing);
      }
    });
  }

  Future<List<CarListing>> _fetchAndUpdateCache() async {
    try {
      final listings = await fetchFromNetwork();
      await _updateListings(listings);
      return listings;
    } catch (e) {
      final cachedListings = await _isar.carListingIsars.where().findAll();
      if (cachedListings.isNotEmpty) {
        return cachedListings.map((e) => e.toCarListing()).toList();
      }
      rethrow;
    }
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
    final listings =
        document.querySelectorAll('.swiper-slider-custom-on-card.list-card');

    return listings.map((listing) {
      final infoDetails =
          listing.querySelectorAll('ul.list-card__info_details__vinfo li');

      return CarListing(
        title: listing
                .querySelector('.list-card__info_details__title')
                ?.text
                .trim() ??
            'Unknown',
        filter: activeFilter?.hakuValue ?? 'Unknown',
        year: infoDetails.isNotEmpty ? infoDetails[0].text.trim() : '',
        mileage: infoDetails.length > 1 ? infoDetails[1].text.trim() : '',
        fuel: infoDetails.length > 2 ? infoDetails[2].text.trim() : '',
        transmission: infoDetails.length > 3 ? infoDetails[3].text.trim() : '',
        price: listing
                .querySelector('.list-card__info_price__main')
                ?.text
                .trim() ??
            'N/A',
        location: listing
                .querySelector('.list-card__location-info_address .block-row')
                ?.text
                .trim() ??
            'Unknown',
        seller: listing.querySelector('.block-row')?.text.trim() ?? 'Unknown',
        images: listing
            .querySelectorAll('.swiper-slide img')
            .map((img) => img.attributes['src'] ?? '')
            .toList(),
        detailPage: listing
                .querySelector('a.list-card__tricky-link')
                ?.attributes['href'] ??
            '',
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
