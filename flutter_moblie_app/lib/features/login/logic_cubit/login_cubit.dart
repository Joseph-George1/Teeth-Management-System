// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/helpers/constants.dart';
// import '../../../core/helpers/shared_pref_helper.dart';
// import '../data/models/login_request_body.dart';
// import '../data/repos/login_repo.dart';
//
// class LoginCubit extends Cubit<LoginState> {
//   final LoginRepo _loginRepo;
//
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   LoginCubit(this._loginRepo) : super(LoginInitial());
//
//   Future<void> login() async {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }
//
//     emit(LoginLoading());
//
//     try {
//       final response = await _loginRepo.login(
//         LoginRequestBody(
//           email: emailController.text,
//           password: passwordController.text,
//         ),
//       );
//
//       response.when(
//         success: (loginResponse) async {
//           await _saveUserToken(loginResponse.userData?.token ?? '');
//           emit(LoginSuccess());
//         },
//         failure: (error) {
//           emit(LoginError(message: error.apiErrorModel.message ?? ''));
//         },
//       );
//     } catch (e) {
//       emit(LoginError(message: e.toString()));
//     }
//   }
//
//   Future<void> _saveUserToken(String token) async {
//     await SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, token);
//     DioFactory.setTokenIntoHeaderAfterLogin(token);
//   }
//
//   @override
//   Future<void> close() {
//     emailController.dispose();
//     passwordController.dispose();
//     return super.close();
//   }
// }
//
// // States
// abstract class LoginState {}
//
// class LoginInitial extends LoginState {}
//
// class LoginLoading extends LoginState {}
//
// class LoginSuccess extends LoginState {}
//
// class LoginError extends LoginState {
//   final String message;
//   LoginError({required this.message});
// }