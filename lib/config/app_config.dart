import 'package:fulupo/flavours.dart';

class AppConfig {
  static const AppConfig instance = AppConfig();
  const AppConfig();
  String get baseUrl {
    switch (F.appFlavor) {
      case null:
        // return 'https://tsitfilemanager.in/fawaz/tsit_farms/public/api/';
        return 'https://fulupostore.tsitcloud.com/api/';
      case Flavor.dev:
        // return 'https://tsitfilemanager.in/fawaz/tsit_farms/public/api/';
        return 'https://fulupostore.tsitcloud.com/api/';
      case Flavor.prod:
        // return 'https://tsitfilemanager.in/fawaz/tsit_farms/public/api/';
        return 'https://fulupostore.tsitcloud.com/api/';
      case Flavor.demo:
        return 'https://tabsquareinfotech.com/App/Abinesh_be_work/tsit_farms/public/api/';
    }
  }
}
