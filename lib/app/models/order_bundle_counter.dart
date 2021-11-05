class OrderBundleCounter {
  int? ordersLeft;
  String? lastUpdated;

  OrderBundleCounter({this.ordersLeft, this.lastUpdated});

  static OrderBundleCounter? fromMap(Map<String, dynamic>? data, String documentID) {
    if (data == null) {
      return null;
    }
    return OrderBundleCounter(
      ordersLeft: data['ordersLeft'],
      lastUpdated: data['lastUpdated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ordersLeft': ordersLeft,
      'lastUpdated': lastUpdated,
    };
  }

}