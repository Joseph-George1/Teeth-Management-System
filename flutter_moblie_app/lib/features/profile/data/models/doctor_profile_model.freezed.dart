// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoctorProfileModel {
  int? get id;
  @JsonKey(readValue: readFirstName)
  String? get firstName;
  @JsonKey(readValue: readLastName)
  String? get lastName;
  @JsonKey(readValue: readEmail)
  String? get email;
  @JsonKey(readValue: readPhone)
  String? get phone;
  @JsonKey(readValue: readFaculty)
  String? get faculty;
  @JsonKey(readValue: readYear)
  String? get year;
  @JsonKey(readValue: readGov)
  String? get governorate;
  @JsonKey(readValue: readCat)
  String? get category;

  /// Create a copy of DoctorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DoctorProfileModelCopyWith<DoctorProfileModel> get copyWith =>
      _$DoctorProfileModelCopyWithImpl<DoctorProfileModel>(
          this as DoctorProfileModel, _$identity);

  /// Serializes this DoctorProfileModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DoctorProfileModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.faculty, faculty) || other.faculty == faculty) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.governorate, governorate) ||
                other.governorate == governorate) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName, email,
      phone, faculty, year, governorate, category);

  @override
  String toString() {
    return 'DoctorProfileModel(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, faculty: $faculty, year: $year, governorate: $governorate, category: $category)';
  }
}

/// @nodoc
abstract mixin class $DoctorProfileModelCopyWith<$Res> {
  factory $DoctorProfileModelCopyWith(
          DoctorProfileModel value, $Res Function(DoctorProfileModel) _then) =
      _$DoctorProfileModelCopyWithImpl;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(readValue: readFirstName) String? firstName,
      @JsonKey(readValue: readLastName) String? lastName,
      @JsonKey(readValue: readEmail) String? email,
      @JsonKey(readValue: readPhone) String? phone,
      @JsonKey(readValue: readFaculty) String? faculty,
      @JsonKey(readValue: readYear) String? year,
      @JsonKey(readValue: readGov) String? governorate,
      @JsonKey(readValue: readCat) String? category});
}

/// @nodoc
class _$DoctorProfileModelCopyWithImpl<$Res>
    implements $DoctorProfileModelCopyWith<$Res> {
  _$DoctorProfileModelCopyWithImpl(this._self, this._then);

  final DoctorProfileModel _self;
  final $Res Function(DoctorProfileModel) _then;

  /// Create a copy of DoctorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? faculty = freezed,
    Object? year = freezed,
    Object? governorate = freezed,
    Object? category = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      faculty: freezed == faculty
          ? _self.faculty
          : faculty // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as String?,
      governorate: freezed == governorate
          ? _self.governorate
          : governorate // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DoctorProfileModel].
extension DoctorProfileModelPatterns on DoctorProfileModel {
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
    TResult Function(_DoctorProfileModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DoctorProfileModel() when $default != null:
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
    TResult Function(_DoctorProfileModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfileModel():
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
    TResult? Function(_DoctorProfileModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfileModel() when $default != null:
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
            @JsonKey(readValue: readFirstName) String? firstName,
            @JsonKey(readValue: readLastName) String? lastName,
            @JsonKey(readValue: readEmail) String? email,
            @JsonKey(readValue: readPhone) String? phone,
            @JsonKey(readValue: readFaculty) String? faculty,
            @JsonKey(readValue: readYear) String? year,
            @JsonKey(readValue: readGov) String? governorate,
            @JsonKey(readValue: readCat) String? category)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DoctorProfileModel() when $default != null:
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.email,
            _that.phone,
            _that.faculty,
            _that.year,
            _that.governorate,
            _that.category);
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
            @JsonKey(readValue: readFirstName) String? firstName,
            @JsonKey(readValue: readLastName) String? lastName,
            @JsonKey(readValue: readEmail) String? email,
            @JsonKey(readValue: readPhone) String? phone,
            @JsonKey(readValue: readFaculty) String? faculty,
            @JsonKey(readValue: readYear) String? year,
            @JsonKey(readValue: readGov) String? governorate,
            @JsonKey(readValue: readCat) String? category)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfileModel():
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.email,
            _that.phone,
            _that.faculty,
            _that.year,
            _that.governorate,
            _that.category);
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
            @JsonKey(readValue: readFirstName) String? firstName,
            @JsonKey(readValue: readLastName) String? lastName,
            @JsonKey(readValue: readEmail) String? email,
            @JsonKey(readValue: readPhone) String? phone,
            @JsonKey(readValue: readFaculty) String? faculty,
            @JsonKey(readValue: readYear) String? year,
            @JsonKey(readValue: readGov) String? governorate,
            @JsonKey(readValue: readCat) String? category)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfileModel() when $default != null:
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.email,
            _that.phone,
            _that.faculty,
            _that.year,
            _that.governorate,
            _that.category);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DoctorProfileModel implements DoctorProfileModel {
  const _DoctorProfileModel(
      {this.id,
      @JsonKey(readValue: readFirstName) this.firstName,
      @JsonKey(readValue: readLastName) this.lastName,
      @JsonKey(readValue: readEmail) this.email,
      @JsonKey(readValue: readPhone) this.phone,
      @JsonKey(readValue: readFaculty) this.faculty,
      @JsonKey(readValue: readYear) this.year,
      @JsonKey(readValue: readGov) this.governorate,
      @JsonKey(readValue: readCat) this.category});
  factory _DoctorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorProfileModelFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(readValue: readFirstName)
  final String? firstName;
  @override
  @JsonKey(readValue: readLastName)
  final String? lastName;
  @override
  @JsonKey(readValue: readEmail)
  final String? email;
  @override
  @JsonKey(readValue: readPhone)
  final String? phone;
  @override
  @JsonKey(readValue: readFaculty)
  final String? faculty;
  @override
  @JsonKey(readValue: readYear)
  final String? year;
  @override
  @JsonKey(readValue: readGov)
  final String? governorate;
  @override
  @JsonKey(readValue: readCat)
  final String? category;

  /// Create a copy of DoctorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DoctorProfileModelCopyWith<_DoctorProfileModel> get copyWith =>
      __$DoctorProfileModelCopyWithImpl<_DoctorProfileModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DoctorProfileModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DoctorProfileModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.faculty, faculty) || other.faculty == faculty) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.governorate, governorate) ||
                other.governorate == governorate) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName, email,
      phone, faculty, year, governorate, category);

  @override
  String toString() {
    return 'DoctorProfileModel(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, faculty: $faculty, year: $year, governorate: $governorate, category: $category)';
  }
}

/// @nodoc
abstract mixin class _$DoctorProfileModelCopyWith<$Res>
    implements $DoctorProfileModelCopyWith<$Res> {
  factory _$DoctorProfileModelCopyWith(
          _DoctorProfileModel value, $Res Function(_DoctorProfileModel) _then) =
      __$DoctorProfileModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(readValue: readFirstName) String? firstName,
      @JsonKey(readValue: readLastName) String? lastName,
      @JsonKey(readValue: readEmail) String? email,
      @JsonKey(readValue: readPhone) String? phone,
      @JsonKey(readValue: readFaculty) String? faculty,
      @JsonKey(readValue: readYear) String? year,
      @JsonKey(readValue: readGov) String? governorate,
      @JsonKey(readValue: readCat) String? category});
}

/// @nodoc
class __$DoctorProfileModelCopyWithImpl<$Res>
    implements _$DoctorProfileModelCopyWith<$Res> {
  __$DoctorProfileModelCopyWithImpl(this._self, this._then);

  final _DoctorProfileModel _self;
  final $Res Function(_DoctorProfileModel) _then;

  /// Create a copy of DoctorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? faculty = freezed,
    Object? year = freezed,
    Object? governorate = freezed,
    Object? category = freezed,
  }) {
    return _then(_DoctorProfileModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      faculty: freezed == faculty
          ? _self.faculty
          : faculty // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as String?,
      governorate: freezed == governorate
          ? _self.governorate
          : governorate // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
