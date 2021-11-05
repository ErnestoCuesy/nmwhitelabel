class Bundle {
  final String? id;
  final String? bundleCode;
  final int? ordersInBundle;

  Bundle({this.id, this.bundleCode, this.ordersInBundle});

  static Bundle fromMap(Map<String, dynamic>? data, String documentID) {
    return Bundle(
      id: data!['id'],
      bundleCode: data['bundleCode'],
      ordersInBundle: data['ordersInBundle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bundleCode': bundleCode,
      'ordersInBundle': ordersInBundle,
    };
  }

}