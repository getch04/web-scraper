// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsIsarCollection on Isar {
  IsarCollection<SettingsIsar> get settingsIsars => this.collection();
}

const SettingsIsarSchema = CollectionSchema(
  name: r'SettingsIsar',
  id: 5385768829924721998,
  properties: {
    r'frequency': PropertySchema(
      id: 0,
      name: r'frequency',
      type: IsarType.byte,
      enumMap: _SettingsIsarfrequencyEnumValueMap,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 1,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _settingsIsarEstimateSize,
  serialize: _settingsIsarSerialize,
  deserialize: _settingsIsarDeserialize,
  deserializeProp: _settingsIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsIsarGetId,
  getLinks: _settingsIsarGetLinks,
  attach: _settingsIsarAttach,
  version: '3.1.0+1',
);

int _settingsIsarEstimateSize(
  SettingsIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _settingsIsarSerialize(
  SettingsIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.frequency.index);
  writer.writeBool(offsets[1], object.notificationsEnabled);
}

SettingsIsar _settingsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsIsar(
    frequency:
        _SettingsIsarfrequencyValueEnumMap[reader.readByteOrNull(offsets[0])] ??
            NotificationFrequency.hourly,
    id: id,
    notificationsEnabled: reader.readBoolOrNull(offsets[1]) ?? true,
  );
  return object;
}

P _settingsIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_SettingsIsarfrequencyValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationFrequency.hourly) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsIsarfrequencyEnumValueMap = {
  'minutes15': 0,
  'minutes30': 1,
  'hourly': 2,
  'hours2': 3,
  'hours4': 4,
  'hours8': 5,
  'daily': 6,
};
const _SettingsIsarfrequencyValueEnumMap = {
  0: NotificationFrequency.minutes15,
  1: NotificationFrequency.minutes30,
  2: NotificationFrequency.hourly,
  3: NotificationFrequency.hours2,
  4: NotificationFrequency.hours4,
  5: NotificationFrequency.hours8,
  6: NotificationFrequency.daily,
};

Id _settingsIsarGetId(SettingsIsar object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _settingsIsarGetLinks(SettingsIsar object) {
  return [];
}

void _settingsIsarAttach(
    IsarCollection<dynamic> col, Id id, SettingsIsar object) {
  object.id = id;
}

extension SettingsIsarQueryWhereSort
    on QueryBuilder<SettingsIsar, SettingsIsar, QWhere> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsIsarQueryWhere
    on QueryBuilder<SettingsIsar, SettingsIsar, QWhereClause> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsIsarQueryFilter
    on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyEqualTo(NotificationFrequency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyGreaterThan(
    NotificationFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyLessThan(
    NotificationFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyBetween(
    NotificationFrequency lower,
    NotificationFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationsEnabled',
        value: value,
      ));
    });
  }
}

extension SettingsIsarQueryObject
    on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {}

extension SettingsIsarQueryLinks
    on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {}

extension SettingsIsarQuerySortBy
    on QueryBuilder<SettingsIsar, SettingsIsar, QSortBy> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }
}

extension SettingsIsarQuerySortThenBy
    on QueryBuilder<SettingsIsar, SettingsIsar, QSortThenBy> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }
}

extension SettingsIsarQueryWhereDistinct
    on QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> {
  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> distinctByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency');
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct>
      distinctByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationsEnabled');
    });
  }
}

extension SettingsIsarQueryProperty
    on QueryBuilder<SettingsIsar, SettingsIsar, QQueryProperty> {
  QueryBuilder<SettingsIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsIsar, NotificationFrequency, QQueryOperations>
      frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<SettingsIsar, bool, QQueryOperations>
      notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }
}
