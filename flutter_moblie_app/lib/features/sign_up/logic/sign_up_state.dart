part of 'sign_up_cubit.dart';

@immutable
sealed class SignUpState {}

final class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String message;
  
  SignUpSuccess(this.message);
}

class SignUpOtpSent extends SignUpState {
  final String phoneNumber;
  final String email;
  final String message;
  
  SignUpOtpSent({
    required this.phoneNumber,
    required this.email,
    this.message = 'تم إرسال رمز التحقق',
  });
}

class SignUpError extends SignUpState {
  final String message;
  
  SignUpError(this.message);
}
