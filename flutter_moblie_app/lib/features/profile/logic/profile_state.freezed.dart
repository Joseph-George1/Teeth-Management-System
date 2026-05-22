// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileState<T> {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileState<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState<$T>()';
  }
}

/// @nodoc
class $ProfileStateCopyWith<T, $Res> {
  $ProfileStateCopyWith(ProfileState<T> _, $Res Function(ProfileState<T>) __);
}

/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns<T> on ProfileState<T> {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial<T> value)? initial,
    TResult Function(Loading<T> value)? loading,
    TResult Function(Success<T> value)? success,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case Loading() when loading != null:
        return loading(_that);
      case Success() when success != null:
        return success(_that);
      case Error() when error != null:
        return error(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial<T> value) initial,
    required TResult Function(Loading<T> value) loading,
    required TResult Function(Success<T> value) success,
    required TResult Function(Error<T> value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case Loading():
        return loading(_that);
      case Success():
        return success(_that);
      case Error():
        return error(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial<T> value)? initial,
    TResult? Function(Loading<T> value)? loading,
    TResult? Function(Success<T> value)? success,
    TResult? Function(Error<T> value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case Loading() when loading != null:
        return loading(_that);
      case Success() when success != null:
        return success(_that);
      case Error() when error != null:
        return error(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(
            DoctorProfileModel? cachedData,
            List<UniversityModel> universities,
            List<CityModel> cities,
            List<CategoryModel> categories)?
        loading,
    TResult Function(T data, List<UniversityModel> universities,
            List<CityModel> cities, List<CategoryModel> categories)?
        success,
    TResult Function(String error, DioExceptionType? type)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case Loading() when loading != null:
        return loading(_that.cachedData, _that.universities, _that.cities,
            _that.categories);
      case Success() when success != null:
        return success(
            _that.data, _that.universities, _that.cities, _that.categories);
      case Error() when error != null:
        return error(_that.error, _that.type);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(
            DoctorProfileModel? cachedData,
            List<UniversityModel> universities,
            List<CityModel> cities,
            List<CategoryModel> categories)
        loading,
    required TResult Function(T data, List<UniversityModel> universities,
            List<CityModel> cities, List<CategoryModel> categories)
        success,
    required TResult Function(String error, DioExceptionType? type) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case Loading():
        return loading(_that.cachedData, _that.universities, _that.cities,
            _that.categories);
      case Success():
        return success(
            _that.data, _that.universities, _that.cities, _that.categories);
      case Error():
        return error(_that.error, _that.type);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(
            DoctorProfileModel? cachedData,
            List<UniversityModel> universities,
            List<CityModel> cities,
            List<CategoryModel> categories)?
        loading,
    TResult? Function(T data, List<UniversityModel> universities,
            List<CityModel> cities, List<CategoryModel> categories)?
        success,
    TResult? Function(String error, DioExceptionType? type)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case Loading() when loading != null:
        return loading(_that.cachedData, _that.universities, _that.cities,
            _that.categories);
      case Success() when success != null:
        return success(
            _that.data, _that.universities, _that.cities, _that.categories);
      case Error() when error != null:
        return error(_that.error, _that.type);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial<T> implements ProfileState<T> {
  _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState<$T>.initial()';
  }
}

/// @nodoc

class Loading<T> implements ProfileState<T> {
  Loading(
      {this.cachedData,
      final List<UniversityModel> universities = const [],
      final List<CityModel> cities = const [],
      final List<CategoryModel> categories = const []})
      : _universities = universities,
        _cities = cities,
        _categories = categories;

  final DoctorProfileModel? cachedData;
  final List<UniversityModel> _universities;
  @JsonKey()
  List<UniversityModel> get universities {
    if (_universities is EqualUnmodifiableListView) return _universities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_universities);
  }

  final List<CityModel> _cities;
  @JsonKey()
  List<CityModel> get cities {
    if (_cities is EqualUnmodifiableListView) return _cities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cities);
  }

  final List<CategoryModel> _categories;
  @JsonKey()
  List<CategoryModel> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoadingCopyWith<T, Loading<T>> get copyWith =>
      _$LoadingCopyWithImpl<T, Loading<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Loading<T> &&
            (identical(other.cachedData, cachedData) ||
                other.cachedData == cachedData) &&
            const DeepCollectionEquality()
                .equals(other._universities, _universities) &&
            const DeepCollectionEquality().equals(other._cities, _cities) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      cachedData,
      const DeepCollectionEquality().hash(_universities),
      const DeepCollectionEquality().hash(_cities),
      const DeepCollectionEquality().hash(_categories));

  @override
  String toString() {
    return 'ProfileState<$T>.loading(cachedData: $cachedData, universities: $universities, cities: $cities, categories: $categories)';
  }
}

/// @nodoc
abstract mixin class $LoadingCopyWith<T, $Res>
    implements $ProfileStateCopyWith<T, $Res> {
  factory $LoadingCopyWith(Loading<T> value, $Res Function(Loading<T>) _then) =
      _$LoadingCopyWithImpl;
  @useResult
  $Res call(
      {DoctorProfileModel? cachedData,
      List<UniversityModel> universities,
      List<CityModel> cities,
      List<CategoryModel> categories});

  $DoctorProfileModelCopyWith<$Res>? get cachedData;
}

/// @nodoc
class _$LoadingCopyWithImpl<T, $Res> implements $LoadingCopyWith<T, $Res> {
  _$LoadingCopyWithImpl(this._self, this._then);

  final Loading<T> _self;
  final $Res Function(Loading<T>) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? cachedData = freezed,
    Object? universities = null,
    Object? cities = null,
    Object? categories = null,
  }) {
    return _then(Loading<T>(
      cachedData: freezed == cachedData
          ? _self.cachedData
          : cachedData // ignore: cast_nullable_to_non_nullable
              as DoctorProfileModel?,
      universities: null == universities
          ? _self._universities
          : universities // ignore: cast_nullable_to_non_nullable
              as List<UniversityModel>,
      cities: null == cities
          ? _self._cities
          : cities // ignore: cast_nullable_to_non_nullable
              as List<CityModel>,
      categories: null == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategoryModel>,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DoctorProfileModelCopyWith<$Res>? get cachedData {
    if (_self.cachedData == null) {
      return null;
    }

    return $DoctorProfileModelCopyWith<$Res>(_self.cachedData!, (value) {
      return _then(_self.copyWith(cachedData: value));
    });
  }
}

/// @nodoc

class Success<T> implements ProfileState<T> {
  Success(this.data,
      {final List<UniversityModel> universities = const [],
      final List<CityModel> cities = const [],
      final List<CategoryModel> categories = const []})
      : _universities = universities,
        _cities = cities,
        _categories = categories;

  final T data;
  final List<UniversityModel> _universities;
  @JsonKey()
  List<UniversityModel> get universities {
    if (_universities is EqualUnmodifiableListView) return _universities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_universities);
  }

  final List<CityModel> _cities;
  @JsonKey()
  List<CityModel> get cities {
    if (_cities is EqualUnmodifiableListView) return _cities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cities);
  }

  final List<CategoryModel> _categories;
  @JsonKey()
  List<CategoryModel> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SuccessCopyWith<T, Success<T>> get copyWith =>
      _$SuccessCopyWithImpl<T, Success<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Success<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            const DeepCollectionEquality()
                .equals(other._universities, _universities) &&
            const DeepCollectionEquality().equals(other._cities, _cities) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(data),
      const DeepCollectionEquality().hash(_universities),
      const DeepCollectionEquality().hash(_cities),
      const DeepCollectionEquality().hash(_categories));

  @override
  String toString() {
    return 'ProfileState<$T>.success(data: $data, universities: $universities, cities: $cities, categories: $categories)';
  }
}

/// @nodoc
abstract mixin class $SuccessCopyWith<T, $Res>
    implements $ProfileStateCopyWith<T, $Res> {
  factory $SuccessCopyWith(Success<T> value, $Res Function(Success<T>) _then) =
      _$SuccessCopyWithImpl;
  @useResult
  $Res call(
      {T data,
      List<UniversityModel> universities,
      List<CityModel> cities,
      List<CategoryModel> categories});
}

/// @nodoc
class _$SuccessCopyWithImpl<T, $Res> implements $SuccessCopyWith<T, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<T> _self;
  final $Res Function(Success<T>) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
    Object? universities = null,
    Object? cities = null,
    Object? categories = null,
  }) {
    return _then(Success<T>(
      freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
      universities: null == universities
          ? _self._universities
          : universities // ignore: cast_nullable_to_non_nullable
              as List<UniversityModel>,
      cities: null == cities
          ? _self._cities
          : cities // ignore: cast_nullable_to_non_nullable
              as List<CityModel>,
      categories: null == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategoryModel>,
    ));
  }
}

/// @nodoc

class Error<T> implements ProfileState<T> {
  Error({required this.error, required this.type});

  final String error;
  final DioExceptionType? type;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ErrorCopyWith<T, Error<T>> get copyWith =>
      _$ErrorCopyWithImpl<T, Error<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Error<T> &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error, type);

  @override
  String toString() {
    return 'ProfileState<$T>.error(error: $error, type: $type)';
  }
}

/// @nodoc
abstract mixin class $ErrorCopyWith<T, $Res>
    implements $ProfileStateCopyWith<T, $Res> {
  factory $ErrorCopyWith(Error<T> value, $Res Function(Error<T>) _then) =
      _$ErrorCopyWithImpl;
  @useResult
  $Res call({String error, DioExceptionType? type});
}

/// @nodoc
class _$ErrorCopyWithImpl<T, $Res> implements $ErrorCopyWith<T, $Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error<T> _self;
  final $Res Function(Error<T>) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
    Object? type = freezed,
  }) {
    return _then(Error<T>(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as DioExceptionType?,
    ));
  }
}

// dart format on
