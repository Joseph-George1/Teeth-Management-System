// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoctorModel {
  int? get id;
  String get firstName;
  String get lastName;
  String get studyYear;
  String get phoneNumber;
  String get universityName;
  String get cityName;
  String get categoryName;
  String? get photo;
  String? get email;
  String? get description;
  double? get price;

  /// Create a copy of DoctorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DoctorModelCopyWith<DoctorModel> get copyWith =>
      _$DoctorModelCopyWithImpl<DoctorModel>(this as DoctorModel, _$identity);

  /// Serializes this DoctorModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DoctorModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.studyYear, studyYear) ||
                other.studyYear == studyYear) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.universityName, universityName) ||
                other.universityName == universityName) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      studyYear,
      phoneNumber,
      universityName,
      cityName,
      categoryName,
      photo,
      email,
      description,
      price);

  @override
  String toString() {
    return 'DoctorModel(id: $id, firstName: $firstName, lastName: $lastName, studyYear: $studyYear, phoneNumber: $phoneNumber, universityName: $universityName, cityName: $cityName, categoryName: $categoryName, photo: $photo, email: $email, description: $description, price: $price)';
  }
}

/// @nodoc
abstract mixin class $DoctorModelCopyWith<$Res> {
  factory $DoctorModelCopyWith(
          DoctorModel value, $Res Function(DoctorModel) _then) =
      _$DoctorModelCopyWithImpl;
  @useResult
  $Res call(
      {int? id,
      String firstName,
      String lastName,
      String studyYear,
      String phoneNumber,
      String universityName,
      String cityName,
      String categoryName,
      String? photo,
      String? email,
      String? description,
      double? price});
}

/// @nodoc
class _$DoctorModelCopyWithImpl<$Res> implements $DoctorModelCopyWith<$Res> {
  _$DoctorModelCopyWithImpl(this._self, this._then);

  final DoctorModel _self;
  final $Res Function(DoctorModel) _then;

  /// Create a copy of DoctorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = null,
    Object? lastName = null,
    Object? studyYear = null,
    Object? phoneNumber = null,
    Object? universityName = null,
    Object? cityName = null,
    Object? categoryName = null,
    Object? photo = freezed,
    Object? email = freezed,
    Object? description = freezed,
    Object? price = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      studyYear: null == studyYear
          ? _self.studyYear
          : studyYear // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      universityName: null == universityName
          ? _self.universityName
          : universityName // ignore: cast_nullable_to_non_nullable
              as String,
      cityName: null == cityName
          ? _self.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _self.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      photo: freezed == photo
          ? _self.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DoctorModel].
extension DoctorModelPatterns on DoctorModel {
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
    TResult Function(_DoctorModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DoctorModel() when $default != null:
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
    TResult Function(_DoctorModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorModel():
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
    TResult? Function(_DoctorModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorModel() when $default != null:
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
            String firstName,
            String lastName,
            String studyYear,
            String phoneNumber,
            String universityName,
            String cityName,
            String categoryName,
            String? photo,
            String? email,
            String? description,
            double? price)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DoctorModel() when $default != null:
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.studyYear,
            _that.phoneNumber,
            _that.universityName,
            _that.cityName,
            _that.categoryName,
            _that.photo,
            _that.email,
            _that.description,
            _that.price);
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
            String firstName,
            String lastName,
            String studyYear,
            String phoneNumber,
            String universityName,
            String cityName,
            String categoryName,
            String? photo,
            String? email,
            String? description,
            double? price)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorModel():
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.studyYear,
            _that.phoneNumber,
            _that.universityName,
            _that.cityName,
            _that.categoryName,
            _that.photo,
            _that.email,
            _that.description,
            _that.price);
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
            String firstName,
            String lastName,
            String studyYear,
            String phoneNumber,
            String universityName,
            String cityName,
            String categoryName,
            String? photo,
            String? email,
            String? description,
            double? price)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorModel() when $default != null:
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.studyYear,
            _that.phoneNumber,
            _that.universityName,
            _that.cityName,
            _that.categoryName,
            _that.photo,
            _that.email,
            _that.description,
            _that.price);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DoctorModel extends DoctorModel {
  const _DoctorModel(
      {this.id,
      this.firstName = '',
      this.lastName = '',
      this.studyYear = '',
      this.phoneNumber = '',
      this.universityName = '',
      this.cityName = '',
      this.categoryName = '',
      this.photo,
      this.email,
      this.description,
      this.price})
      : super._();
  factory _DoctorModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorModelFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey()
  final String firstName;
  @override
  @JsonKey()
  final String lastName;
  @override
  @JsonKey()
  final String studyYear;
  @override
  @JsonKey()
  final String phoneNumber;
  @override
  @JsonKey()
  final String universityName;
  @override
  @JsonKey()
  final String cityName;
  @override
  @JsonKey()
  final String categoryName;
  @override
  final String? photo;
  @override
  final String? email;
  @override
  final String? description;
  @override
  final double? price;

  /// Create a copy of DoctorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DoctorModelCopyWith<_DoctorModel> get copyWith =>
      __$DoctorModelCopyWithImpl<_DoctorModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DoctorModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DoctorModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.studyYear, studyYear) ||
                other.studyYear == studyYear) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.universityName, universityName) ||
                other.universityName == universityName) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      studyYear,
      phoneNumber,
      universityName,
      cityName,
      categoryName,
      photo,
      email,
      description,
      price);

  @override
  String toString() {
    return 'DoctorModel(id: $id, firstName: $firstName, lastName: $lastName, studyYear: $studyYear, phoneNumber: $phoneNumber, universityName: $universityName, cityName: $cityName, categoryName: $categoryName, photo: $photo, email: $email, description: $description, price: $price)';
  }
}

/// @nodoc
abstract mixin class _$DoctorModelCopyWith<$Res>
    implements $DoctorModelCopyWith<$Res> {
  factory _$DoctorModelCopyWith(
          _DoctorModel value, $Res Function(_DoctorModel) _then) =
      __$DoctorModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int? id,
      String firstName,
      String lastName,
      String studyYear,
      String phoneNumber,
      String universityName,
      String cityName,
      String categoryName,
      String? photo,
      String? email,
      String? description,
      double? price});
}

/// @nodoc
class __$DoctorModelCopyWithImpl<$Res> implements _$DoctorModelCopyWith<$Res> {
  __$DoctorModelCopyWithImpl(this._self, this._then);

  final _DoctorModel _self;
  final $Res Function(_DoctorModel) _then;

  /// Create a copy of DoctorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? firstName = null,
    Object? lastName = null,
    Object? studyYear = null,
    Object? phoneNumber = null,
    Object? universityName = null,
    Object? cityName = null,
    Object? categoryName = null,
    Object? photo = freezed,
    Object? email = freezed,
    Object? description = freezed,
    Object? price = freezed,
  }) {
    return _then(_DoctorModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      studyYear: null == studyYear
          ? _self.studyYear
          : studyYear // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      universityName: null == universityName
          ? _self.universityName
          : universityName // ignore: cast_nullable_to_non_nullable
              as String,
      cityName: null == cityName
          ? _self.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _self.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      photo: freezed == photo
          ? _self.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
