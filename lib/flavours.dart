enum Flavor {
  dev,
  prod,
  demo,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Fulupo Dev';
      case Flavor.prod:
        return 'Fulupo';
      case Flavor.demo:
        return 'Fulupo Demo';
      default:
        return 'title';
    }
  }
}
