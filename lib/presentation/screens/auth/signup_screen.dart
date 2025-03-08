import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger_app/core/common/custom_button.dart';
import 'package:messenger_app/core/common/custom_text_field.dart';
import 'package:messenger_app/core/utils/ui_utils.dart';
import 'package:messenger_app/data/repositories/auth_repository.dart';
import 'package:messenger_app/data/services/service_locator.dart';
import 'package:messenger_app/logic/cubits/auth/auth_cubit.dart';
import 'package:messenger_app/logic/cubits/auth/auth_state.dart';
import 'package:messenger_app/presentation/home/home_screen.dart';
import 'package:messenger_app/router/app_router.dart';
// import 'package:messenger_app/presentation/screens/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final _nameFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    _nameFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username is required";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address (e.g., example@email.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., +1234567890)';
    }
    return null;
  }

  Future<void> handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signUp(
          fullName: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      print("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => HomeScreen()));
            getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
          } else if (state.status == AuthStatus.error && state.error != null) {
            UiUtils.showSnackBar(context, message: state.error!);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Account",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Please fill the details to create an account",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey)),
                        SizedBox(
                          height: 30,
                        ),
                        CustomTextField(
                          controller: nameController,
                          focusNode: _nameFocus,
                          validator: _validateName,
                          hintText: "Full Name",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomTextField(
                          controller: usernameController,
                          focusNode: _usernameFocus,
                          validator: _validateUsername,
                          hintText: "User Name",
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomTextField(
                          controller: emailController,
                          focusNode: _emailFocus,
                          validator: _validateEmail,
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomTextField(
                          controller: phoneController,
                          focusNode: _phoneFocus,
                          validator: _validatePhone,
                          hintText: "Phone Number",
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomTextField(
                          controller: passwordController,
                          focusNode: _passwordFocus,
                          validator: _validatePassword,
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: "Password",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        CustomButton(
                          onPressed: handleSignUp,
                          text: 'Create Account',
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: RichText(
                              text: TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(color: Colors.grey[600]),
                                  children: [
                                TextSpan(
                                    text: "Login",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pop(context);
                                      })
                              ])),
                        ),
                      ],
                    ),
                  )),
            ),
          );
        });
  }
}
