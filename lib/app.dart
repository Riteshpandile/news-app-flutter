import 'package:flutter/material.dart';
import 'package:newsapp/Core/routers/app_router.dart';
import 'core/const/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'News Intelligence',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        fontFamily: 'Roboto',
      ),
      routerConfig: appRouter,
    );
  }
}
