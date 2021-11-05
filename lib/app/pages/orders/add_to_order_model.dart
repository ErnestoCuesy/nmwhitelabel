import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/order_item.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class AddToOrderModel with ChangeNotifier {
  final Database database;
  final Session session;
  String? menuCode;
  Map<dynamic, dynamic>? item;
  Map<dynamic, dynamic>? options;
  bool isLoading;
  bool submitted;
  List<String> menuItemOptions = [];
  List<String> tempMenuItemOptions = [];
  Map<String?, int> optionsSelectionCounters = Map<String?, int>();
  int quantity = 1;
  String menuCodeAndItemName = '';

  AddToOrderModel(
      {required this.database,
        required this.session,
        required this.menuCode,
        required this.item,
        required this.options,
        this.isLoading = false,
        this.submitted = false,
      });

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    _addMenuItemToOrder();
  }

  void _addMenuItemToOrder() {
    final orderItem = OrderItem(
      id: documentIdFromCurrentDate(),
      orderId: session.currentOrder!.id,
      menuCode: menuCode,
      name: item!['name'],
      quantity: quantity,
      price: item!['price'],
      lineTotal: item!['price'] * quantity,
      options: tempMenuItemOptions,
    ).toMap();
    session.currentOrder!.orderItems!.add(orderItem);
    session.broadcastOrderCounter(session.currentOrder!.orderItems!.length);
    session.userDetails!.orderOnHold = session.currentOrder!.toMap();
    database.setUserDetails(session.userDetails);
  }

  String get primaryButtonText => 'Save';

  bool get canSave => _optionsAreValid();

  bool _optionsAreValid() {
    if (item!['options'].isEmpty) {
      return true;
    }
    if (optionsSelectionCounters.isEmpty) {
      return false;
    }
    bool optionsAreValid = true;
    item!['options'].forEach((key) {
      Map<dynamic, dynamic> optionValue = options![key];
      final maxAllowed = optionValue['numberAllowed'];
      if (optionsSelectionCounters[optionValue['name']] == null ||
          optionsSelectionCounters[optionValue['name']]! > maxAllowed ||
          optionsSelectionCounters[optionValue['name']] == 0) {
        optionsAreValid = false;
      }
    });
    return optionsAreValid;
  }

  void updateQuantity(int quantity) {
    final qty = this.quantity += quantity;
    updateWith(quantity: qty);
  }

  void updateOptionsList(String? key, String option, bool addFlag) {
      if (addFlag) {
        tempMenuItemOptions.add(option);
        if (optionsSelectionCounters.containsKey(key)) {
          optionsSelectionCounters.update(key, (value) => value + 1);
        } else {
          optionsSelectionCounters.putIfAbsent(key, () => 1);
        }
      } else {
        tempMenuItemOptions.remove(option);
        if (optionsSelectionCounters.containsKey(key)) {
          optionsSelectionCounters.update(key, (value) => value - 1);
        } else {
          optionsSelectionCounters.putIfAbsent(key, () => 0);
        }
      }
      updateWith(menuItemOptions: tempMenuItemOptions);
  }

  bool optionCheck(String key) => menuItemOptions.contains(key);

  void updateWith({
    List<String>? menuItemOptions,
    int? quantity,
    bool? isLoading,
    bool? submitted,
  }) {
    this.menuItemOptions = menuItemOptions ?? this.menuItemOptions;
    this.quantity = quantity ?? this.quantity;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
