import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/menu_item.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/menu_item_observable_stream.dart';
import 'package:nmwhitelabel/app/utilities/validators.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class MenuItemDetailsModel with MenuItemValidators, ChangeNotifier {
  final Database database;
  final Session session;
  final Menu? menu;
  final MenuItemObservableStream? menuItemStream;
  String? id;
  String? name;
  String? description;
  int? sequence;
  bool? hidden;
  List<String?>? optionIdList;
  double price;
  bool isLoading;
  bool submitted;

  List<int?> menuSequences = [];
  Map<dynamic, dynamic>? restaurantObjectStagedOptions;
  Map<String?, Option?> stagedOptions = {};
  Restaurant? get restaurant => session.currentRestaurant;

  MenuItemDetailsModel(
      {required this.database,
       required this.session,
       required this.menu,
       required this.menuItemStream,
        this.id,
        this.name,
        this.description,
        this.sequence,
        this.hidden,
        this.price = 0.00,
        this.optionIdList,
        this.isLoading = false,
        this.submitted = false,
      }) {
    restaurantObjectStagedOptions = restaurant!.restaurantOptions;
    if (id == null || id == '') {
      id = documentIdFromCurrentDate();
    }
    restaurant!.restaurantMenus!.forEach((key, value) {
      if (key == menu!.id) {
        final Map<String, dynamic> entry = value;
        entry.forEach((key, value) {
          if (key.toString().length > 20) {
            if (sequence != value['sequence']) {
              menuSequences.add(value['sequence']);
            }
          }
        });
      }
    });
  }
  
  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    final item = MenuItem(
      id: id,
      menuId: menu!.id,
      restaurantId: restaurant!.id,
      name: name,
      description: description,
      sequence: sequence,
      hidden: hidden,
      price: price,
      options: optionIdList,
    );
    try {
      final Map<dynamic, dynamic> items = restaurant!.restaurantMenus![menu!.id];
      if (items.containsKey(id)) {
        restaurant!.restaurantMenus![menu!.id].update(id, (_) => item.toMap());
      } else {
        restaurant!.restaurantMenus![menu!.id].putIfAbsent(id, () => item.toMap());
      }
      restaurant!.restaurantOptions = restaurantObjectStagedOptions;
      menuItemStream!.broadcastEvent(restaurant!.restaurantMenus![menu!.id]);
      await Restaurant.setRestaurant(database, restaurant);
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText => 'Save';

  bool get canSave => menuItemNameValidator.isValid(name) &&
      menuItemPriceValidator.isValid(price);

  String? get menuItemNameErrorText {
    bool showErrorText = !menuItemNameValidator.isValid(name);
    return showErrorText ? invalidMenuItemNameText : null;
  }

  String? get menuItemDescriptionErrorText {
    bool showErrorText = !menuItemDescriptionValidator.isValid(description);
    return showErrorText ? invalidMenuItemDescriptionText : null;
  }

  String? get menuItemPriceErrorText {
    bool showErrorText = !menuItemPriceValidator.isValid(price);
    return showErrorText ? invalidMenuItemPriceText : null;
  }

  void copyMenuItem(String? newMenuId) async {
    final Map<String, dynamic> items = restaurant!.restaurantMenus![newMenuId];
    List<int> sequences = [];
    items.forEach((key, value) {
      if (key.length > 20) {
        sequences.add(value['sequence']);
      }
    });
    int targetMenuSequence = 1;
    if (sequences.length > 0) {
      targetMenuSequence = sequences.reduce(max) + 1;
    }
    final item = MenuItem(
      id: id,
      menuId: newMenuId,
      restaurantId: restaurant!.id,
      name: name,
      description: description,
      sequence: targetMenuSequence,
      hidden: hidden,
      price: price,
      options: optionIdList,
    );
    try {
      if (items.containsKey(id)) {
        restaurant!.restaurantMenus![newMenuId].update(id, (_) => item.toMap());
      } else {
        restaurant!.restaurantMenus![newMenuId].putIfAbsent(id, () => item.toMap());
      }
      await Restaurant.setRestaurant(database, restaurant);
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateMenuItemName(String name) => updateWith(name: name);

  void updateMenuItemDescription(String description) => updateWith(description: description);

  void updateMenuItemPrice(String price) {
   var amount = price.replaceAll(RegExp(r','), '.');
   updateWith(price: double.tryParse(amount));
  }

  void updateSequence(int sequence) => updateWith(sequence: sequence);

  bool optionCheck(String? key) => optionIdList!.contains(key);

  void updateOptionIdList(String? key, bool value) {
    final newOptionIdList = optionIdList;
    Map<String, dynamic> option = restaurantObjectStagedOptions![key];
    stagedOptions[key] = Option.fromMap(option, null);
    List<dynamic> usedByMenuItems = option['usedByMenuItems'] ?? [];
    if (value) {
      newOptionIdList!.add(key);
      usedByMenuItems.add(id);
    } else {
      newOptionIdList!.remove(key);
      usedByMenuItems.remove(id);
    }
    restaurantObjectStagedOptions![key]['usedByMenuItems'] = usedByMenuItems;
    stagedOptions[key]!.usedByMenuItems = usedByMenuItems;
    updateWith(optionIdList: newOptionIdList);
  }

  void updateHidden(bool? hidden) => updateWith(hidden: hidden);

  void updateWith({
    String? name,
    String? description,
    int? sequence,
    bool? hidden,
    double? price,
    List<String?>? optionIdList,
    bool? isLoading,
    bool? submitted,
  }) {
    this.name = name ?? this.name;
    this.description = description ?? this.description;
    this.sequence = sequence ?? this.sequence;
    this.hidden = hidden ?? this.hidden;
    this.price = price ?? this.price;
    this.optionIdList = optionIdList ?? this.optionIdList;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
