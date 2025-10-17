
import 'package:flutter/material.dart';
import 'package:fulupo/app.dart';
import 'package:fulupo/config/app_intialize.dart';


Future<void> main() async {
  await AppInitialize.start();
  runApp( MyApp());
}
