// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetSettingsIsarCollection on Isar {
  IsarCollection<SettingsIsar> get settingsIsars => this.collection();
}

const SettingsIsarSchema = CollectionSchema(
  name: r'SettingsIsar',
  id: 5385768829924721998,
  properties: {
    r'frequencyUnit': PropertySchema(
      id: 0,
      name: r'frequencyUnit',
      type: IsarType.byte,
      enumMap: _SettingsIsarfrequencyUnitEnumValueMap,
    ),
    r'frequencyValue': PropertySchema(
      id: 1,
      name: r'frequencyValue',
      type: IsarType.long,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 2,
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
  version: '3.0.5',
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
  writer.writeByte(offsets[0], object.frequencyUnit.index);
  writer.writeLong(offsets[1], object.frequencyValue);
  writer.writeBool(offsets[2], object.notificationsEnabled);
}

SettingsIsar _settingsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsIsar(
    frequencyUnit: _SettingsIsarfrequencyUnitValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        TimeUnit.hours,
    frequencyValue: reader.readLongOrNull(offsets[1]) ?? 1,
    id: id,
    notificationsEnabled: reader.readBoolOrNull(offsets[2]) ?? true,
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
      return (_SettingsIsarfrequencyUnitValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TimeUnit.hours) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsIsarfrequencyUnitEnumValueMap = {
  'seconds': 0,
  'minutes': 1,
  'hours': 2,
  'days': 3,
};
const _SettingsIsarfrequencyUnitValueEnumMap = {
  0: TimeUnit.seconds,
  1: TimeUnit.minutes,
  2: TimeUnit.hours,
  3: TimeUnit.days,
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
      frequencyUnitEqualTo(TimeUnit value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyUnitGreaterThan(
    TimeUnit value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequencyUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyUnitLessThan(
    TimeUnit value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequencyUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyUnitBetween(
    TimeUnit lower,
    TimeUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequencyUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequencyValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequencyValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      frequencyValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequencyValue',
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
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByFrequencyUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyUnit', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByFrequencyUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyUnit', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByFrequencyValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyValue', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByFrequencyValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyValue', Sort.desc);
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
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByFrequencyUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyUnit', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByFrequencyUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyUnit', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByFrequencyValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyValue', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByFrequencyValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyValue', Sort.desc);
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
  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct>
      distinctByFrequencyUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequencyUnit');
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct>
      distinctByFrequencyValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequencyValue');
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

  QueryBuilder<SettingsIsar, TimeUnit, QQueryOperations>
      frequencyUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequencyUnit');
    });
  }

  QueryBuilder<SettingsIsar, int, QQueryOperations> frequencyValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequencyValue');
    });
  }

  QueryBuilder<SettingsIsar, bool, QQueryOperations>
      notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }
}
