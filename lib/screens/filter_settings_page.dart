import 'package:car_web_scrapepr/providers/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/theme.dart';
import '../core/toast_utils.dart';
import '../models/filter_isar.dart';
import '../provider/car_listing_provider.dart';

class FilterSettingsPage extends HookConsumerWidget {
  const FilterSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'My Filters',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
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
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                size: 24,
                color: AppTheme.textLight,
              ),
              onPressed: () => _showAddFilterDialog(context, ref),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: filters.when(
        data: (filterList) => filterList.isEmpty
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient.scale(0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.filter_alt_outlined,
                          size: 72,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'No Filters Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Add your first filter to start tracking',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textLight.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
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
                          onPressed: () => _showAddFilterDialog(context, ref),
                          icon:
                              const Icon(Icons.add, color: AppTheme.textLight),
                          label: const Text(
                            'Add Your First Filter',
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
                              horizontal: 24,
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
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.backgroundColor,
                      AppTheme.surfaceColor.withOpacity(0.3),
                    ],
                  ),
                ),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: filterList.length,
                  itemBuilder: (context, index) {
                    final filter = filterList[index];
                    return Dismissible(
                      key: Key(filter.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.8),
                              Colors.red.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.surfaceColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Confirm Delete',
                              style: TextStyle(
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete this filter?',
                              style: TextStyle(
                                color: AppTheme.textLight.withOpacity(0.9),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
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
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(filtersProvider.notifier)
                                          .deleteFilter(filter.id ?? 0);

                                      await ref
                                          .read(carListingNotifierProvider
                                              .notifier)
                                          .fetchListings(forceRefresh: true);

                                      Navigator.pop(context, true);
                                      ToastUtils.showSuccessToast(
                                        context,
                                        'Filter deleted successfully',
                                      );
                                    } catch (e) {
                                      ToastUtils.showErrorToast(
                                        context,
                                        'Failed to delete filter',
                                      );
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.textLight,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: _buildFilterCard(context, filter, ref),
                    );
                  },
                ),
              ),
        loading: () => Center(
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.textLight,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        error: (error, stack) => Center(
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
                'Error: $error',
                style: const TextStyle(color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(
      BuildContext context, FilterIsar filter, WidgetRef ref) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filter.isActive
              ? AppTheme.primaryBlue.withOpacity(0.2)
              : AppTheme.textLight.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: filter.isActive
                ? AppTheme.primaryBlue.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: filter.isActive
                            ? AppTheme.primaryGradient.scale(0.3)
                            : LinearGradient(
                                colors: [
                                  AppTheme.textLight.withOpacity(0.1),
                                  AppTheme.textLight.withOpacity(0.05),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 20,
                        color: filter.isActive
                            ? AppTheme.primaryBlue
                            : AppTheme.textLight.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        filter.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight.withOpacity(0.9),
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: filter.isActive,
                      activeColor: AppTheme.primaryBlue,
                      activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
                      inactiveThumbColor: AppTheme.textLight.withOpacity(0.3),
                      inactiveTrackColor: AppTheme.textLight.withOpacity(0.1),
                      onChanged: (value) {
                        _toggleFilter(ref, filter.id ?? 0, context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient.scale(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 14,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.hakuValue,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: filter.isActive
                            ? AppTheme.primaryGradient.scale(0.3)
                            : LinearGradient(
                                colors: [
                                  AppTheme.textLight.withOpacity(0.1),
                                  AppTheme.textLight.withOpacity(0.05),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filter.isActive
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textLight.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color: filter.isActive
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textLight.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFilter(
      WidgetRef ref, int id, BuildContext context) async {
    try {
      await ref.read(filtersProvider.notifier).toggleFilter(id);
    } catch (e) {
      ToastUtils.showErrorToast(
        context,
        'Failed to update filter',
      );
    }
  }

  void _showAddFilterDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final hakuController = TextEditingController();

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'New Filter',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: InputDecoration(
                  labelText: 'Filter Name',
                  labelStyle: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.7),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hakuController,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: InputDecoration(
                  labelText: 'Haku Value',
                  labelStyle: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.7),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.textLight.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            hakuController.text.isEmpty) {
                          ToastUtils.showErrorToast(
                            context,
                            'Please fill in all fields',
                          );
                          return;
                        }

                        try {
                          final newFilter = FilterIsar(
                            name: nameController.text,
                            hakuValue: hakuController.text,
                            isActive: true,
                          );

                          await ref
                              .read(filtersProvider.notifier)
                              .addFilter(newFilter);

                          Navigator.pop(context);
                          ToastUtils.showSuccessToast(
                            context,
                            'Filter added successfully',
                          );
                        } catch (e) {
                          ToastUtils.showErrorToast(
                            context,
                            'Failed to add filter: $e',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Filter',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
