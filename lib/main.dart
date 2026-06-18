import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/constants/services/auth_service.dart';
import 'package:right_routes/core/routes/all_routes.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();

  await AuthService.init();

  bool isLoggedIn = AuthService.isLoggedIn();
  String? token = await AuthService.getAccessToken();
  String? userEmail = AuthService.getUserEmail();

  print('');
  print('═══════════════════════════════════════════════════');
  print('🚀 APP STARTING');
  print('═════════════════════════════════════════════════+══');
  print('📊 Login Status: $isLoggedIn');
  print('🔑 Has Access Token: ${token != null}');
  print('📧 User Email: ${userEmail ?? "No email"}');
  print('═══════════════════════════════════════════════════');

  // 🔥 Decide initial route based on authentication status
  String initialRoute;

  if (isLoggedIn && token != null && token.isNotEmpty) {
    //  User has valid token - Auto login to Home
    print('✅ Valid token found - Auto login to Home');
    print('🏠 Navigating to: ${AppRoutes.homeScreen}');
    initialRoute = AppRoutes.homeScreen;
  } else {
    // ❌ No valid token - Go to login
    print('❌ No valid token - Going to splash/getStarted');
    print('🔐 Navigating to: ${AppRoutes.splashScreen}');
    initialRoute = AppRoutes.splashScreen;
  }

  print('═══════════════════════════════════════════════════');
  print('');

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Right Routes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            // ✅ Dark navy — prevents white flash on any screen
            scaffoldBackgroundColor: const Color(0xFF0B1129),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
          ),
          initialRoute: initialRoute,
          navigatorKey: Get.key,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
