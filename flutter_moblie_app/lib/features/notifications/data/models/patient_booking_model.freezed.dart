// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatientBookingModel {
  String get patientName;
  String get phone;
  String get date;
  String get time;

  /// Create a copy of PatientBookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PatientBookingModelCopyWith<PatientBookingModel> get copyWith =>
      _$PatientBookingModelCopyWithImpl<PatientBookingModel>(
          this as PatientBookingModel, _$identity);

  /// Serializes this PatientBookingModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PatientBookingModel &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, patientName, phone, date, time);

  @override
  String toString() {
    return 'PatientBookingModel(patientName: $patientName, phone: $phone, date: $date, time: $time)';
  }
}

/// @nodoc
abstract mixin class $PatientBookingModelCopyWith<$Res> {
  factory $PatientBookingModelCopyWith(
          PatientBookingModel value, $Res Function(PatientBookingModel) _then) =
      _$PatientBookingModelCopyWithImpl;
  @useResult
  $Res call({String patientName, String phone, String date, String time});
}

/// @nodoc
class _$PatientBookingModelCopyWithImpl<$Res>
    implements $PatientBookingModelCopyWith<$Res> {
  _$PatientBookingModelCopyWithImpl(this._self, this._then);

  final PatientBookingModel _self;
  final $Res Function(PatientBookingModel) _then;

  /// Create a copy of PatientBookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientName = null,
    Object? phone = null,
    Object? date = null,
    Object? time = null,
  }) {
    return _then(_self.copyWith(
      patientName: null == patientName
          ? _self.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [PatientBookingModel].
extension PatientBookingModelPatterns on PatientBookingModel {
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
    TResult Function(_PatientBookingModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PatientBookingModel() when $default != null:
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
    TResult Function(_PatientBookingModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatientBookingModel():
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
    TResult? Function(_PatientBookingModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatientBookingModel() when $default != null:
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
            String patientName, String phone, String date, String time)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PatientBookingModel() when $default != null:
        return $default(_that.patientName, _that.phone, _that.date, _that.time);
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
    TResult Function(String patientName, String phone, String date, String time)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatientBookingModel():
        return $default(_that.patientName, _that.phone, _that.date, _that.time);
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
            String patientName, String phone, String date, String time)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatientBookingModel() when $default != null:
        return $default(_that.patientName, _that.phone, _that.date, _that.time);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PatientBookingModel implements PatientBookingModel {
  const _PatientBookingModel(
      {this.patientName = 'Unknown',
      this.phone = '',
      this.date = '',
      this.time = ''});
  factory _PatientBookingModel.fromJson(Map<String, dynamic> json) =>
      _$PatientBookingModelFromJson(json);

  @override
  @JsonKey()
  final String patientName;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String date;
  @override
  @JsonKey()
  final String time;

  /// Create a copy of PatientBookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PatientBookingModelCopyWith<_PatientBookingModel> get copyWith =>
      __$PatientBookingModelCopyWithImpl<_PatientBookingModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PatientBookingModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PatientBookingModel &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, patientName, phone, date, time);

  @override
  String toString() {
    return 'PatientBookingModel(patientName: $patientName, phone: $phone, date: $date, time: $time)';
  }
}

/// @nodoc
abstract mixin class _$PatientBookingModelCopyWith<$Res>
    implements $PatientBookingModelCopyWith<$Res> {
  factory _$PatientBookingModelCopyWith(_PatientBookingModel value,
          $Res Function(_PatientBookingModel) _then) =
      __$PatientBookingModelCopyWithImpl;
  @override
  @useResult
  $Res call({String patientName, String phone, String date, String time});
}

/// @nodoc
class __$PatientBookingModelCopyWithImpl<$Res>
    implements _$PatientBookingModelCopyWith<$Res> {
  __$PatientBookingModelCopyWithImpl(this._self, this._then);

  final _PatientBookingModel _self;
  final $Res Function(_PatientBookingModel) _then;

  /// Create a copy of PatientBookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? patientName = null,
    Object? phone = null,
    Object? date = null,
    Object? time = null,
  }) {
    return _then(_PatientBookingModel(
      patientName: null == patientName
          ? _self.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
