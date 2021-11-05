import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/order.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/models/user_message.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class ViewOrderModel with ChangeNotifier {
  final Database database;
  final Session session;
  Order? order;
  Map<String, double?> stagedPaymentMethods = {};
  bool? automaticallyCloseOrder;
  bool isLoading;
  bool submitted;

  ViewOrderModel({
    required this.database,
    required this.session,
    required this.order,
    this.automaticallyCloseOrder,
    this.isLoading = false,
    this.submitted = false,
  });

  Future<int> get orderDistance async {
    double distance = Geolocator.distanceBetween(
      session.position!.latitude,
      session.position!.longitude,
      order!.deliveryPosition!.latitude,
      order!.deliveryPosition!.longitude,
    );
    return distance.round();
  }

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    _submitOrder();
    if (!FlavourConfig.isStaff()) {
      _sendMessage(
          session.currentRestaurant!.managerId,
          FlavourConfig.isManager() ? ROLE_MANAGER : ROLE_PATRON,
          ROLE_STAFF,
          'New order to ${session.currentRestaurant!.name}');
    }
  }

  Future<void> _submitOrder() async {
    final double timestamp = dateFromCurrentDate() / 1.0;
    var orderNumber = documentIdFromCurrentDate();
    try {
      order!.id = orderNumber;
      order!.timestamp = timestamp;
      order!.deliveryPosition = session.position;
      order!.status = automaticallyCloseOrder! ? ORDER_CLOSED : ORDER_PLACED;
      database.setOrderTransaction(session.currentRestaurant!.managerId,
          session.currentRestaurant!.id, order);
      session.currentOrder =
          session.emptyOrder(orderNumber, timestamp, database.userId);
      session.userDetails!.orderOnHold = null;
      session.broadcastOrderCounter(0);
      _setUserDetails();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> _sendMessage(
      String? toUid, String fromRole, String toRole, String? type) async {
    final double timestamp = dateFromCurrentDate() / 1.0;
    database.setMessageDetails(UserMessage(
      id: documentIdFromCurrentDate(),
      timestamp: timestamp,
      fromUid: database.userId,
      toUid: toUid,
      restaurantId: session.currentRestaurant!.id,
      fromRole: fromRole,
      toRole: toRole,
      fromName: session.userDetails!.name,
      delivered: false,
      type: type,
      authFlag: false,
      attendedFlag: false,
    ));
  }

  void processOrder(int newOrderStatus) {
    try {
      order!.status = newOrderStatus;
      database.setOrder(order);
      if (newOrderStatus == ORDER_CANCELLED) {
        database.setBundleCounterTransaction(
            session.currentRestaurant!.managerId, 1);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    String? message;
    switch (newOrderStatus) {
      case ORDER_ACCEPTED:
        message = '${session.currentRestaurant!.name} is processing your order!';
        break;
      case ORDER_READY:
        message = 'Your order is ready!';
        break;
      case ORDER_DELIVERING:
        message = 'Your order is on it\'s way!';
        break;
      case ORDER_REJECTED_BUSY:
        message = 'We can\'t process your order at the moment, sorry.';
        break;
      case ORDER_REJECTED_STOCK:
        message = 'We\'re out of stock on one or more items.';
        break;
    }
    if (newOrderStatus != ORDER_CLOSED && newOrderStatus != ORDER_CANCELLED) {
      _sendMessage(order!.userId, ROLE_STAFF, ROLE_PATRON, message);
    }
  }

  void cancelOnHoldOrder() {
    order = null;
    session.userDetails!.orderOnHold = null;
    session.currentOrder = null;
    session.broadcastOrderCounter(0);
    _setUserDetails();
  }

  void _setUserDetails() {
    database.setUserDetails(session.userDetails);
  }

  void updateNotes(String notes) => updateWith(notes: notes);

  void deleteOrderItem(int index) {
    order!.orderItems!.removeAt(index);
    session.currentOrder = order;
    session.userDetails!.orderOnHold = order!.toMap();
    session.broadcastOrderCounter(order!.orderItems!.length);
    _setUserDetails();
    notifyListeners();
  }

  String get primaryButtonText => 'Save';

  bool get canSave => _checkOrder();

  bool get canSettleOrder => order!.paymentMethods!.length > 0;

  bool _checkOrder() {
    int deliveryOptionsAvailable = 0;
    session.currentRestaurant!.foodDeliveryFlags!.forEach((key, value) {
      if (value) deliveryOptionsAvailable++;
    });
    bool deliveryOptionsOk = false;
    if (deliveryOptionsAvailable > 0) {
      if (order!.deliveryOption != '') {
        deliveryOptionsOk = true;
      }
    }
    double orderFinalAmount =
        order!.orderTotal - (order!.orderTotal * order!.discount!) + order!.tip!;
    double? paymentMethodsSum = 0;
    if (order!.paymentMethods!.length > 0) {
      paymentMethodsSum =
          order!.paymentMethods!.values.reduce((sum, element) => sum! + element!);
    }
    return paymentMethodsSum == orderFinalAmount &&
        deliveryOptionsOk &&
        orderFinalAmount > 0;
  }

  void updatePaymentMethod(String key, bool flag) {
    if (order!.status != ORDER_ON_HOLD) {
      return;
    }
    if (flag) {
      updateWith(paymentMethod: key);
    } else {
      updateWith(paymentMethod: '');
    }
  }

  void updatePaymentMethods(String key, bool? flag) {
    if (order!.status != ORDER_ON_HOLD && FlavourConfig.isPatron()) {
      return;
    }
    if (flag!) {
      stagedPaymentMethods.putIfAbsent(key, () => 0.0);
    } else {
      stagedPaymentMethods.remove(key);
    }
    updateWith(paymentMethods: stagedPaymentMethods);
  }

  void updatePaymentMethodAmount(String key, double? newValue) {
    if (stagedPaymentMethods.containsKey(key)) {
      stagedPaymentMethods.update(key, (value) => newValue);
    } else {
      stagedPaymentMethods.putIfAbsent(key, () => newValue);
    }
  }

  void updateFoodDeliveryOption(String key, bool? flag) {
    if (order!.status != ORDER_ON_HOLD) {
      return;
    }
    if (flag!) {
      updateWith(deliveryOption: key);
    } else {
      updateWith(deliveryOption: '');
    }
  }

  bool paymentOptionCheck(String key) => order!.paymentMethod == key;

  bool paymentOptionsCheck(String key) => order!.paymentMethods!.containsKey(key);

  bool foodDeliveryOptionCheck(String key) => order!.deliveryOption == key;

  bool? canDoThis(int processStep) {
    bool? proceed;
    switch (processStep) {
      case ORDER_ACCEPTED:
        if (order!.status == ORDER_PLACED) {
          proceed = true;
        } else {
          proceed = false;
        }
        break;
      case ORDER_READY:
        if (order!.status == ORDER_ACCEPTED) {
          proceed = true;
        } else {
          proceed = false;
        }
        break;
      case ORDER_REJECTED_BUSY:
      case ORDER_REJECTED_STOCK:
        if (order!.status == ORDER_PLACED) {
          proceed = true;
        } else {
          proceed = false;
        }
        break;
      case ORDER_DELIVERING:
        if (order!.status == ORDER_READY && order!.deliveryOption == 'Deliver') {
          proceed = true;
        } else {
          proceed = false;
        }
        break;
      case ORDER_CLOSED:
        if (order!.status == ORDER_READY || order!.status == ORDER_DELIVERING) {
          proceed = true;
        } else {
          proceed = false;
        }
        break;
    }
    return proceed;
  }

  void updateTip(double tip) => updateWith(tip: tip);

  void updateDiscount(double discount) => updateWith(discount: discount);

  void updateCashReceived(double cashReceived) =>
      updateWith(cashReceived: cashReceived);

  void updateAutomaticallyCloseOrder(bool? flag) =>
      updateWith(automaticallyCloseOrder: flag);

  void updateWith({
    String? notes,
    double? tip,
    double? discount,
    double? cashReceived,
    String? paymentMethod,
    Map<String, double?>? paymentMethods,
    String? deliveryOption,
    bool? automaticallyCloseOrder,
    bool? isLoading,
    bool? submitted,
  }) {
    this.order!.notes = notes ?? this.order!.notes;
    this.order!.tip = tip ?? this.order!.tip;
    this.order!.discount = discount ?? this.order!.discount;
    this.order!.cashReceived = cashReceived ?? this.order!.cashReceived;
    this.order!.paymentMethod = paymentMethod ?? this.order!.paymentMethod;
    this.order!.paymentMethods = paymentMethods ?? this.order!.paymentMethods;
    this.order!.deliveryOption = deliveryOption ?? this.order!.deliveryOption;
    this.automaticallyCloseOrder =
        automaticallyCloseOrder ?? this.automaticallyCloseOrder;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
