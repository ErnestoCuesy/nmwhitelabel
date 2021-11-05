class APIPath {
  // Root collections
  static String userDetails(String? uid) => 'users/$uid/';
  static String messages() => 'messages';
  static String message(String? id) => 'messages/$id';
  static String authorization(String? restaurantId) => 'authorizations/$restaurantId';
  static String authorizations() => 'authorizations';
  static String restaurant(String? restaurantId) => 'restaurants/$restaurantId';
  static String restaurants() => 'restaurants';
  static String order(String? orderId) => 'orders/$orderId';
  static String orders() => 'orders';
  static String bundle(String? emailOrManagerId, String? bundleId) => 'bundles/$emailOrManagerId/bundles/$bundleId';
  static String bundles(String? emailOrManagerId) => 'bundles/$emailOrManagerId/bundles';
  static String bundleOrdersCounter(String? managerId) => 'bundles/$managerId/bundles/counter';
  static String itemImage(String? restaurantId, int? itemImageId) => 'itemImages/$restaurantId/images/$itemImageId';
  static String itemImages(String? restaurantId) => 'itemImages/$restaurantId/images';
  static String itemImg(String? restaurantId) => 'itemImages/$restaurantId';
  // Restaurant collections
  static String orderNumberCounter(String? restaurantId) => 'restaurants/$restaurantId/orderNumbers';
  static String orderNumberCounterDelete(String? restaurantId) => 'restaurants/$restaurantId/orderNumbers/$restaurantId';
}