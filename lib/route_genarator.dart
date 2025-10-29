import 'package:flutter/material.dart';
import 'package:fulupo/pages/allow_location_page.dart';
import 'package:fulupo/pages/app_page.dart';

import 'package:fulupo/pages/delete_account.dart';
import 'package:fulupo/pages/login_page.dart';
import 'package:fulupo/pages/main_home_page.dart';
import 'package:fulupo/pages/otp.dart';
import 'package:fulupo/pages/register_page.dart';
import 'package:fulupo/pages/setting&privacy/intro_page.dart';
import 'package:fulupo/pages/splash_screen_page.dart';
import 'package:fulupo/pages/subscription_pages/monthly_subscription/monthly_schedule.dart';
import 'package:fulupo/pages/subscription_pages/weekly_subscription/weekly_subscription_page.dart';
import 'package:fulupo/util/extension.dart';

enum AppRouteName {
  splashPage('/splash_screen_page'),
  deletePage('/delete_account'),
  login('/login_page.'),
  homepage('/homepage'),
  mainhomepage('mainhome'),
  allowlocationpage('/allow_location_page'),
  register('/register_page'),
  apppage('/app_page'),
  weeklypage('/weekly_subscription_page'),
  cartpage('/cart_page.dart'),
  montlyschedule('/monthly_schedule'),
  intro_privacy_page('/intro_page'),
  otp('/otp');

  final String value;
  const AppRouteName(this.value);
}

extension AppRouteNameExt on AppRouteName {
  Future<T?> push<T extends Object?>(
    BuildContext context, {
    Object? args,
  }) async {
    return await Navigator.pushNamed<T>(context, value, arguments: args);
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    bool Function(Route<dynamic>) predicate, {
    Object? args,
  }) async {
    return await Navigator.pushNamedAndRemoveUntil<T>(
      context,
      value,
      predicate,
      arguments: args,
    );
  }

  Future<T?> popAndPush<T extends Object?>(
    BuildContext context, {
    Object? args,
  }) async {
    return await Navigator.popAndPushNamed(context, value);
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final name = AppRouteName.values
        .where((element) => element.value == settings.name)
        .firstOrNull;
    // settings.name
    switch (name) {
      case AppRouteName.splashPage:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case AppRouteName.login:
        return MaterialPageRoute(builder: (_) => Login());
              case AppRouteName.mainhomepage:
        return MaterialPageRoute(builder: (_) => MainHomePage());
      case AppRouteName.otp:
        return MaterialPageRoute(
          builder: (_) => OtpPage(selectedCountryCode: args as String, initialOtp: '',),
        );
      case AppRouteName.allowlocationpage:
        return MaterialPageRoute(builder: (_) => AllowLocationPage());
      case AppRouteName.deletePage:
        return MaterialPageRoute(builder: (_) => DeleteAccountPage());
      case AppRouteName.register:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final otp = (args['otp'] as String?) ?? '';
        return MaterialPageRoute(builder: (_) => RegisterPage(Otp: otp));

      case AppRouteName.apppage:
        return MaterialPageRoute(
          builder: (_) => AppPage(tabNumber: args as int),
        );
      case AppRouteName.weeklypage:
        return MaterialPageRoute(builder: (_) => WeeklySubscriptionPage());
      case AppRouteName.montlyschedule:
        return MaterialPageRoute(builder: (_) => MonthlySchedule());
      case AppRouteName.intro_privacy_page:
        return MaterialPageRoute(builder: (_) => IntroPage());


      case null:
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: Text(
                  "Route Error",
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const SafeArea(child: Scaffold(body: Text("Route Error"))),
        );
    }
  }
}
