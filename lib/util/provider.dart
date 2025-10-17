

import 'package:flutter/material.dart';

extension ChangeNotifierExt on ChangeNotifier {
  refresh() {

    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    notifyListeners();
  }
}

abstract class CustomChangeNotifier extends ChangeNotifier {
  bool disposed = false;
  CustomChangeNotifier() {
    initState();
  }
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  void refresh() {
    if (!disposed) {
      notifyListeners();
    }
  }

  @protected
  void initState() {}
}
