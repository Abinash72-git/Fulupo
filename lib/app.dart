import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/config/app_theme.dart';
import 'package:fulupo/flavours.dart';
import 'package:fulupo/pages/homepage.dart';
import 'package:fulupo/pages/main_home_page.dart';
import 'package:fulupo/pages/splash_screen_page.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

ValueNotifier<bool> isDevicePreviewEnabled = ValueNotifier<bool>(false);
bool testingMode = kDebugMode && F.appFlavor == Flavor.dev;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDevicePreviewEnabled,
      builder: (context, value, __) {
        return AppThemeData(
          data: AppThemes(ThemeMode.light).customTheme,
          child: DevicePreview(
            enabled: F.appFlavor != Flavor.prod ? value : false,
            // useInheritedMediaQuery:true,
            builder: (context) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (ctx) => UserProvider()),
                  ChangeNotifierProvider(create: (ctx) => GetProvider()),
                ],
                child: MaterialApp(
                  localizationsDelegates: const [],
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(context).textScaler.clamp(
                          minScaleFactor: 0.5,
                          maxScaleFactor: 1.5,
                        ),
                      ),
                      child: child!,
                    );
                  },
                  // supportedLocales: context.supportedLocales,
                  // locale: context.locale,
                  navigatorKey: AppConstants.navigatorKey,
                  // ignore: deprecated_member_use
                  useInheritedMediaQuery: true,
                  onGenerateRoute: RouteGenerator.generateRoute,
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppThemes(ThemeMode.light).theme,
                  darkTheme: AppThemes(ThemeMode.dark).theme,
                  themeMode: ThemeMode.light,
                  home: SplashScreen(),
                  // home: FruitListScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
