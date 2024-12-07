// car_listing_provider.dart
import 'package:car_web_scrapepr/controllers/car_listing_state.dart';
import 'package:car_web_scrapepr/repo/car_listing_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_listing_provider.g.dart';

@riverpod
class CarListingNotifier extends _$CarListingNotifier {
  late final CarListingRepository _repository = CarListingRepository();

  @override
  CarListingState build() => const CarListingState();

  Future<void> fetchListings({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final listings = await _repository.fetchCarListings(forceRefresh: forceRefresh);
      state = state.copyWith(
        listings: listings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
