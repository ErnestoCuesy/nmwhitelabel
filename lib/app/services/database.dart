import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearbymenus/app/models/authorizations.dart';
import 'package:nearbymenus/app/models/item_image.dart';
import 'package:nearbymenus/app/models/order.dart';
import 'package:nearbymenus/app/models/bundle.dart';
import 'package:nearbymenus/app/models/user_message.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'api_path.dart';
import 'firestore_service.dart';

abstract class Database {
  String? get userId;
  void setUserId(String uid);

  Future<void> setUserDetails(UserDetails? userDetails);
  Future<void> setRestaurant(Restaurant? restaurant);
  Future<void> setMessageDetails(UserMessage roleNotification);
  Future<void> setAuthorization(
      String? restaurantId, Authorizations authorizations);
  Future<void> setOrder(Order? order);
  Future<void> setBundle(String? email, Bundle orderBundle);
  Future<int?> setBundleCounterTransaction(String? managerId, int quantity);
  Future<void> setOrderTransaction(
      String? managerId, String? restaurantId, Order? order);
  Future<void> setItemImage(ItemImage itemImage);

  Future<void> deleteMessage(String? id);
  Future<void> deleteRestaurant(Restaurant? restaurant);
  Future<void> deleteOrder(Order order);
  Future<void> deleteImage(String restaurantId, int imageId);
  Future<void> deleteUser(String? uid);

  Stream<UserDetails> userDetailsStream();
  Stream<Authorizations> authorizationsStream(String? restaurantId);
  Stream<List<Restaurant>> managerRestaurants(String? managerId);
  Stream<List<UserMessage>> managerMessages(String? uid, String toRole);
  Stream<List<UserMessage>> staffMessages(String? restaurantId, String toRole);
  Stream<List<UserMessage>> patronMessages(String? uid);
  Stream<List<UserMessage>> adminMessages();
  Stream<List<Restaurant>> patronRestaurants();
  Stream<Restaurant> selectedRestaurantStream(String? restaurantId);
  Stream<List<Order>> activeRestaurantOrders(String? restaurantId);
  Stream<List<Order>> inactiveRestaurantOrders(String? restaurantId);
  Stream<List<Order>> dayRestaurantOrders(
      String? restaurantId, DateTime dateTime);
  Stream<List<Order>> userOrders(String? restaurantId, String? uid);
  Stream<List<Order>> blockedOrders(String? managerId);
  Stream<List<ItemImage>> itemImages(String? itemImageId);

  Future<List<ItemImage>> itemImagesSnapshot(String restaurantId);
  Future<UserDetails> userDetailsSnapshot(String uid);
  Future<List<Authorizations>> authorizationsSnapshot();
  Future<int?> ordersLeft(String? uid);
  Future<List<Bundle>> bundlesSnapshot(String? email);
  Future<List<Restaurant>> restaurantSnapshot();
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();
int dateFromCurrentDate() => DateTime.now().millisecondsSinceEpoch;

class FirestoreDatabase implements Database {
  String? uid;
  final _service = FirestoreService.instance;

  @override
  String? get userId => uid;

  @override
  void setUserId(String uid) {
    this.uid = uid;
  }

  @override
  Future<void> setUserDetails(UserDetails? userDetails) async => await _service
      .setData(path: APIPath.userDetails(uid), data: userDetails!.toMap());

  @override
  Future<void> setRestaurant(Restaurant? restaurant) async =>
      await _service.setData(
          path: APIPath.restaurant(restaurant!.id), data: restaurant.toMap());

  @override
  Future<void> setMessageDetails(UserMessage message) async => await _service
      .setData(path: APIPath.message(message.id), data: message.toMap());

  @override
  Future<void> setAuthorization(
          String? restaurantId, Authorizations authorizations) async =>
      await _service.setData(
          path: APIPath.authorization(restaurantId),
          data: authorizations.toMap());

  @override
  Future<void> setOrder(Order? order) async => await _service.setData(
      path: APIPath.order(order!.id), data: order.toMap());

  @override
  Future<void> setBundle(String? email, Bundle orderBundle) async =>
      await _service.setData(
          path: APIPath.bundle(email, orderBundle.id),
          data: orderBundle.toMap());

  @override
  Future<int?> setBundleCounterTransaction(
      String? managerId, int quantity) async {
    return await _service.runUpdateCounterTransaction(
        counterPath: APIPath.bundles(managerId),
        documentId: 'counter',
        fieldName: 'ordersLeft',
        quantity: quantity);
  }

  @override
  Future<void> setOrderTransaction(
      String? managerId, String? restaurantId, Order? order) async {
    await _service.runSetOrderTransaction(
      orderNumberPath: APIPath.orderNumberCounter(restaurantId),
      orderNumberDocumentId: restaurantId,
      orderNumberFieldName: 'lastOrderNumber',
      bundleCounterPath: APIPath.bundles(managerId),
      bundleCounterDocumentId: 'counter',
      bundleCounterFieldName: 'ordersLeft',
      orderPath: APIPath.orders(),
      orderDocumentId: order!.id,
      orderData: order.toMap(),
    );
  }

  @override
  Future<void> setItemImage(ItemImage itemImage) async =>
      await _service.setData(
          path: APIPath.itemImage(itemImage.restaurantId, itemImage.id),
          data: itemImage.toMap());

  @override
  Future<void> deleteMessage(String? id) async =>
      await _service.deleteData(path: APIPath.message(id));

  @override
  Future<void> deleteRestaurant(Restaurant? restaurant) async {
    final FirebaseStorage _storage = FirebaseStorage.instanceFor(
        bucket: 'gs://nearby-menus-be6e3.appspot.com');
    final images = await itemImagesSnapshot(restaurant!.id);
    images.forEach((image) {
      deleteImage(restaurant.id, image.id);
      if (image.url != '') {
        _storage
            .ref()
            .child('images/${restaurant.id}/Image_${image.id}')
            .delete();
      }
    });
    await _service.deleteCollectionData(
        collectionPath: APIPath.orders(),
        fieldName: 'restaurantId',
        fieldValue: restaurant.id);
    await _service.deleteCollectionData(
        collectionPath: APIPath.messages(),
        fieldName: 'restaurantId',
        fieldValue: restaurant.id);
    await _service.deleteData(
        path: APIPath.orderNumberCounterDelete(restaurant.id));
    await _service.deleteData(path: APIPath.authorization(restaurant.id));
    await _service.deleteData(path: APIPath.itemImg(restaurant.id));
    await _service.deleteData(path: APIPath.restaurant(restaurant.id));
  }

  @override
  Future<void> deleteOrder(Order order) async {
    await _service.deleteData(path: APIPath.order(order.id));
  }

  @override
  Future<void> deleteImage(String? restaurantId, int? imageId) async {
    await _service.deleteData(path: APIPath.itemImage(restaurantId, imageId));
  }

  @override
  Future<void> deleteUser(String? uid) async {
    //await _service.deleteData(path: APIPath.bundleOrdersCounter(uid));
    await _service.deleteData(path: APIPath.userDetails(uid));
  }

  @override
  Stream<UserDetails> userDetailsStream() => _service.documentStream(
        path: APIPath.userDetails(uid),
        builder: (data, documentId) => UserDetails.fromMap(data),
      );

  @override
  Stream<Authorizations> authorizationsStream(String? restaurantId) =>
      _service.documentStream(
        path: APIPath.authorization(restaurantId),
        builder: (data, documentId) => Authorizations.fromMap(data, documentId),
      );

  @override
  Stream<List<Restaurant>> managerRestaurants(String? managerId) =>
      _service.collectionStream(
        path: APIPath.restaurants(),
        queryBuilder: managerId != null
            ? (query) => query.where('managerId', isEqualTo: managerId)
            : null,
        builder: (data, documentId) => Restaurant.fromMap(data, documentId),
      );

  @override
  Stream<List<UserMessage>> managerMessages(String? uid, String toRole) =>
      _service.collectionStream(
        path: APIPath.messages(),
        queryBuilder: uid != null
            ? (query) => query
                .where('toUid', isEqualTo: uid)
                .where('toRole', isEqualTo: toRole)
            : null,
        builder: (data, documentId) => UserMessage.fromMap(data, documentId),
      );

  @override
  Stream<List<UserMessage>> staffMessages(
          String? restaurantId, String toRole) =>
      _service.collectionStream(
        path: APIPath.messages(),
        queryBuilder: restaurantId != null
            ? (query) => query
                .where('restaurantId', isEqualTo: restaurantId)
                .where('toRole', isEqualTo: toRole)
            : null,
        builder: (data, documentId) => UserMessage.fromMap(data, documentId),
      );

  @override
  Stream<List<UserMessage>> patronMessages(String? uid) =>
      _service.collectionStream(
        path: APIPath.messages(),
        queryBuilder: uid != null
            ? (query) => query.where('toUid', isEqualTo: uid)
            : null,
        builder: (data, documentId) => UserMessage.fromMap(data, documentId),
      );

  @override
  Stream<List<UserMessage>> adminMessages() => _service.collectionStream(
        path: APIPath.messages(),
        queryBuilder: uid != null
            ? (query) => query.where('toRole', isEqualTo: 'Admin')
            : null,
        builder: (data, documentId) => UserMessage.fromMap(data, documentId),
      );

  @override
  Stream<List<Restaurant>> patronRestaurants() => _service.collectionStream(
        path: APIPath.restaurants(),
        builder: (data, documentId) => Restaurant.fromMap(data, documentId),
      );

  @override
  Stream<Restaurant> selectedRestaurantStream(String? restaurantId) =>
      _service.documentStream(
        path: APIPath.restaurant(restaurantId),
        builder: (data, documentId) => Restaurant.fromMap(data, documentId),
      );

  @override
  Stream<List<Order>> activeRestaurantOrders(String? restaurantId) =>
      _service.collectionStream(
        path: APIPath.orders(),
        queryBuilder: restaurantId != null
            ? (query) => query
                .where('restaurantId', isEqualTo: restaurantId)
                .where('isActive', isEqualTo: true)
                .orderBy('timestamp', descending: true)
            : null,
        builder: (data, documentId) => Order.fromMap(data, documentId),
      );

  @override
  Stream<List<Order>> inactiveRestaurantOrders(String? restaurantId) =>
      _service.collectionStream(
        path: APIPath.orders(),
        queryBuilder: restaurantId != null
            ? (query) => query
                .where('restaurantId', isEqualTo: restaurantId)
                .where('isActive', isEqualTo: false)
                .orderBy('timestamp', descending: true)
            : null,
        builder: (data, documentId) => Order.fromMap(data, documentId),
      );

  @override
  Stream<List<Order>> dayRestaurantOrders(
          String? restaurantId, DateTime dateTime) =>
      _service.collectionStream(
        path: APIPath.orders(),
        queryBuilder: restaurantId != null
            ? (query) => query
                .where('restaurantId', isEqualTo: restaurantId)
                .where('timestamp',
                    isGreaterThanOrEqualTo: dateTime.millisecondsSinceEpoch)
                .where('timestamp',
                    isLessThanOrEqualTo: dateTime
                        .add(Duration(hours: 24))
                        .millisecondsSinceEpoch)
            : null,
        builder: (data, documentId) => Order.fromMap(data, documentId),
      );

  @override
  Stream<List<Order>> userOrders(String? restaurantId, String? uid) =>
      _service.collectionStream(
        path: APIPath.orders(),
        queryBuilder: restaurantId != null
            ? (query) => query
                .where('restaurantId', isEqualTo: restaurantId)
                .where('userId', isEqualTo: uid)
                .orderBy('timestamp', descending: true)
            : null,
        builder: (data, documentId) => Order.fromMap(data, documentId),
      );

  @override
  Stream<List<Order>> blockedOrders(String? managerId) =>
      _service.collectionStream(
        path: APIPath.orders(),
        queryBuilder: managerId != null
            ? (query) => query
                .where('managerId', isEqualTo: managerId)
                .where('isBlocked', isEqualTo: true)
            : null,
        builder: (data, documentId) => Order.fromMap(data, documentId),
      );

  @override
  Stream<List<ItemImage>> itemImages(String? restaurantId) =>
      _service.collectionStream(
        path: APIPath.itemImages(restaurantId),
        builder: (data, documentId) => ItemImage.fromMap(data, documentId),
      );

  @override
  Future<List<ItemImage>> itemImagesSnapshot(String? restaurantId) =>
      _service.collectionSnapshot(
        path: APIPath.itemImages(restaurantId),
        builder: (data, documentId) => ItemImage.fromMap(data, documentId),
      );

  @override
  Future<UserDetails> userDetailsSnapshot(String uid) =>
      _service.documentSnapshot(
        path: APIPath.userDetails(uid),
        builder: (data, documentId) => UserDetails.fromMap(data),
      );

  @override
  Future<List<Authorizations>> authorizationsSnapshot() =>
      _service.collectionSnapshot(
        path: APIPath.authorizations(),
        builder: (data, documentId) => Authorizations.fromMap(data, documentId),
      );

  @override
  Future<int?> ordersLeft(String? managerUid) => _service.documentSnapshot(
        path: APIPath.bundleOrdersCounter(managerUid),
        builder: (data, documentId) => data!['ordersLeft'],
      );

  @override
  Future<List<Bundle>> bundlesSnapshot(String? email) =>
      _service.collectionSnapshot(
        path: APIPath.bundles(email),
        builder: (data, documentId) => Bundle.fromMap(data, documentId),
      );

  @override
  Future<List<Restaurant>> restaurantSnapshot() => _service.collectionSnapshot(
        path: APIPath.restaurants(),
        builder: (data, documentId) => Restaurant.fromMap(data, documentId),
      );
}
