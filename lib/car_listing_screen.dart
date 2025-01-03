// car_listing_page.dart
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_web_scrapepr/core/theme.dart';
import 'package:car_web_scrapepr/core/transitions.dart';
import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/providers/car_listing_provider.dart';
import 'package:car_web_scrapepr/providers/search_provider.dart';
import 'package:car_web_scrapepr/screens/paywall_page.dart';
import 'package:car_web_scrapepr/screens/settings_page.dart';
import 'package:car_web_scrapepr/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:url_launcher/url_launcher.dart';

// car_listing_page.dart
final displayCountProvider = StateProvider<(int, int)>((ref) => (0, 0));

class CarListingPage extends HookConsumerWidget {
  const CarListingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(carListingNotifierProvider);
    final searchState = ref.watch(searchProvider);
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();

    // Add paging controller hook here
    final pagingController = useMemoized(
      () => PagingController<int, CarListing>(firstPageKey: 0),
      [],
    );

    useEffect(() {
      void fetchPage(int pageKey) async {
        try {
          final newItems = await ref
              .read(carListingNotifierProvider.notifier)
              .fetchPage(pageKey);

          final isLastPage = newItems.length < CarListingNotifier.pageSize;
          if (isLastPage) {
            pagingController.appendLastPage(newItems);
          } else {
            final nextPageKey = pageKey + 1;
            pagingController.appendPage(newItems, nextPageKey);
          }
        } catch (error) {
          pagingController.error = error;
        }
      }

      pagingController.addPageRequestListener(fetchPage);
      return () => pagingController.dispose();
    }, [pagingController]);

    // Add this useEffect to refresh pagingController when total changes
    useEffect(() {
      final subscription = ref
          .read(carListingNotifierProvider.notifier)
          .repository
          .watchTotalListings()
          .listen((total) {
        if (total > (pagingController.itemList?.length ?? 0)) {
          pagingController.refresh();
        }
      });

      return subscription.cancel;
    }, []);

    // Handle navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final showNewestFirst = args?['showNewestFirst'] as bool? ?? false;
    final timestamp = args?['timestamp'] as int? ?? 0;

    // If coming from notification with showNewestFirst, update sorting preference
    useEffect(() {
      if (showNewestFirst && timestamp > 0) {
        Future.microtask(() => ref
            .read(carListingNotifierProvider.notifier)
            .setSortingPreference(showNewestFirst: true, timestamp: timestamp));
      }
      return null;
    }, []);

    // Add this useEffect to update the count
    useEffect(() {
      void updateCount() {
        final current = pagingController.itemList?.length ?? 0;
        ref
            .read(carListingNotifierProvider.notifier)
            .repository
            .getTotalListings()
            .then((total) {
          ref.read(displayCountProvider.notifier).state = (current, total);
        });
      }

      // Update count when items change
      pagingController.addListener(updateCount);
      // Initial count
      updateCount();

      return () => pagingController.removeListener(updateCount);
    }, [pagingController]);

    return StreamBuilder<bool>(
      stream: TrialService.watchShouldShowPaywall(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return const PaywallPage();
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: searchState.isSearching
                  ? _buildSearchField(
                      context,
                      ref,
                      searchController,
                      focusNode,
                      state.listings,
                    )
                  : ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Premium Cars',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surfaceColor.withOpacity(0.9),
                    AppTheme.surfaceColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(
                    PageTransitions.scaleTransition(const SettingsPage()),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.settings,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient.scale(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: AppTheme.textLight,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Consumer(
                      builder: (context, ref, _) {
                        final (current, total) =
                            ref.watch(displayCountProvider);
                        return Text(
                          '$current/$total',
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.surfaceColor.withOpacity(0.9),
                      AppTheme.surfaceColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (searchState.isSearching) {
                        searchController.clear();
                        ref.read(searchProvider.notifier).clearSearch();
                        focusNode.unfocus();
                      }
                      ref
                          .read(searchProvider.notifier)
                          .setSearching(!searchState.isSearching);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        searchState.isSearching ? Icons.close : Icons.search,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: state.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const CircularProgressIndicator(
                          color: AppTheme.textLight,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : state.error != null
                  ? _buildErrorWidget(state.error!, ref)
                  : _buildListView(
                      pagingController, searchState.isSearching, ref),
        );
      },
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
    FocusNode focusNode,
    List<CarListing> listings,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceColor.withOpacity(0.9),
            AppTheme.surfaceColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          hintText: 'Search cars...',
          hintStyle: TextStyle(
            color: AppTheme.textLight.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textLight.withOpacity(0.5),
          ),
        ),
        onChanged: (value) {
          ref.read(searchProvider.notifier).setQuery(
                value,
                ref.read(carListingNotifierProvider).listings,
              );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: AppTheme.textLight.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => ref
                  .read(carListingNotifierProvider.notifier)
                  .fetchCarListingsFromDb(),
              icon: const Icon(Icons.refresh, color: AppTheme.textLight),
              label: const Text(
                'Try Again',
                style: TextStyle(color: AppTheme.textLight),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    PagingController<int, CarListing> pagingController,
    bool isSearching,
    WidgetRef ref,
  ) {
    final searchState = ref.watch(searchProvider);

    // If searching, use filtered list instead of paged list
    if (isSearching && searchState.query.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: searchState.searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            CarListingCard(car: searchState.searchResults[index]),
      );
    }

    // Otherwise use paged list
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => pagingController.refresh()),
      child: PagedListView<int, CarListing>.separated(
        pagingController: pagingController,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        builderDelegate: PagedChildBuilderDelegate<CarListing>(
          itemBuilder: (context, car, index) => CarListingCard(car: car),
          firstPageErrorIndicatorBuilder: (_) => _buildErrorWidget(
            pagingController.error.toString(),
            ref,
          ),
          noItemsFoundIndicatorBuilder: (_) =>
              _buildEmptyState(isSearching, ref),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              isSearching ? 'No Results Found' : 'No Cars Found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? 'Try different keywords or filters'
                : 'Please add filters to start searching for cars.\nYou can set your preferences in the settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textLight.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (!isSearching)
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => ref
                    .read(carListingNotifierProvider.notifier)
                    .fetchCarListingsFromDb(),
                icon: const Icon(Icons.refresh, color: AppTheme.textLight),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CarListingCard extends ConsumerWidget {
  final CarListing car;

  const CarListingCard({super.key, required this.car});

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
            ),
            title: const Text(
              'Delete Listing',
              style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this car listing?',
              style: TextStyle(color: AppTheme.textLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.7),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _getTimeAgoText(DateTime dateTime) {
    //show only date
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(car.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) {
        ref.read(carListingNotifierProvider.notifier).deleteCar(car);
      },
      background: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageTransitions.scaleTransition(CarDetailPage(car: car)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceColor,
                AppTheme.surfaceColor.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.backgroundColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Image with Gradient Overlay
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          car.images.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: car.images.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      // opacity: 0.3,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient:
                                          AppTheme.primaryGradient.scale(0.3),
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color: AppTheme.primaryBlue,
                                      size: 40,
                                    ),
                                  ),
                                ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Car Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppTheme.textLight.withOpacity(0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSpecChip(car.year),
                              _buildDot(),
                              _buildSpecChip(car.price),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient.scale(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.local_gas_station,
                                  size: 14,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  car.seller,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textLight.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getTimeAgoText(car.lastUpdated),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Action Buttons
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (await _showDeleteConfirmation(context)) {
                          ref
                              .read(carListingNotifierProvider.notifier)
                              .deleteCar(car);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: AppTheme.textLight,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        try {
                          launchUrl(
                            Uri.parse(
                                'https://www.nettiauto.com${car.detailPage}'),
                          );
                        } catch (e) {
                          debugPrint('Failed to launch URL: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.open_in_new,
                              color: AppTheme.textLight,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'View',
                              style: TextStyle(
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Location Tag
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppTheme.textLight.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      car.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: AppTheme.textLight.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: AppTheme.textLight.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}

class CarDetailPage extends ConsumerWidget {
  final CarListing car;

  const CarDetailPage({super.key, required this.car});

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
            ),
            title: const Text(
              'Delete Listing',
              style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this car listing?',
              style: TextStyle(color: AppTheme.textLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.7),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surfaceColor.withOpacity(0.9),
                      AppTheme.surfaceColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageTransitions.scaleTransition(const CarListingPage()),
                        (route) => false,
                      );
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.surfaceColor.withOpacity(0.9),
                        AppTheme.surfaceColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        if (await _showDeleteConfirmation(context)) {
                          ref
                              .read(carListingNotifierProvider.notifier)
                              .deleteCar(car);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  car.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: car.images.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: car.images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient.scale(0.3),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient.scale(0.3),
                                ),
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 64,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient.scale(0.3),
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            size: 64,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                  // Gradient overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.surfaceColor,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            car.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            RegExp(r'.*?[€$£]').firstMatch(car.price)?[0] ??
                                car.price,
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSpecificationCard(),
                    const SizedBox(height: 24),
                    _buildLocationCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceColor,
            AppTheme.surfaceColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecRow(Icons.calendar_today, 'Year', car.year),
          _buildSpecRow(Icons.speed, 'Mileage', car.mileage),
          _buildSpecRow(Icons.local_gas_station, 'Fuel Type', car.fuel),
          _buildSpecRow(Icons.settings, 'Transmission', car.transmission),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceColor,
            AppTheme.surfaceColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: const Text(
              'Location & Seller',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecRow(Icons.location_on, 'Location', car.location),
          _buildSpecRow(Icons.store, 'Seller', car.seller),
        ],
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
