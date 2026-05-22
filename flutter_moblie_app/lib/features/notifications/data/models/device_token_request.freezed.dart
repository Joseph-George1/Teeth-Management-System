// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_token_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceTokenRequest {
  @JsonKey(name: 'user_id')
  int? get userId;
  @JsonKey(name: 'patient_id')
  int? get patientId;
  @JsonKey(name: 'patient_token')
  String? get patientToken;
  String get fcmToken;
  String get deviceType; // 'ANDROID' or 'IOS'
  String? get deviceModel;
  String? get osVersion;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceTokenRequestCopyWith<DeviceTokenRequest> get copyWith =>
      _$DeviceTokenRequestCopyWithImpl<DeviceTokenRequest>(
          this as DeviceTokenRequest, _$identity);

  /// Serializes this DeviceTokenRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceTokenRequest &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientToken, patientToken) ||
                other.patientToken == patientToken) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceModel, deviceModel) ||
                other.deviceModel == deviceModel) &&
            (identical(other.osVersion, osVersion) ||
                other.osVersion == osVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, patientId, patientToken,
      fcmToken, deviceType, deviceModel, osVersion);

  @override
  String toString() {
    return 'DeviceTokenRequest(userId: $userId, patientId: $patientId, patientToken: $patientToken, fcmToken: $fcmToken, deviceType: $deviceType, deviceModel: $deviceModel, osVersion: $osVersion)';
  }
}

/// @nodoc
abstract mixin class $DeviceTokenRequestCopyWith<$Res> {
  factory $DeviceTokenRequestCopyWith(
          DeviceTokenRequest value, $Res Function(DeviceTokenRequest) _then) =
      _$DeviceTokenRequestCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'patient_id') int? patientId,
      @JsonKey(name: 'patient_token') String? patientToken,
      String fcmToken,
      String deviceType,
      String? deviceModel,
      String? osVersion});
}

/// @nodoc
class _$DeviceTokenRequestCopyWithImpl<$Res>
    implements $DeviceTokenRequestCopyWith<$Res> {
  _$DeviceTokenRequestCopyWithImpl(this._self, this._then);

  final DeviceTokenRequest _self;
  final $Res Function(DeviceTokenRequest) _then;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? patientId = freezed,
    Object? patientToken = freezed,
    Object? fcmToken = null,
    Object? deviceType = null,
    Object? deviceModel = freezed,
    Object? osVersion = freezed,
  }) {
    return _then(_self.copyWith(
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      patientId: freezed == patientId
          ? _self.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int?,
      patientToken: freezed == patientToken
          ? _self.patientToken
          : patientToken // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceModel: freezed == deviceModel
          ? _self.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String?,
      osVersion: freezed == osVersion
          ? _self.osVersion
          : osVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceTokenRequest].
extension DeviceTokenRequestPatterns on DeviceTokenRequest {
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
    TResult Function(_DeviceTokenRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceTokenRequest() when $default != null:
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
    TResult Function(_DeviceTokenRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceTokenRequest():
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
    TResult? Function(_DeviceTokenRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceTokenRequest() when $default != null:
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
            @JsonKey(name: 'user_id') int? userId,
            @JsonKey(name: 'patient_id') int? patientId,
            @JsonKey(name: 'patient_token') String? patientToken,
            String fcmToken,
            String deviceType,
            String? deviceModel,
            String? osVersion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceTokenRequest() when $default != null:
        return $default(
            _that.userId,
            _that.patientId,
            _that.patientToken,
            _that.fcmToken,
            _that.deviceType,
            _that.deviceModel,
            _that.osVersion);
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
            @JsonKey(name: 'user_id') int? userId,
            @JsonKey(name: 'patient_id') int? patientId,
            @JsonKey(name: 'patient_token') String? patientToken,
            String fcmToken,
            String deviceType,
            String? deviceModel,
            String? osVersion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceTokenRequest():
        return $default(
            _that.userId,
            _that.patientId,
            _that.patientToken,
            _that.fcmToken,
            _that.deviceType,
            _that.deviceModel,
            _that.osVersion);
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
            @JsonKey(name: 'user_id') int? userId,
            @JsonKey(name: 'patient_id') int? patientId,
            @JsonKey(name: 'patient_token') String? patientToken,
            String fcmToken,
            String deviceType,
            String? deviceModel,
            String? osVersion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceTokenRequest() when $default != null:
        return $default(
            _that.userId,
            _that.patientId,
            _that.patientToken,
            _that.fcmToken,
            _that.deviceType,
            _that.deviceModel,
            _that.osVersion);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeviceTokenRequest implements DeviceTokenRequest {
  const _DeviceTokenRequest(
      {@JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'patient_id') this.patientId,
      @JsonKey(name: 'patient_token') this.patientToken,
      required this.fcmToken,
      required this.deviceType,
      this.deviceModel,
      this.osVersion});
  factory _DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final int? userId;
  @override
  @JsonKey(name: 'patient_id')
  final int? patientId;
  @override
  @JsonKey(name: 'patient_token')
  final String? patientToken;
  @override
  final String fcmToken;
  @override
  final String deviceType;
// 'ANDROID' or 'IOS'
  @override
  final String? deviceModel;
  @override
  final String? osVersion;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceTokenRequestCopyWith<_DeviceTokenRequest> get copyWith =>
      __$DeviceTokenRequestCopyWithImpl<_DeviceTokenRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeviceTokenRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceTokenRequest &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientToken, patientToken) ||
                other.patientToken == patientToken) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceModel, deviceModel) ||
                other.deviceModel == deviceModel) &&
            (identical(other.osVersion, osVersion) ||
                other.osVersion == osVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, patientId, patientToken,
      fcmToken, deviceType, deviceModel, osVersion);

  @override
  String toString() {
    return 'DeviceTokenRequest(userId: $userId, patientId: $patientId, patientToken: $patientToken, fcmToken: $fcmToken, deviceType: $deviceType, deviceModel: $deviceModel, osVersion: $osVersion)';
  }
}

/// @nodoc
abstract mixin class _$DeviceTokenRequestCopyWith<$Res>
    implements $DeviceTokenRequestCopyWith<$Res> {
  factory _$DeviceTokenRequestCopyWith(
          _DeviceTokenRequest value, $Res Function(_DeviceTokenRequest) _then) =
      __$DeviceTokenRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'patient_id') int? patientId,
      @JsonKey(name: 'patient_token') String? patientToken,
      String fcmToken,
      String deviceType,
      String? deviceModel,
      String? osVersion});
}

/// @nodoc
class __$DeviceTokenRequestCopyWithImpl<$Res>
    implements _$DeviceTokenRequestCopyWith<$Res> {
  __$DeviceTokenRequestCopyWithImpl(this._self, this._then);

  final _DeviceTokenRequest _self;
  final $Res Function(_DeviceTokenRequest) _then;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = freezed,
    Object? patientId = freezed,
    Object? patientToken = freezed,
    Object? fcmToken = null,
    Object? deviceType = null,
    Object? deviceModel = freezed,
    Object? osVersion = freezed,
  }) {
    return _then(_DeviceTokenRequest(
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      patientId: freezed == patientId
          ? _self.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int?,
      patientToken: freezed == patientToken
          ? _self.patientToken
          : patientToken // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceModel: freezed == deviceModel
          ? _self.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String?,
      osVersion: freezed == osVersion
          ? _self.osVersion
          : osVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
