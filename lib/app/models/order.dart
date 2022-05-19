import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

const int ORDER_ON_HOLD = 0;
const int ORDER_PLACED = 1;
const int ORDER_ACCEPTED = 2;
const int ORDER_READY = 3;
const int ORDER_DELIVERING = 4;
const int ORDER_REJECTED_BUSY = 10;
const int ORDER_REJECTED_STOCK = 11;
const int ORDER_CANCELLED = 12;
const int ORDER_CLOSED = 13;

class Order {
  String? id;
  int? orderNumber;
  final String? restaurantId;
  final String? restaurantName;
  final String? managerId;
  String? userId;
  double? timestamp;
  int? status;
  String? name;
  String? deliveryAddress;
  String? telephone;
  Position? deliveryPosition;
  String? paymentMethod;
  Map<String, double?>? paymentMethods;
  String? deliveryOption;
  List<Map<dynamic, dynamic>>? orderItems;
  String? notes;
  double? tip;
  double? discount;
  double? cashReceived;
  bool? isActive;
  bool? isBlocked;

  Order({
    this.id,
    this.orderNumber,
    this.restaurantId,
    this.restaurantName,
    this.managerId,
    this.userId,
    this.timestamp,
    this.status,
    this.name,
    this.deliveryAddress,
    this.telephone,
    this.deliveryPosition,
    this.paymentMethod,
    this.paymentMethods,
    this.deliveryOption,
    this.orderItems,
    this.notes,
    this.tip,
    this.discount,
    this.cashReceived,
    this.isActive,
    this.isBlocked,
  });

  static Order fromMap(Map<dynamic, dynamic>? data, String? documentID) {
    // if (data == null) {
    //   return null;
    // }
    final geoPoint = data!['deliveryPosition'] as GeoPoint;
    List<Map<dynamic, dynamic>> orderItems;
    if (data['orderItems'] != null) {
      orderItems = List.from(data['orderItems']);
    } else {
      orderItems = [];
    }
    Map<String, dynamic> paymentMethodsDynamic;
    Map<String, double> paymentMethods = Map<String, double>();
    if (data['paymentMethods'] != null) {
      paymentMethodsDynamic = Map.from(data['paymentMethods']);
      for (final paymentMethod in paymentMethodsDynamic.entries) {
        paymentMethods.putIfAbsent(paymentMethod.key, () => paymentMethod.value.toDouble());
      }
    }
    return Order(
      id: data['id'],
      orderNumber: data['orderNumber'],
      restaurantId: data['restaurantId'],
      restaurantName: data['restaurantName'],
      managerId: data['managerId'],
      userId: data['userId'],
      timestamp: data['timestamp'].toDouble(),
      status: data['status'],
      name: data['name'],
      deliveryAddress: data['deliveryAddress'],
      telephone: data['telephone'],
      deliveryPosition: Position(
          latitude: geoPoint.latitude,
          longitude: geoPoint.longitude,
          speedAccuracy: 0,
          speed: 0,
          heading: 0,
          accuracy: 0,
          altitude: 0,
          timestamp: DateTime.now()
         ),
      paymentMethod: data['paymentMethod'],
      paymentMethods: paymentMethods,
      deliveryOption: data['deliveryOption'],
      orderItems: orderItems,
      notes: data['notes'],
      tip: data['tip'].toDouble() ?? 0,
      discount: data['discount'].toDouble() ?? 0,
      cashReceived: data['cashReceived'].toDouble() ?? 0,
      isActive: data['isActive'],
      isBlocked: data['isBlocked'],
    );
  }

  double get orderTotal {
    double total = 0;
    orderItems!.forEach((element) {
      Map<dynamic, dynamic> item = element;
      total += item['lineTotal'];
    });
    return total;
  }

  double get netTotal {
    return (orderTotal - (orderTotal * discount!)) + tip!;
  }

  Map<String, dynamic> toMap() {
    final GeoPoint geoPoint =
    GeoPoint(deliveryPosition!.latitude, deliveryPosition!.longitude);
    bool activeFlag = status! < 10 ? true : false;
    return {
      'id': id,
      'orderNumber': orderNumber,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'managerId': managerId,
      'userId': userId,
      'timestamp': timestamp,
      'status': status,
      'name': name,
      'deliveryAddress': deliveryAddress,
      'telephone': telephone,
      'deliveryPosition': geoPoint,
      'paymentMethod': paymentMethod ?? '',
      'paymentMethods': paymentMethods ?? {},
      'deliveryOption': deliveryOption ?? '',
      'orderItems': orderItems ?? [],
      'notes': notes,
      'tip': tip,
      'discount': discount,
      'cashReceived': cashReceived,
      'isActive': activeFlag,
      'isBlocked': isBlocked ?? false,
    };
  }

  String get statusString {
    String stString = '';
    switch (status) {
      case ORDER_ON_HOLD:
        stString = 'On hold';
        break;
      case ORDER_PLACED:
        stString = 'Placed, pending';
        break;
      case ORDER_ACCEPTED:
        stString = 'Accepted, in progress';
        break;
      case ORDER_READY:
        stString = 'Ready';
        break;
      case ORDER_REJECTED_BUSY:
        stString = 'Rejected by staff: too busy or closed';
        break;
      case ORDER_REJECTED_STOCK:
        stString = 'Rejected by staff: out of stock';
        break;
      case ORDER_CANCELLED:
        stString = 'Cancelled by patron';
        break;
      case ORDER_DELIVERING:
        stString = 'Being delivered';
        break;
      case ORDER_CLOSED:
        stString = 'Delivered, closed';
        break;
    }
    return stString;
  }

  @override
  String toString() {
    return 'id: $id, orderNumber: $orderNumber, restaurantId: $restaurantId, restaurantName: $restaurantName, managerId: $managerId, userId: $userId, timestamp: $timestamp, status: $status, name: $name, deliveryAddress: $deliveryAddress, telephone: $telephone, paymentMethod: $paymentMethod, deliveryOption: $deliveryOption, orderItems: $orderItems, notes: $notes, tip: $tip, disount: $discount, isBlocked: $isBlocked';
  }

}
