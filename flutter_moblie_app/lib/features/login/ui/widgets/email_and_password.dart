// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/helpers/app_regex.dart';
// import '../../../../core/helpers/spacing.dart';
// import '../../../../core/widgets/app_text_form_filed.dart';
// import '../../logic_cubit/login_cubit.dart';
// import 'password_validations.dart';
//
// class EmailAndPassword extends StatefulWidget {
//   const EmailAndPassword({
//     super.key,
//   });
//
//   @override
//   State<EmailAndPassword> createState() => _EmailAndPasswordState();
// }
//
// class _EmailAndPasswordState extends State<EmailAndPassword> {
//   bool isObscureText = true;
//   bool hasLowercase = false;
//   bool hasUppercase = false;
//   bool hasSpecialCharacters = false;
//   bool hasNumber = false;
//   bool hasMinLength = false;
//   final _formKey = GlobalKey<FormState>();
//   late final LoginCubit _loginCubit;
//
//   @override
//   void initState() {
//     super.initState();
//     _loginCubit = context.read<LoginCubit>();
//     _loginCubit.passwordController.addListener(_updatePasswordValidations);
//   }
//
//   void _updatePasswordValidations() {
//     setState(() {
//       hasLowercase = AppRegex.hasLowerCase(_loginCubit.passwordController.text);
//       hasUppercase = AppRegex.hasUpperCase(_loginCubit.passwordController.text);
//       hasSpecialCharacters = AppRegex.hasSpecialCharacter(_loginCubit.passwordController.text);
//       hasNumber = AppRegex.hasNumber(_loginCubit.passwordController.text);
//       hasMinLength = AppRegex.hasMinLength(_loginCubit.passwordController.text);
//     });
//   }
//
//   @override
//   void dispose() {
//     _loginCubit.passwordController.removeListener(_updatePasswordValidations);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           AppTextFormField(
//             hintText: 'Email',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               } else if (!AppRegex.isEmailValid(value)) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//             controller: _loginCubit.emailController,
//           ),
//           verticalSpace(18),
//           AppTextFormField(
//             hintText: 'Password',
//             controller: _loginCubit.passwordController,
//             isObscureText: isObscureText,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your password';
//               }
//               return null;
//             },
//             suffixIcon: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   isObscureText = !isObscureText;
//                 });
//               },
//               child: Icon(
//                 isObscureText ? Icons.visibility_off : Icons.visibility,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           if (_loginCubit.passwordController.text.isNotEmpty) ...[
//             verticalSpace(24),
//             PasswordValidations(
//               hasLowercase: hasLowercase,
//               hasUpperCase: hasUppercase,
//               hasSpecialCharacters: hasSpecialCharacters,
//               hasNumber: hasNumber,
//               hasMinLength: hasMinLength,
//             ),
//           ],
//         ],
//       ),
//     );
//   }