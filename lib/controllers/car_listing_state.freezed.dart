// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_listing_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CarListingState {
  List<CarListing> get listings => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CarListingStateCopyWith<CarListingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarListingStateCopyWith<$Res> {
  factory $CarListingStateCopyWith(
          CarListingState value, $Res Function(CarListingState) then) =
      _$CarListingStateCopyWithImpl<$Res, CarListingState>;
  @useResult
  $Res call({List<CarListing> listings, bool isLoading, String? error});
}

/// @nodoc
class _$CarListingStateCopyWithImpl<$Res, $Val extends CarListingState>
    implements $CarListingStateCopyWith<$Res> {
  _$CarListingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listings = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      listings: null == listings
          ? _value.listings
          : listings // ignore: cast_nullable_to_non_nullable
              as List<CarListing>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarListingStateImplCopyWith<$Res>
    implements $CarListingStateCopyWith<$Res> {
  factory _$$CarListingStateImplCopyWith(_$CarListingStateImpl value,
          $Res Function(_$CarListingStateImpl) then) =
      __$$CarListingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CarListing> listings, bool isLoading, String? error});
}

/// @nodoc
class __$$CarListingStateImplCopyWithImpl<$Res>
    extends _$CarListingStateCopyWithImpl<$Res, _$CarListingStateImpl>
    implements _$$CarListingStateImplCopyWith<$Res> {
  __$$CarListingStateImplCopyWithImpl(
      _$CarListingStateImpl _value, $Res Function(_$CarListingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listings = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$CarListingStateImpl(
      listings: null == listings
          ? _value._listings
          : listings // ignore: cast_nullable_to_non_nullable
              as List<CarListing>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CarListingStateImpl implements _CarListingState {
  const _$CarListingStateImpl(
      {final List<CarListing> listings = const [],
      this.isLoading = true,
      this.error})
      : _listings = listings;

  final List<CarListing> _listings;
  @override
  @JsonKey()
  List<CarListing> get listings {
    if (_listings is EqualUnmodifiableListView) return _listings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listings);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'CarListingState(listings: $listings, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarListingStateImpl &&
            const DeepCollectionEquality().equals(other._listings, _listings) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_listings), isLoading, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CarListingStateImplCopyWith<_$CarListingStateImpl> get copyWith =>
      __$$CarListingStateImplCopyWithImpl<_$CarListingStateImpl>(
          this, _$identity);
}

abstract class _CarListingState implements CarListingState {
  const factory _CarListingState(
      {final List<CarListing> listings,
      final bool isLoading,
      final String? error}) = _$CarListingStateImpl;

  @override
  List<CarListing> get listings;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$CarListingStateImplCopyWith<_$CarListingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
