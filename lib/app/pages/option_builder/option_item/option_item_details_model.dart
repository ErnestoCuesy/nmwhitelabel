import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/option_item.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/option_item_observable_stream.dart';
import 'package:nmwhitelabel/app/utilities/validators.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class OptionItemDetailsModel with OptionItemValidators, ChangeNotifier {
  final Database database;
  final Session session;
  final Option? option;
  final OptionItemObservableStream? optionItemStream;
  Restaurant? restaurant;
  String? id;
  String? name;
  bool isLoading;
  bool submitted;

  OptionItemDetailsModel(
      {required this.database,
       required this.session,
       required this.option,
       required this.restaurant,
       required this.optionItemStream,
        this.id,
        this.name,
        this.isLoading = false,
        this.submitted = false,
      });

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    if (id == null || id == '') {
      id = documentIdFromCurrentDate();
    }
    final item = OptionItem(
      id: id,
      restaurantId: restaurant!.id,
      optionId: option!.id,
      name: name,
    );
    try {
      final Map<dynamic, dynamic> items = restaurant!.restaurantOptions![option!.id];
      if (items.containsKey(id)) {
        restaurant!.restaurantOptions![option!.id].update(id, (_) => item.toMap());
      } else {
        restaurant!.restaurantOptions![option!.id].putIfAbsent(id, () => item.toMap());
      }
      optionItemStream!.broadcastEvent(restaurant!.restaurantOptions![option!.id]);
      await Restaurant.setRestaurant(database, restaurant);
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText => 'Save';

  bool get canSave => optionItemNameValidator.isValid(name);

  String? get optionItemNameErrorText {
    bool showErrorText = !optionItemNameValidator.isValid(name);
    return showErrorText ? invalidOptionItemNameText : null;
  }

  void updateOptionItemName(String name) => updateWith(name: name);

  void updateWith({
    String? name,
    bool? isLoading,
    bool? submitted,
  }) {
    this.name = name ?? this.name;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
