// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatResponse {
  @JsonKey(name: 'session_id')
  String? get sessionId;
  @JsonKey(name: 'next_step')
  String? get nextStep;
  @JsonKey(name: 'chatbot_mode')
  bool? get chatbotMode;
  ChatQuestion? get question;
  List<ChatAnswer>? get answers;
  @JsonKey(name: 'question_id')
  String? get questionId;
  @JsonKey(name: 'question_text')
  String? get questionText;
  Map<String, dynamic>? get result;
  String? get reply;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatResponseCopyWith<ChatResponse> get copyWith =>
      _$ChatResponseCopyWithImpl<ChatResponse>(
          this as ChatResponse, _$identity);

  /// Serializes this ChatResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatResponse &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.nextStep, nextStep) ||
                other.nextStep == nextStep) &&
            (identical(other.chatbotMode, chatbotMode) ||
                other.chatbotMode == chatbotMode) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other.answers, answers) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            const DeepCollectionEquality().equals(other.result, result) &&
            (identical(other.reply, reply) || other.reply == reply));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      nextStep,
      chatbotMode,
      question,
      const DeepCollectionEquality().hash(answers),
      questionId,
      questionText,
      const DeepCollectionEquality().hash(result),
      reply);

  @override
  String toString() {
    return 'ChatResponse(sessionId: $sessionId, nextStep: $nextStep, chatbotMode: $chatbotMode, question: $question, answers: $answers, questionId: $questionId, questionText: $questionText, result: $result, reply: $reply)';
  }
}

/// @nodoc
abstract mixin class $ChatResponseCopyWith<$Res> {
  factory $ChatResponseCopyWith(
          ChatResponse value, $Res Function(ChatResponse) _then) =
      _$ChatResponseCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'next_step') String? nextStep,
      @JsonKey(name: 'chatbot_mode') bool? chatbotMode,
      ChatQuestion? question,
      List<ChatAnswer>? answers,
      @JsonKey(name: 'question_id') String? questionId,
      @JsonKey(name: 'question_text') String? questionText,
      Map<String, dynamic>? result,
      String? reply});

  $ChatQuestionCopyWith<$Res>? get question;
}

/// @nodoc
class _$ChatResponseCopyWithImpl<$Res> implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._self, this._then);

  final ChatResponse _self;
  final $Res Function(ChatResponse) _then;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = freezed,
    Object? nextStep = freezed,
    Object? chatbotMode = freezed,
    Object? question = freezed,
    Object? answers = freezed,
    Object? questionId = freezed,
    Object? questionText = freezed,
    Object? result = freezed,
    Object? reply = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: freezed == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      nextStep: freezed == nextStep
          ? _self.nextStep
          : nextStep // ignore: cast_nullable_to_non_nullable
              as String?,
      chatbotMode: freezed == chatbotMode
          ? _self.chatbotMode
          : chatbotMode // ignore: cast_nullable_to_non_nullable
              as bool?,
      question: freezed == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as ChatQuestion?,
      answers: freezed == answers
          ? _self.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<ChatAnswer>?,
      questionId: freezed == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String?,
      questionText: freezed == questionText
          ? _self.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String?,
      result: freezed == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      reply: freezed == reply
          ? _self.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ChatResponse
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

/// Adds pattern-matching-related methods to [ChatResponse].
extension ChatResponsePatterns on ChatResponse {
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
    TResult Function(_ChatResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatResponse() when $default != null:
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
    TResult Function(_ChatResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatResponse():
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
    TResult? Function(_ChatResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatResponse() when $default != null:
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
            @JsonKey(name: 'session_id') String? sessionId,
            @JsonKey(name: 'next_step') String? nextStep,
            @JsonKey(name: 'chatbot_mode') bool? chatbotMode,
            ChatQuestion? question,
            List<ChatAnswer>? answers,
            @JsonKey(name: 'question_id') String? questionId,
            @JsonKey(name: 'question_text') String? questionText,
            Map<String, dynamic>? result,
            String? reply)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatResponse() when $default != null:
        return $default(
            _that.sessionId,
            _that.nextStep,
            _that.chatbotMode,
            _that.question,
            _that.answers,
            _that.questionId,
            _that.questionText,
            _that.result,
            _that.reply);
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
            @JsonKey(name: 'session_id') String? sessionId,
            @JsonKey(name: 'next_step') String? nextStep,
            @JsonKey(name: 'chatbot_mode') bool? chatbotMode,
            ChatQuestion? question,
            List<ChatAnswer>? answers,
            @JsonKey(name: 'question_id') String? questionId,
            @JsonKey(name: 'question_text') String? questionText,
            Map<String, dynamic>? result,
            String? reply)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatResponse():
        return $default(
            _that.sessionId,
            _that.nextStep,
            _that.chatbotMode,
            _that.question,
            _that.answers,
            _that.questionId,
            _that.questionText,
            _that.result,
            _that.reply);
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
            @JsonKey(name: 'session_id') String? sessionId,
            @JsonKey(name: 'next_step') String? nextStep,
            @JsonKey(name: 'chatbot_mode') bool? chatbotMode,
            ChatQuestion? question,
            List<ChatAnswer>? answers,
            @JsonKey(name: 'question_id') String? questionId,
            @JsonKey(name: 'question_text') String? questionText,
            Map<String, dynamic>? result,
            String? reply)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatResponse() when $default != null:
        return $default(
            _that.sessionId,
            _that.nextStep,
            _that.chatbotMode,
            _that.question,
            _that.answers,
            _that.questionId,
            _that.questionText,
            _that.result,
            _that.reply);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChatResponse implements ChatResponse {
  const _ChatResponse(
      {@JsonKey(name: 'session_id') this.sessionId,
      @JsonKey(name: 'next_step') this.nextStep,
      @JsonKey(name: 'chatbot_mode') this.chatbotMode,
      this.question,
      final List<ChatAnswer>? answers,
      @JsonKey(name: 'question_id') this.questionId,
      @JsonKey(name: 'question_text') this.questionText,
      final Map<String, dynamic>? result,
      this.reply})
      : _answers = answers,
        _result = result;
  factory _ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String? sessionId;
  @override
  @JsonKey(name: 'next_step')
  final String? nextStep;
  @override
  @JsonKey(name: 'chatbot_mode')
  final bool? chatbotMode;
  @override
  final ChatQuestion? question;
  final List<ChatAnswer>? _answers;
  @override
  List<ChatAnswer>? get answers {
    final value = _answers;
    if (value == null) return null;
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'question_id')
  final String? questionId;
  @override
  @JsonKey(name: 'question_text')
  final String? questionText;
  final Map<String, dynamic>? _result;
  @override
  Map<String, dynamic>? get result {
    final value = _result;
    if (value == null) return null;
    if (_result is EqualUnmodifiableMapView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? reply;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatResponseCopyWith<_ChatResponse> get copyWith =>
      __$ChatResponseCopyWithImpl<_ChatResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatResponse &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.nextStep, nextStep) ||
                other.nextStep == nextStep) &&
            (identical(other.chatbotMode, chatbotMode) ||
                other.chatbotMode == chatbotMode) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            const DeepCollectionEquality().equals(other._result, _result) &&
            (identical(other.reply, reply) || other.reply == reply));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      nextStep,
      chatbotMode,
      question,
      const DeepCollectionEquality().hash(_answers),
      questionId,
      questionText,
      const DeepCollectionEquality().hash(_result),
      reply);

  @override
  String toString() {
    return 'ChatResponse(sessionId: $sessionId, nextStep: $nextStep, chatbotMode: $chatbotMode, question: $question, answers: $answers, questionId: $questionId, questionText: $questionText, result: $result, reply: $reply)';
  }
}

/// @nodoc
abstract mixin class _$ChatResponseCopyWith<$Res>
    implements $ChatResponseCopyWith<$Res> {
  factory _$ChatResponseCopyWith(
          _ChatResponse value, $Res Function(_ChatResponse) _then) =
      __$ChatResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'next_step') String? nextStep,
      @JsonKey(name: 'chatbot_mode') bool? chatbotMode,
      ChatQuestion? question,
      List<ChatAnswer>? answers,
      @JsonKey(name: 'question_id') String? questionId,
      @JsonKey(name: 'question_text') String? questionText,
      Map<String, dynamic>? result,
      String? reply});

  @override
  $ChatQuestionCopyWith<$Res>? get question;
}

/// @nodoc
class __$ChatResponseCopyWithImpl<$Res>
    implements _$ChatResponseCopyWith<$Res> {
  __$ChatResponseCopyWithImpl(this._self, this._then);

  final _ChatResponse _self;
  final $Res Function(_ChatResponse) _then;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = freezed,
    Object? nextStep = freezed,
    Object? chatbotMode = freezed,
    Object? question = freezed,
    Object? answers = freezed,
    Object? questionId = freezed,
    Object? questionText = freezed,
    Object? result = freezed,
    Object? reply = freezed,
  }) {
    return _then(_ChatResponse(
      sessionId: freezed == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      nextStep: freezed == nextStep
          ? _self.nextStep
          : nextStep // ignore: cast_nullable_to_non_nullable
              as String?,
      chatbotMode: freezed == chatbotMode
          ? _self.chatbotMode
          : chatbotMode // ignore: cast_nullable_to_non_nullable
              as bool?,
      question: freezed == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as ChatQuestion?,
      answers: freezed == answers
          ? _self._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<ChatAnswer>?,
      questionId: freezed == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String?,
      questionText: freezed == questionText
          ? _self.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String?,
      result: freezed == result
          ? _self._result
          : result // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      reply: freezed == reply
          ? _self.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ChatResponse
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
mixin _$ChatQuestion {
  String? get id;
  String? get text;
  List<ChatAnswer>? get answers;

  /// Create a copy of ChatQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatQuestionCopyWith<ChatQuestion> get copyWith =>
      _$ChatQuestionCopyWithImpl<ChatQuestion>(
          this as ChatQuestion, _$identity);

  /// Serializes this ChatQuestion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatQuestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other.answers, answers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, text, const DeepCollectionEquality().hash(answers));

  @override
  String toString() {
    return 'ChatQuestion(id: $id, text: $text, answers: $answers)';
  }
}

/// @nodoc
abstract mixin class $ChatQuestionCopyWith<$Res> {
  factory $ChatQuestionCopyWith(
          ChatQuestion value, $Res Function(ChatQuestion) _then) =
      _$ChatQuestionCopyWithImpl;
  @useResult
  $Res call({String? id, String? text, List<ChatAnswer>? answers});
}

/// @nodoc
class _$ChatQuestionCopyWithImpl<$Res> implements $ChatQuestionCopyWith<$Res> {
  _$ChatQuestionCopyWithImpl(this._self, this._then);

  final ChatQuestion _self;
  final $Res Function(ChatQuestion) _then;

  /// Create a copy of ChatQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? text = freezed,
    Object? answers = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      answers: freezed == answers
          ? _self.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<ChatAnswer>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatQuestion].
extension ChatQuestionPatterns on ChatQuestion {
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
    TResult Function(_ChatQuestion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatQuestion() when $default != null:
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
    TResult Function(_ChatQuestion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatQuestion():
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
    TResult? Function(_ChatQuestion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatQuestion() when $default != null:
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
    TResult Function(String? id, String? text, List<ChatAnswer>? answers)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatQuestion() when $default != null:
        return $default(_that.id, _that.text, _that.answers);
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
    TResult Function(String? id, String? text, List<ChatAnswer>? answers)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatQuestion():
        return $default(_that.id, _that.text, _that.answers);
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
    TResult? Function(String? id, String? text, List<ChatAnswer>? answers)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatQuestion() when $default != null:
        return $default(_that.id, _that.text, _that.answers);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChatQuestion implements ChatQuestion {
  const _ChatQuestion({this.id, this.text, final List<ChatAnswer>? answers})
      : _answers = answers;
  factory _ChatQuestion.fromJson(Map<String, dynamic> json) =>
      _$ChatQuestionFromJson(json);

  @override
  final String? id;
  @override
  final String? text;
  final List<ChatAnswer>? _answers;
  @override
  List<ChatAnswer>? get answers {
    final value = _answers;
    if (value == null) return null;
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of ChatQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatQuestionCopyWith<_ChatQuestion> get copyWith =>
      __$ChatQuestionCopyWithImpl<_ChatQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatQuestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._answers, _answers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, text, const DeepCollectionEquality().hash(_answers));

  @override
  String toString() {
    return 'ChatQuestion(id: $id, text: $text, answers: $answers)';
  }
}

/// @nodoc
abstract mixin class _$ChatQuestionCopyWith<$Res>
    implements $ChatQuestionCopyWith<$Res> {
  factory _$ChatQuestionCopyWith(
          _ChatQuestion value, $Res Function(_ChatQuestion) _then) =
      __$ChatQuestionCopyWithImpl;
  @override
  @useResult
  $Res call({String? id, String? text, List<ChatAnswer>? answers});
}

/// @nodoc
class __$ChatQuestionCopyWithImpl<$Res>
    implements _$ChatQuestionCopyWith<$Res> {
  __$ChatQuestionCopyWithImpl(this._self, this._then);

  final _ChatQuestion _self;
  final $Res Function(_ChatQuestion) _then;

  /// Create a copy of ChatQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? text = freezed,
    Object? answers = freezed,
  }) {
    return _then(_ChatQuestion(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      answers: freezed == answers
          ? _self._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<ChatAnswer>?,
    ));
  }
}

/// @nodoc
mixin _$ChatAnswer {
  String? get id;
  String? get text;

  /// Create a copy of ChatAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatAnswerCopyWith<ChatAnswer> get copyWith =>
      _$ChatAnswerCopyWithImpl<ChatAnswer>(this as ChatAnswer, _$identity);

  /// Serializes this ChatAnswer to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatAnswer &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text);

  @override
  String toString() {
    return 'ChatAnswer(id: $id, text: $text)';
  }
}

/// @nodoc
abstract mixin class $ChatAnswerCopyWith<$Res> {
  factory $ChatAnswerCopyWith(
          ChatAnswer value, $Res Function(ChatAnswer) _then) =
      _$ChatAnswerCopyWithImpl;
  @useResult
  $Res call({String? id, String? text});
}

/// @nodoc
class _$ChatAnswerCopyWithImpl<$Res> implements $ChatAnswerCopyWith<$Res> {
  _$ChatAnswerCopyWithImpl(this._self, this._then);

  final ChatAnswer _self;
  final $Res Function(ChatAnswer) _then;

  /// Create a copy of ChatAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? text = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatAnswer].
extension ChatAnswerPatterns on ChatAnswer {
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
    TResult Function(_ChatAnswer value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatAnswer() when $default != null:
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
    TResult Function(_ChatAnswer value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatAnswer():
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
    TResult? Function(_ChatAnswer value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatAnswer() when $default != null:
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
    TResult Function(String? id, String? text)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatAnswer() when $default != null:
        return $default(_that.id, _that.text);
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
    TResult Function(String? id, String? text) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatAnswer():
        return $default(_that.id, _that.text);
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
    TResult? Function(String? id, String? text)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatAnswer() when $default != null:
        return $default(_that.id, _that.text);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChatAnswer implements ChatAnswer {
  const _ChatAnswer({this.id, this.text});
  factory _ChatAnswer.fromJson(Map<String, dynamic> json) =>
      _$ChatAnswerFromJson(json);

  @override
  final String? id;
  @override
  final String? text;

  /// Create a copy of ChatAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatAnswerCopyWith<_ChatAnswer> get copyWith =>
      __$ChatAnswerCopyWithImpl<_ChatAnswer>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatAnswerToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatAnswer &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text);

  @override
  String toString() {
    return 'ChatAnswer(id: $id, text: $text)';
  }
}

/// @nodoc
abstract mixin class _$ChatAnswerCopyWith<$Res>
    implements $ChatAnswerCopyWith<$Res> {
  factory _$ChatAnswerCopyWith(
          _ChatAnswer value, $Res Function(_ChatAnswer) _then) =
      __$ChatAnswerCopyWithImpl;
  @override
  @useResult
  $Res call({String? id, String? text});
}

/// @nodoc
class __$ChatAnswerCopyWithImpl<$Res> implements _$ChatAnswerCopyWith<$Res> {
  __$ChatAnswerCopyWithImpl(this._self, this._then);

  final _ChatAnswer _self;
  final $Res Function(_ChatAnswer) _then;

  /// Create a copy of ChatAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? text = freezed,
  }) {
    return _then(_ChatAnswer(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
