// car_listing_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_web_scrapepr/core/theme.dart';
import 'package:car_web_scrapepr/core/transitions.dart';
import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:car_web_scrapepr/provider/car_listing_provider.dart';
import 'package:car_web_scrapepr/screens/paywall_page.dart';
import 'package:car_web_scrapepr/screens/settings_page.dart';
import 'package:car_web_scrapepr/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// car_listing_page.dart
class CarListingPage extends HookConsumerWidget {
  const CarListingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(carListingNotifierProvider);

    useEffect(() {
      Future.microtask(
          () => ref.read(carListingNotifierProvider.notifier).fetchListings());
      return null;
    }, []);

    return StreamBuilder<bool>(
  stream: TrialService.watchShouldShowPaywall(),
  builder: (context, snapshot) {
    if (snapshot.data == true) {
      return const PaywallPage();
    }


        return Scaffold(
          backgroundColor: AppTheme.lightGreen,
          appBar: AppBar(
            title: const Text(
              'Premium Cars',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryGreen,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightGreen.withOpacity(0.9),
                    AppTheme.lightGreen.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
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
                      // Decorative background circle
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.settings,
                        color: AppTheme.primaryGreen,
                        size: 24,
                      ),
                      // Small dot indicator (optional, for showing active filters)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                )
              : state.error != null
                  ? _buildErrorWidget(state.error!, ref)
                  : _buildListView(state.listings, ref),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.primaryGreen,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(carListingNotifierProvider.notifier).fetchListings(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<CarListing> listings, WidgetRef ref) {
    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      onRefresh: () =>
          ref.read(carListingNotifierProvider.notifier).fetchListings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final car = listings[index];
          return CarListingCard(car: car);
        },
      ),
    );
  }
}

class CarListingCard extends StatelessWidget {
  final CarListing car;

  const CarListingCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageTransitions.scaleTransition(CarDetailPage(car: car)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
                                  color: AppTheme.lightGreen.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: AppTheme.lightGreen.withOpacity(0.3),
                                child: const Icon(
                                  Icons.directions_car,
                                  color: AppTheme.primaryGreen,
                                  size: 40,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSpecChip(car.year),
                            _buildDot(),
                            _buildSpecChip(car.mileage),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_gas_station,
                                size: 14,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              car.fuel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Price Tag
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  car.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // Location Tag
            Positioned(
              bottom: 12,
              right: 12,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    car.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }
}

class CarDetailPage extends StatelessWidget {
  final CarListing car;

  const CarDetailPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Existing image code
                  car.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: car.images.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: car.images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.lightGreen,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.lightGreen,
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 64,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.lightGreen,
                          child: const Icon(
                            Icons.directions_car,
                            size: 64,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                  // Add gradient overlay for better visibility
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
                            color: Colors.black87,
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
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          car.price,
                          style: const TextStyle(
                            color: Colors.white,
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
                  _buildContactButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            _buildSpecRow(Icons.calendar_today, 'Year', car.year),
            _buildSpecRow(Icons.speed, 'Mileage', car.mileage),
            _buildSpecRow(Icons.local_gas_station, 'Fuel Type', car.fuel),
            _buildSpecRow(Icons.settings, 'Transmission', car.transmission),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location & Seller',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            _buildSpecRow(Icons.location_on, 'Location', car.location),
            _buildSpecRow(Icons.store, 'Seller', car.seller),
          ],
        ),
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
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
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

  Widget _buildContactButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Implement contact functionality
          if (car.detailPage.isNotEmpty) {
            // Launch URL
          }
        },
        icon: const Icon(Icons.phone),
        label: const Text('Contact Seller'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
