// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationLogModel {
  int get id;
  String get title;
  String get body;
  @JsonKey(name: 'status')
  String get status;
  @JsonKey(name: 'createdAt')
  String get createdAt;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;
  bool get readStatus;
  Map<String, dynamic> get payload; // Optional payload fields
  String? get appointmentId;
  String? get messageId;
  String? get doctorId;
  String? get type;
  String? get time;
  String? get clinic;
  String? get doctorName;

  /// Create a copy of NotificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationLogModelCopyWith<NotificationLogModel> get copyWith =>
      _$NotificationLogModelCopyWithImpl<NotificationLogModel>(
          this as NotificationLogModel, _$identity);

  /// Serializes this NotificationLogModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationLogModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.readStatus, readStatus) ||
                other.readStatus == readStatus) &&
            const DeepCollectionEquality().equals(other.payload, payload) &&
            (identical(other.appointmentId, appointmentId) ||
                other.appointmentId == appointmentId) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.clinic, clinic) || other.clinic == clinic) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      body,
      status,
      createdAt,
      updatedAt,
      readStatus,
      const DeepCollectionEquality().hash(payload),
      appointmentId,
      messageId,
      doctorId,
      type,
      time,
      clinic,
      doctorName);

  @override
  String toString() {
    return 'NotificationLogModel(id: $id, title: $title, body: $body, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, readStatus: $readStatus, payload: $payload, appointmentId: $appointmentId, messageId: $messageId, doctorId: $doctorId, type: $type, time: $time, clinic: $clinic, doctorName: $doctorName)';
  }
}

/// @nodoc
abstract mixin class $NotificationLogModelCopyWith<$Res> {
  factory $NotificationLogModelCopyWith(NotificationLogModel value,
          $Res Function(NotificationLogModel) _then) =
      _$NotificationLogModelCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String title,
      String body,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'createdAt') String createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      bool readStatus,
      Map<String, dynamic> payload,
      String? appointmentId,
      String? messageId,
      String? doctorId,
      String? type,
      String? time,
      String? clinic,
      String? doctorName});
}

/// @nodoc
class _$NotificationLogModelCopyWithImpl<$Res>
    implements $NotificationLogModelCopyWith<$Res> {
  _$NotificationLogModelCopyWithImpl(this._self, this._then);

  final NotificationLogModel _self;
  final $Res Function(NotificationLogModel) _then;

  /// Create a copy of NotificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? readStatus = null,
    Object? payload = null,
    Object? appointmentId = freezed,
    Object? messageId = freezed,
    Object? doctorId = freezed,
    Object? type = freezed,
    Object? time = freezed,
    Object? clinic = freezed,
    Object? doctorName = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      readStatus: null == readStatus
          ? _self.readStatus
          : readStatus // ignore: cast_nullable_to_non_nullable
              as bool,
      payload: null == payload
          ? _self.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      appointmentId: freezed == appointmentId
          ? _self.appointmentId
          : appointmentId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageId: freezed == messageId
          ? _self.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String?,
      doctorId: freezed == doctorId
          ? _self.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      time: freezed == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String?,
      clinic: freezed == clinic
          ? _self.clinic
          : clinic // ignore: cast_nullable_to_non_nullable
              as String?,
      doctorName: freezed == doctorName
          ? _self.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [NotificationLogModel].
extension NotificationLogModelPatterns on NotificationLogModel {
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
    TResult Function(_NotificationLogModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationLogModel() when $default != null:
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
    TResult Function(_NotificationLogModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationLogModel():
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
    TResult? Function(_NotificationLogModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationLogModel() when $default != null:
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
            int id,
            String title,
            String body,
            @JsonKey(name: 'status') String status,
            @JsonKey(name: 'createdAt') String createdAt,
            @JsonKey(name: 'updatedAt') String? updatedAt,
            bool readStatus,
            Map<String, dynamic> payload,
            String? appointmentId,
            String? messageId,
            String? doctorId,
            String? type,
            String? time,
            String? clinic,
            String? doctorName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationLogModel() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.body,
            _that.status,
            _that.createdAt,
            _that.updatedAt,
            _that.readStatus,
            _that.payload,
            _that.appointmentId,
            _that.messageId,
            _that.doctorId,
            _that.type,
            _that.time,
            _that.clinic,
            _that.doctorName);
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
            int id,
            String title,
            String body,
            @JsonKey(name: 'status') String status,
            @JsonKey(name: 'createdAt') String createdAt,
            @JsonKey(name: 'updatedAt') String? updatedAt,
            bool readStatus,
            Map<String, dynamic> payload,
            String? appointmentId,
            String? messageId,
            String? doctorId,
            String? type,
            String? time,
            String? clinic,
            String? doctorName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationLogModel():
        return $default(
            _that.id,
            _that.title,
            _that.body,
            _that.status,
            _that.createdAt,
            _that.updatedAt,
            _that.readStatus,
            _that.payload,
            _that.appointmentId,
            _that.messageId,
            _that.doctorId,
            _that.type,
            _that.time,
            _that.clinic,
            _that.doctorName);
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
            int id,
            String title,
            String body,
            @JsonKey(name: 'status') String status,
            @JsonKey(name: 'createdAt') String createdAt,
            @JsonKey(name: 'updatedAt') String? updatedAt,
            bool readStatus,
            Map<String, dynamic> payload,
            String? appointmentId,
            String? messageId,
            String? doctorId,
            String? type,
            String? time,
            String? clinic,
            String? doctorName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationLogModel() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.body,
            _that.status,
            _that.createdAt,
            _that.updatedAt,
            _that.readStatus,
            _that.payload,
            _that.appointmentId,
            _that.messageId,
            _that.doctorId,
            _that.type,
            _that.time,
            _that.clinic,
            _that.doctorName);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NotificationLogModel implements NotificationLogModel {
  const _NotificationLogModel(
      {required this.id,
      required this.title,
      this.body = '',
      @JsonKey(name: 'status') this.status = 'SENT',
      @JsonKey(name: 'createdAt') required this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt,
      this.readStatus = false,
      final Map<String, dynamic> payload = const {},
      this.appointmentId = '',
      this.messageId = '',
      this.doctorId = '',
      this.type = '',
      this.time = '',
      this.clinic = '',
      this.doctorName = ''})
      : _payload = payload;
  factory _NotificationLogModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationLogModelFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey()
  final String body;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'createdAt')
  final String createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;
  @override
  @JsonKey()
  final bool readStatus;
  final Map<String, dynamic> _payload;
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

// Optional payload fields
  @override
  @JsonKey()
  final String? appointmentId;
  @override
  @JsonKey()
  final String? messageId;
  @override
  @JsonKey()
  final String? doctorId;
  @override
  @JsonKey()
  final String? type;
  @override
  @JsonKey()
  final String? time;
  @override
  @JsonKey()
  final String? clinic;
  @override
  @JsonKey()
  final String? doctorName;

  /// Create a copy of NotificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationLogModelCopyWith<_NotificationLogModel> get copyWith =>
      __$NotificationLogModelCopyWithImpl<_NotificationLogModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NotificationLogModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationLogModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.readStatus, readStatus) ||
                other.readStatus == readStatus) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.appointmentId, appointmentId) ||
                other.appointmentId == appointmentId) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.clinic, clinic) || other.clinic == clinic) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      body,
      status,
      createdAt,
      updatedAt,
      readStatus,
      const DeepCollectionEquality().hash(_payload),
      appointmentId,
      messageId,
      doctorId,
      type,
      time,
      clinic,
      doctorName);

  @override
  String toString() {
    return 'NotificationLogModel(id: $id, title: $title, body: $body, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, readStatus: $readStatus, payload: $payload, appointmentId: $appointmentId, messageId: $messageId, doctorId: $doctorId, type: $type, time: $time, clinic: $clinic, doctorName: $doctorName)';
  }
}

/// @nodoc
abstract mixin class _$NotificationLogModelCopyWith<$Res>
    implements $NotificationLogModelCopyWith<$Res> {
  factory _$NotificationLogModelCopyWith(_NotificationLogModel value,
          $Res Function(_NotificationLogModel) _then) =
      __$NotificationLogModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String body,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'createdAt') String createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      bool readStatus,
      Map<String, dynamic> payload,
      String? appointmentId,
      String? messageId,
      String? doctorId,
      String? type,
      String? time,
      String? clinic,
      String? doctorName});
}

/// @nodoc
class __$NotificationLogModelCopyWithImpl<$Res>
    implements _$NotificationLogModelCopyWith<$Res> {
  __$NotificationLogModelCopyWithImpl(this._self, this._then);

  final _NotificationLogModel _self;
  final $Res Function(_NotificationLogModel) _then;

  /// Create a copy of NotificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? readStatus = null,
    Object? payload = null,
    Object? appointmentId = freezed,
    Object? messageId = freezed,
    Object? doctorId = freezed,
    Object? type = freezed,
    Object? time = freezed,
    Object? clinic = freezed,
    Object? doctorName = freezed,
  }) {
    return _then(_NotificationLogModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      readStatus: null == readStatus
          ? _self.readStatus
          : readStatus // ignore: cast_nullable_to_non_nullable
              as bool,
      payload: null == payload
          ? _self._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      appointmentId: freezed == appointmentId
          ? _self.appointmentId
          : appointmentId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageId: freezed == messageId
          ? _self.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String?,
      doctorId: freezed == doctorId
          ? _self.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      time: freezed == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String?,
      clinic: freezed == clinic
          ? _self.clinic
          : clinic // ignore: cast_nullable_to_non_nullable
              as String?,
      doctorName: freezed == doctorName
          ? _self.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
