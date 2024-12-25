// car_listing_provider.dart
import 'package:car_web_scrapepr/controllers/car_listing_state.dart';
import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/repo/car_listing_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_listing_provider.g.dart';

@riverpod
class CarListingNotifier extends _$CarListingNotifier {
  late final CarListingRepository _repository = CarListingRepository();

  @override
  CarListingState build() {
    _repository.watchCarListings().listen((listings) {
      state = state.copyWith(
        listings: listings,
        isLoading: false,
      );
    });

    return const CarListingState();
  }

  Future<void> fetchCarListingsFromDb() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final listings = await _repository.fetchCarListingsFromDb();
      state = state.copyWith(
        listings: listings,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  //fetch from remote
  Future<List<CarListing>> fetchFromRemote(
      [final FilterIsar? searchValue]) async {
    return await _repository.fetchFromNetwork(searchValue);
  }
}
