import 'package:flutter/material.dart';
import 'package:fulupo/model/api_validation_model.dart';

class AppConstants {
  static const String appName = 'Farms';

  //API URL Constants
  // static const String BASE_URL = 'https://new.dev-healthplanner.xyz/api/'; //Dev
  static const String BASE_URL =
      'https://upgrade.test-healthplanner.xyz/api/'; //Prod
  static const String imageBaseUrl =
      'https://fulupostore.tsitcloud.com/'; // <- adjust if different
  String fullImg(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return Uri.parse(AppConstants.imageBaseUrl).resolve(path).toString();
  }

  // static final String BASE_URL = AppConfig.instance.baseUrl;
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  static Map<String, String> headers = {
    //"X-API-KEY": "OpalIndiaKeysinUse",
    'Charset': 'utf-8',
    'Accept': 'application/json',
  };
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  static late ApiValidationModel apiValidationModel;
  static const String token = 'token';
  static const String USERMOBILE = 'user_mobile';
  static const String USER_ID ='user_id';

  static const String USERLATITUTE = 'user_latitude';
  static const String USERLONGITUTE = 'user_longitude';
  static const String USERADDRESS = 'user_address';
  static const String ADDRESS_TYPE='SELECTED_ADDRESS_TYPE';
  static const String ADDRESS_NAME='SELECTED_FLAT_HOUSE_NO';
  static const String ADDRESS_ID ='savedAddressId';


  static const String USERNAME = 'user_name';
  static const String USEREMAIL='user_mail';
  static const String USEROTP = 'user_otp';
  static const String Rupees = '₹';
  static const String StoreCode = 'PRIMARY_STORE';
static const String IS_EXISTING_USER = 'is_existing_user';

// Add these to AppConstants
static const String KEY_SELECTED_ADDRESS_TYPE = 'SELECTED_ADDRESS_TYPE'; // Home, Work, Others
static const String KEY_SELECTED_ADDRESS_NAME = 'SELECTED_ADDRESS_NAME'; // Custom name for "Others"
static const String KEY_SELECTED_ADDRESS_FULL = 'SELECTED_ADDRESS_FULL'; // Full address text


  static var imei;
}
