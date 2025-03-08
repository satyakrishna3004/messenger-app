import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger_app/core/common/custom_button.dart';
import 'package:messenger_app/core/common/custom_text_field.dart';
import 'package:messenger_app/core/utils/ui_utils.dart';
import 'package:messenger_app/data/services/service_locator.dart';
import 'package:messenger_app/logic/cubits/auth/auth_cubit.dart';
import 'package:messenger_app/logic/cubits/auth/auth_state.dart';
import 'package:messenger_app/presentation/home/home_screen.dart';
import 'package:messenger_app/presentation/screens/auth/signup_screen.dart';
import 'package:messenger_app/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
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

  Future<void> handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signIn(
          email: emailController.text,
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
            body: SafeArea(
              child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Welcome back",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Sign in to continue",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey)),
                        SizedBox(
                          height: 30,
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
                          controller: passwordController,
                          focusNode: _passwordFocus,
                          validator: _validatePassword,
                          hintText: "Password",
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icon(Icons.lock_outline),
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
                          onPressed: handleSignIn,
                          text: 'Login',
                          child: state.status == AuthStatus.loading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: RichText(
                              text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(color: Colors.grey[600]),
                                  children: [
                                TextSpan(
                                    text: "SignUp",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             SignupScreen()));
                                        getIt<AppRouter>().push(SignupScreen());
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
