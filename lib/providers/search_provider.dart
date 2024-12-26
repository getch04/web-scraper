import 'dart:async';

import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchState {
  final String query;
  final List<CarListing> searchResults;
  final bool isSearching;

  SearchState({
    this.query = '',
    this.searchResults = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<CarListing>? searchResults,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState()) {
    _debounceTimer = Timer(Duration.zero, () {});
  }

  late Timer _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  void setQuery(String query, List<CarListing> listings) {
    state = state.copyWith(query: query);
    _debounceTimer.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      final results = filterListings(listings);
      state = state.copyWith(searchResults: results);
    });
  }

  void setSearching(bool isSearching) {
    state = state.copyWith(isSearching: isSearching);
  }

  void clearSearch() {
    _debounceTimer.cancel();
    state = SearchState();
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    super.dispose();
  }

  List<CarListing> filterListings(List<CarListing> listings) {
    if (state.query.isEmpty) return [];

    final query = state.query.toLowerCase();
    return listings.where((car) {
      return car.title.toLowerCase().contains(query) ||
          car.location.toLowerCase().contains(query) ||
          car.seller.toLowerCase().contains(query) ||
          car.year.toLowerCase().contains(query) ||
          car.fuel.toLowerCase().contains(query) ||
          car.transmission.toLowerCase().contains(query) ||
          car.price.toLowerCase().contains(query);
    }).toList();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
