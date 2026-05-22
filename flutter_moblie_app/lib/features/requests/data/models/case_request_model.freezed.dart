// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseRequestModel {
  int? get id;
  String get doctorFirstName;
  String get doctorLastName;
  String get doctorPhoneNumber;
  String get doctorCityName;
  String get doctorUniversityName;
  String get categoryName;
  String get description;
  String get dateTime;

  /// Create a copy of CaseRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CaseRequestModelCopyWith<CaseRequestModel> get copyWith =>
      _$CaseRequestModelCopyWithImpl<CaseRequestModel>(
          this as CaseRequestModel, _$identity);

  /// Serializes this CaseRequestModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CaseRequestModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.doctorFirstName, doctorFirstName) ||
                other.doctorFirstName == doctorFirstName) &&
            (identical(other.doctorLastName, doctorLastName) ||
                other.doctorLastName == doctorLastName) &&
            (identical(other.doctorPhoneNumber, doctorPhoneNumber) ||
                other.doctorPhoneNumber == doctorPhoneNumber) &&
            (identical(other.doctorCityName, doctorCityName) ||
                other.doctorCityName == doctorCityName) &&
            (identical(other.doctorUniversityName, doctorUniversityName) ||
                other.doctorUniversityName == doctorUniversityName) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      doctorFirstName,
      doctorLastName,
      doctorPhoneNumber,
      doctorCityName,
      doctorUniversityName,
      categoryName,
      description,
      dateTime);

  @override
  String toString() {
    return 'CaseRequestModel(id: $id, doctorFirstName: $doctorFirstName, doctorLastName: $doctorLastName, doctorPhoneNumber: $doctorPhoneNumber, doctorCityName: $doctorCityName, doctorUniversityName: $doctorUniversityName, categoryName: $categoryName, description: $description, dateTime: $dateTime)';
  }
}

/// @nodoc
abstract mixin class $CaseRequestModelCopyWith<$Res> {
  factory $CaseRequestModelCopyWith(
          CaseRequestModel value, $Res Function(CaseRequestModel) _then) =
      _$CaseRequestModelCopyWithImpl;
  @useResult
  $Res call(
      {int? id,
      String doctorFirstName,
      String doctorLastName,
      String doctorPhoneNumber,
      String doctorCityName,
      String doctorUniversityName,
      String categoryName,
      String description,
      String dateTime});
}

/// @nodoc
class _$CaseRequestModelCopyWithImpl<$Res>
    implements $CaseRequestModelCopyWith<$Res> {
  _$CaseRequestModelCopyWithImpl(this._self, this._then);

  final CaseRequestModel _self;
  final $Res Function(CaseRequestModel) _then;

  /// Create a copy of CaseRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? doctorFirstName = null,
    Object? doctorLastName = null,
    Object? doctorPhoneNumber = null,
    Object? doctorCityName = null,
    Object? doctorUniversityName = null,
    Object? categoryName = null,
    Object? description = null,
    Object? dateTime = null,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      doctorFirstName: null == doctorFirstName
          ? _self.doctorFirstName
          : doctorFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorLastName: null == doctorLastName
          ? _self.doctorLastName
          : doctorLastName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorPhoneNumber: null == doctorPhoneNumber
          ? _self.doctorPhoneNumber
          : doctorPhoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      doctorCityName: null == doctorCityName
          ? _self.doctorCityName
          : doctorCityName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorUniversityName: null == doctorUniversityName
          ? _self.doctorUniversityName
          : doctorUniversityName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _self.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _self.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CaseRequestModel].
extension CaseRequestModelPatterns on CaseRequestModel {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CaseRequestModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CaseRequestModel() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_CaseRequestModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CaseRequestModel():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CaseRequestModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CaseRequestModel() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int? id,
            String doctorFirstName,
            String doctorLastName,
            String doctorPhoneNumber,
            String doctorCityName,
            String doctorUniversityName,
            String categoryName,
            String description,
            String dateTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CaseRequestModel() when $default != null:
        return $default(
            _that.id,
            _that.doctorFirstName,
            _that.doctorLastName,
            _that.doctorPhoneNumber,
            _that.doctorCityName,
            _that.doctorUniversityName,
            _that.categoryName,
            _that.description,
            _that.dateTime);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            int? id,
            String doctorFirstName,
            String doctorLastName,
            String doctorPhoneNumber,
            String doctorCityName,
            String doctorUniversityName,
            String categoryName,
            String description,
            String dateTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CaseRequestModel():
        return $default(
            _that.id,
            _that.doctorFirstName,
            _that.doctorLastName,
            _that.doctorPhoneNumber,
            _that.doctorCityName,
            _that.doctorUniversityName,
            _that.categoryName,
            _that.description,
            _that.dateTime);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int? id,
            String doctorFirstName,
            String doctorLastName,
            String doctorPhoneNumber,
            String doctorCityName,
            String doctorUniversityName,
            String categoryName,
            String description,
            String dateTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CaseRequestModel() when $default != null:
        return $default(
            _that.id,
            _that.doctorFirstName,
            _that.doctorLastName,
            _that.doctorPhoneNumber,
            _that.doctorCityName,
            _that.doctorUniversityName,
            _that.categoryName,
            _that.description,
            _that.dateTime);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CaseRequestModel extends CaseRequestModel {
  const _CaseRequestModel(
      {this.id,
      this.doctorFirstName = '',
      this.doctorLastName = '',
      this.doctorPhoneNumber = '',
      this.doctorCityName = '',
      this.doctorUniversityName = '',
      this.categoryName = '',
      this.description = '',
      this.dateTime = ''})
      : super._();
  factory _CaseRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CaseRequestModelFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey()
  final String doctorFirstName;
  @override
  @JsonKey()
  final String doctorLastName;
  @override
  @JsonKey()
  final String doctorPhoneNumber;
  @override
  @JsonKey()
  final String doctorCityName;
  @override
  @JsonKey()
  final String doctorUniversityName;
  @override
  @JsonKey()
  final String categoryName;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String dateTime;

  /// Create a copy of CaseRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CaseRequestModelCopyWith<_CaseRequestModel> get copyWith =>
      __$CaseRequestModelCopyWithImpl<_CaseRequestModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CaseRequestModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CaseRequestModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.doctorFirstName, doctorFirstName) ||
                other.doctorFirstName == doctorFirstName) &&
            (identical(other.doctorLastName, doctorLastName) ||
                other.doctorLastName == doctorLastName) &&
            (identical(other.doctorPhoneNumber, doctorPhoneNumber) ||
                other.doctorPhoneNumber == doctorPhoneNumber) &&
            (identical(other.doctorCityName, doctorCityName) ||
                other.doctorCityName == doctorCityName) &&
            (identical(other.doctorUniversityName, doctorUniversityName) ||
                other.doctorUniversityName == doctorUniversityName) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      doctorFirstName,
      doctorLastName,
      doctorPhoneNumber,
      doctorCityName,
      doctorUniversityName,
      categoryName,
      description,
      dateTime);

  @override
  String toString() {
    return 'CaseRequestModel(id: $id, doctorFirstName: $doctorFirstName, doctorLastName: $doctorLastName, doctorPhoneNumber: $doctorPhoneNumber, doctorCityName: $doctorCityName, doctorUniversityName: $doctorUniversityName, categoryName: $categoryName, description: $description, dateTime: $dateTime)';
  }
}

/// @nodoc
abstract mixin class _$CaseRequestModelCopyWith<$Res>
    implements $CaseRequestModelCopyWith<$Res> {
  factory _$CaseRequestModelCopyWith(
          _CaseRequestModel value, $Res Function(_CaseRequestModel) _then) =
      __$CaseRequestModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int? id,
      String doctorFirstName,
      String doctorLastName,
      String doctorPhoneNumber,
      String doctorCityName,
      String doctorUniversityName,
      String categoryName,
      String description,
      String dateTime});
}

/// @nodoc
class __$CaseRequestModelCopyWithImpl<$Res>
    implements _$CaseRequestModelCopyWith<$Res> {
  __$CaseRequestModelCopyWithImpl(this._self, this._then);

  final _CaseRequestModel _self;
  final $Res Function(_CaseRequestModel) _then;

  /// Create a copy of CaseRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? doctorFirstName = null,
    Object? doctorLastName = null,
    Object? doctorPhoneNumber = null,
    Object? doctorCityName = null,
    Object? doctorUniversityName = null,
    Object? categoryName = null,
    Object? description = null,
    Object? dateTime = null,
  }) {
    return _then(_CaseRequestModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      doctorFirstName: null == doctorFirstName
          ? _self.doctorFirstName
          : doctorFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorLastName: null == doctorLastName
          ? _self.doctorLastName
          : doctorLastName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorPhoneNumber: null == doctorPhoneNumber
          ? _self.doctorPhoneNumber
          : doctorPhoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      doctorCityName: null == doctorCityName
          ? _self.doctorCityName
          : doctorCityName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorUniversityName: null == doctorUniversityName
          ? _self.doctorUniversityName
          : doctorUniversityName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _self.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _self.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
