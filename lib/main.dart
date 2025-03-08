import 'package:flutter/material.dart';
import 'package:messenger_app/config/theme/app_theme.dart';
import 'package:messenger_app/data/services/service_locator.dart';
import 'package:messenger_app/presentation/screens/auth/login_screen.dart';
import 'package:messenger_app/router/app_router.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messenger app',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}
