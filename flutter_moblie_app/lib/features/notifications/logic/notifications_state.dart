part of 'notifications_cubit.dart';

class NotificationsState {
  const NotificationsState._();

  factory NotificationsState.initial() = InitialState;
  factory NotificationsState.loading() = LoadingState;
  factory NotificationsState.success(
      List<NotificationLogModel> notifications) = SuccessState;
  factory NotificationsState.failure(String message) = FailureState;
}

class InitialState extends NotificationsState {
  InitialState() : super._();
}

class LoadingState extends NotificationsState {
  LoadingState() : super._();
}

class SuccessState extends NotificationsState {
  final List<NotificationLogModel> notifications;

  SuccessState(this.notifications) : super._();
}

class FailureState extends NotificationsState {
  final String message;

  FailureState(this.message) : super._();
}
