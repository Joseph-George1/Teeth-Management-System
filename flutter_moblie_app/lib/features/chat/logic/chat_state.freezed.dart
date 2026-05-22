// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ChatState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ChatState()';
  }
}

/// @nodoc
class $ChatStateCopyWith<$Res> {
  $ChatStateCopyWith(ChatState _, $Res Function(ChatState) __);
}

/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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
    TResult Function(_Initial value)? initial,
    TResult Function(ChatLoading value)? loading,
    TResult Function(ChatSuccess value)? success,
    TResult Function(ChatError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case ChatLoading() when loading != null:
        return loading(_that);
      case ChatSuccess() when success != null:
        return success(_that);
      case ChatError() when error != null:
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
    required TResult Function(_Initial value) initial,
    required TResult Function(ChatLoading value) loading,
    required TResult Function(ChatSuccess value) success,
    required TResult Function(ChatError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case ChatLoading():
        return loading(_that);
      case ChatSuccess():
        return success(_that);
      case ChatError():
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
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChatLoading value)? loading,
    TResult? Function(ChatSuccess value)? success,
    TResult? Function(ChatError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case ChatLoading() when loading != null:
        return loading(_that);
      case ChatSuccess() when success != null:
        return success(_that);
      case ChatError() when error != null:
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
    TResult Function()? loading,
    TResult Function(
            List<FlowItem> flowItems,
            List<ChatItem> chatHistory,
            List<Map<String, dynamic>> categories,
            String? sessionId,
            String? activeQuestionId,
            bool chatMode,
            bool isActionLoading)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case ChatLoading() when loading != null:
        return loading();
      case ChatSuccess() when success != null:
        return success(
            _that.flowItems,
            _that.chatHistory,
            _that.categories,
            _that.sessionId,
            _that.activeQuestionId,
            _that.chatMode,
            _that.isActionLoading);
      case ChatError() when error != null:
        return error(_that.message);
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
    required TResult Function() loading,
    required TResult Function(
            List<FlowItem> flowItems,
            List<ChatItem> chatHistory,
            List<Map<String, dynamic>> categories,
            String? sessionId,
            String? activeQuestionId,
            bool chatMode,
            bool isActionLoading)
        success,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case ChatLoading():
        return loading();
      case ChatSuccess():
        return success(
            _that.flowItems,
            _that.chatHistory,
            _that.categories,
            _that.sessionId,
            _that.activeQuestionId,
            _that.chatMode,
            _that.isActionLoading);
      case ChatError():
        return error(_that.message);
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
    TResult? Function()? loading,
    TResult? Function(
            List<FlowItem> flowItems,
            List<ChatItem> chatHistory,
            List<Map<String, dynamic>> categories,
            String? sessionId,
            String? activeQuestionId,
            bool chatMode,
            bool isActionLoading)?
        success,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case ChatLoading() when loading != null:
        return loading();
      case ChatSuccess() when success != null:
        return success(
            _that.flowItems,
            _that.chatHistory,
            _that.categories,
            _that.sessionId,
            _that.activeQuestionId,
            _that.chatMode,
            _that.isActionLoading);
      case ChatError() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements ChatState {
  _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ChatState.initial()';
  }
}

/// @nodoc

class ChatLoading implements ChatState {
  ChatLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ChatLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ChatState.loading()';
  }
}

/// @nodoc

class ChatSuccess implements ChatState {
  ChatSuccess(
      {required final List<FlowItem> flowItems,
      required final List<ChatItem> chatHistory,
      final List<Map<String, dynamic>> categories = const [],
      this.sessionId,
      this.activeQuestionId,
      this.chatMode = false,
      this.isActionLoading = false})
      : _flowItems = flowItems,
        _chatHistory = chatHistory,
        _categories = categories;

  final List<FlowItem> _flowItems;
  List<FlowItem> get flowItems {
    if (_flowItems is EqualUnmodifiableListView) return _flowItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_flowItems);
  }

  final List<ChatItem> _chatHistory;
  List<ChatItem> get chatHistory {
    if (_chatHistory is EqualUnmodifiableListView) return _chatHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chatHistory);
  }

  final List<Map<String, dynamic>> _categories;
  @JsonKey()
  List<Map<String, dynamic>> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final String? sessionId;
  final String? activeQuestionId;
  @JsonKey()
  final bool chatMode;
  @JsonKey()
  final bool isActionLoading;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatSuccessCopyWith<ChatSuccess> get copyWith =>
      _$ChatSuccessCopyWithImpl<ChatSuccess>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatSuccess &&
            const DeepCollectionEquality()
                .equals(other._flowItems, _flowItems) &&
            const DeepCollectionEquality()
                .equals(other._chatHistory, _chatHistory) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.activeQuestionId, activeQuestionId) ||
                other.activeQuestionId == activeQuestionId) &&
            (identical(other.chatMode, chatMode) ||
                other.chatMode == chatMode) &&
            (identical(other.isActionLoading, isActionLoading) ||
                other.isActionLoading == isActionLoading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_flowItems),
      const DeepCollectionEquality().hash(_chatHistory),
      const DeepCollectionEquality().hash(_categories),
      sessionId,
      activeQuestionId,
      chatMode,
      isActionLoading);

  @override
  String toString() {
    return 'ChatState.success(flowItems: $flowItems, chatHistory: $chatHistory, categories: $categories, sessionId: $sessionId, activeQuestionId: $activeQuestionId, chatMode: $chatMode, isActionLoading: $isActionLoading)';
  }
}

/// @nodoc
abstract mixin class $ChatSuccessCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory $ChatSuccessCopyWith(
          ChatSuccess value, $Res Function(ChatSuccess) _then) =
      _$ChatSuccessCopyWithImpl;
  @useResult
  $Res call(
      {List<FlowItem> flowItems,
      List<ChatItem> chatHistory,
      List<Map<String, dynamic>> categories,
      String? sessionId,
      String? activeQuestionId,
      bool chatMode,
      bool isActionLoading});
}

/// @nodoc
class _$ChatSuccessCopyWithImpl<$Res> implements $ChatSuccessCopyWith<$Res> {
  _$ChatSuccessCopyWithImpl(this._self, this._then);

  final ChatSuccess _self;
  final $Res Function(ChatSuccess) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? flowItems = null,
    Object? chatHistory = null,
    Object? categories = null,
    Object? sessionId = freezed,
    Object? activeQuestionId = freezed,
    Object? chatMode = null,
    Object? isActionLoading = null,
  }) {
    return _then(ChatSuccess(
      flowItems: null == flowItems
          ? _self._flowItems
          : flowItems // ignore: cast_nullable_to_non_nullable
              as List<FlowItem>,
      chatHistory: null == chatHistory
          ? _self._chatHistory
          : chatHistory // ignore: cast_nullable_to_non_nullable
              as List<ChatItem>,
      categories: null == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      sessionId: freezed == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      activeQuestionId: freezed == activeQuestionId
          ? _self.activeQuestionId
          : activeQuestionId // ignore: cast_nullable_to_non_nullable
              as String?,
      chatMode: null == chatMode
          ? _self.chatMode
          : chatMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isActionLoading: null == isActionLoading
          ? _self.isActionLoading
          : isActionLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class ChatError implements ChatState {
  ChatError(this.message);

  final String message;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatErrorCopyWith<ChatError> get copyWith =>
      _$ChatErrorCopyWithImpl<ChatError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'ChatState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $ChatErrorCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory $ChatErrorCopyWith(ChatError value, $Res Function(ChatError) _then) =
      _$ChatErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$ChatErrorCopyWithImpl<$Res> implements $ChatErrorCopyWith<$Res> {
  _$ChatErrorCopyWithImpl(this._self, this._then);

  final ChatError _self;
  final $Res Function(ChatError) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(ChatError(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$FlowItem {
  FlowType get type;
  String get text;
  ChatQuestion? get question;
  String? get category;

  /// Create a copy of FlowItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FlowItemCopyWith<FlowItem> get copyWith =>
      _$FlowItemCopyWithImpl<FlowItem>(this as FlowItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FlowItem &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, text, question, category);

  @override
  String toString() {
    return 'FlowItem(type: $type, text: $text, question: $question, category: $category)';
  }
}

/// @nodoc
abstract mixin class $FlowItemCopyWith<$Res> {
  factory $FlowItemCopyWith(FlowItem value, $Res Function(FlowItem) _then) =
      _$FlowItemCopyWithImpl;
  @useResult
  $Res call(
      {FlowType type, String text, ChatQuestion? question, String? category});

  $ChatQuestionCopyWith<$Res>? get question;
}

/// @nodoc
class _$FlowItemCopyWithImpl<$Res> implements $FlowItemCopyWith<$Res> {
  _$FlowItemCopyWithImpl(this._self, this._then);

  final FlowItem _self;
  final $Res Function(FlowItem) _then;

  /// Create a copy of FlowItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? text = null,
    Object? question = freezed,
    Object? category = freezed,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as FlowType,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      question: freezed == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as ChatQuestion?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of FlowItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatQuestionCopyWith<$Res>? get question {
    if (_self.question == null) {
      return null;
    }

    return $ChatQuestionCopyWith<$Res>(_self.question!, (value) {
      return _then(_self.copyWith(question: value));
    });
  }
}

/// Adds pattern-matching-related methods to [FlowItem].
extension FlowItemPatterns on FlowItem {
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
    TResult Function(_FlowItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FlowItem() when $default != null:
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
    TResult Function(_FlowItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FlowItem():
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
    TResult? Function(_FlowItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FlowItem() when $default != null:
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
    TResult Function(FlowType type, String text, ChatQuestion? question,
            String? category)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FlowItem() when $default != null:
        return $default(_that.type, _that.text, _that.question, _that.category);
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
    TResult Function(FlowType type, String text, ChatQuestion? question,
            String? category)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FlowItem():
        return $default(_that.type, _that.text, _that.question, _that.category);
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
    TResult? Function(FlowType type, String text, ChatQuestion? question,
            String? category)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FlowItem() when $default != null:
        return $default(_that.type, _that.text, _that.question, _that.category);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FlowItem implements FlowItem {
  _FlowItem(
      {required this.type, required this.text, this.question, this.category});

  @override
  final FlowType type;
  @override
  final String text;
  @override
  final ChatQuestion? question;
  @override
  final String? category;

  /// Create a copy of FlowItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FlowItemCopyWith<_FlowItem> get copyWith =>
      __$FlowItemCopyWithImpl<_FlowItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FlowItem &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, text, question, category);

  @override
  String toString() {
    return 'FlowItem(type: $type, text: $text, question: $question, category: $category)';
  }
}

/// @nodoc
abstract mixin class _$FlowItemCopyWith<$Res>
    implements $FlowItemCopyWith<$Res> {
  factory _$FlowItemCopyWith(_FlowItem value, $Res Function(_FlowItem) _then) =
      __$FlowItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {FlowType type, String text, ChatQuestion? question, String? category});

  @override
  $ChatQuestionCopyWith<$Res>? get question;
}

/// @nodoc
class __$FlowItemCopyWithImpl<$Res> implements _$FlowItemCopyWith<$Res> {
  __$FlowItemCopyWithImpl(this._self, this._then);

  final _FlowItem _self;
  final $Res Function(_FlowItem) _then;

  /// Create a copy of FlowItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? text = null,
    Object? question = freezed,
    Object? category = freezed,
  }) {
    return _then(_FlowItem(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as FlowType,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      question: freezed == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as ChatQuestion?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of FlowItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatQuestionCopyWith<$Res>? get question {
    if (_self.question == null) {
      return null;
    }

    return $ChatQuestionCopyWith<$Res>(_self.question!, (value) {
      return _then(_self.copyWith(question: value));
    });
  }
}

/// @nodoc
mixin _$ChatItem {
  ChatRole get role;
  String get text;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatItemCopyWith<ChatItem> get copyWith =>
      _$ChatItemCopyWithImpl<ChatItem>(this as ChatItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatItem &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, text);

  @override
  String toString() {
    return 'ChatItem(role: $role, text: $text)';
  }
}

/// @nodoc
abstract mixin class $ChatItemCopyWith<$Res> {
  factory $ChatItemCopyWith(ChatItem value, $Res Function(ChatItem) _then) =
      _$ChatItemCopyWithImpl;
  @useResult
  $Res call({ChatRole role, String text});
}

/// @nodoc
class _$ChatItemCopyWithImpl<$Res> implements $ChatItemCopyWith<$Res> {
  _$ChatItemCopyWithImpl(this._self, this._then);

  final ChatItem _self;
  final $Res Function(ChatItem) _then;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? text = null,
  }) {
    return _then(_self.copyWith(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as ChatRole,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatItem].
extension ChatItemPatterns on ChatItem {
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
    TResult Function(_ChatItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatItem() when $default != null:
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
    TResult Function(_ChatItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatItem():
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
    TResult? Function(_ChatItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatItem() when $default != null:
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
    TResult Function(ChatRole role, String text)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatItem() when $default != null:
        return $default(_that.role, _that.text);
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
    TResult Function(ChatRole role, String text) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatItem():
        return $default(_that.role, _that.text);
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
    TResult? Function(ChatRole role, String text)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatItem() when $default != null:
        return $default(_that.role, _that.text);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChatItem implements ChatItem {
  _ChatItem({required this.role, required this.text});

  @override
  final ChatRole role;
  @override
  final String text;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatItemCopyWith<_ChatItem> get copyWith =>
      __$ChatItemCopyWithImpl<_ChatItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatItem &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, text);

  @override
  String toString() {
    return 'ChatItem(role: $role, text: $text)';
  }
}

/// @nodoc
abstract mixin class _$ChatItemCopyWith<$Res>
    implements $ChatItemCopyWith<$Res> {
  factory _$ChatItemCopyWith(_ChatItem value, $Res Function(_ChatItem) _then) =
      __$ChatItemCopyWithImpl;
  @override
  @useResult
  $Res call({ChatRole role, String text});
}

/// @nodoc
class __$ChatItemCopyWithImpl<$Res> implements _$ChatItemCopyWith<$Res> {
  __$ChatItemCopyWithImpl(this._self, this._then);

  final _ChatItem _self;
  final $Res Function(_ChatItem) _then;

  /// Create a copy of ChatItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? role = null,
    Object? text = null,
  }) {
    return _then(_ChatItem(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as ChatRole,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
