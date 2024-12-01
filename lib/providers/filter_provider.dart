import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_service.dart';

part 'filter_provider.g.dart';

@riverpod
class Filters extends _$Filters {
  final _isar = DatabaseService.instance;

  @override
  Stream<List<FilterIsar>> build() {
    return _isar.filterIsars.where().watch(fireImmediately: true);
  }

  Future<void> addFilter(FilterIsar filter) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.filterIsars.put(filter);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> toggleFilter(Id id) async {
    await _isar.writeTxn(() async {
      // Get the filter we want to toggle
      final targetFilter = await _isar.filterIsars.get(id);
      if (targetFilter == null) return;

      // If we're trying to activate this filter
      if (!targetFilter.isActive) {
        // First, deactivate all currently active filters
        final activeFilters =
            await _isar.filterIsars.filter().isActiveEqualTo(true).findAll();

        for (final filter in activeFilters) {
          await _isar.filterIsars.put(
            filter.copyWith(isActive: false),
          );
        }
      }

      // Now toggle the target filter
      await _isar.filterIsars.put(
        targetFilter.copyWith(isActive: !targetFilter.isActive),
      );
    });
  }

  Future<void> deleteFilter(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.filterIsars.delete(id);
    });
  }
}
