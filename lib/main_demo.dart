

import 'package:fulupo/flavours.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.demo;
  await runner.main();
}
