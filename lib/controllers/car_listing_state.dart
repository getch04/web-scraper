// car_listing_state.dart
import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_listing_state.freezed.dart';

@freezed
class CarListingState with _$CarListingState {
  const factory CarListingState({
    @Default([]) List<CarListing> listings,
    @Default(true) bool isLoading,
    String? error,
  }) = _CarListingState;
}
