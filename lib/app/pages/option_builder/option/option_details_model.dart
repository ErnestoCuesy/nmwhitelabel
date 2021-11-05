import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/option_observable_stream.dart';
import 'package:nmwhitelabel/app/utilities/validators.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class OptionDetailsModel with RestaurantOptionValidators, ChangeNotifier {
  final Database database;
  final Session session;
  final OptionObservableStream? optionStream;
  Restaurant? restaurant;
  String? id;
  String? name;
  int? numberAllowed;
  bool isLoading;
  bool submitted;

  OptionDetailsModel(
      {required this.database,
       required this.session,
       required this.optionStream,
      this.restaurant,
      this.id,
      this.name,
      this.numberAllowed,
      this.isLoading = false,
      this.submitted = false,
  });

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    if (id == null || id == '') {
      id = documentIdFromCurrentDate();
    }
    final option = Option(
      id: id,
      restaurantId: restaurant!.id,
      name: name,
      numberAllowed: numberAllowed,
    );
    try {
      if (restaurant!.restaurantOptions!.containsKey(id)) {
        final stageOption = restaurant!.restaurantOptions![id];
        print('Staged option: $stageOption');
        stageOption['id'] = id;
        stageOption['restaurantId'] = restaurant!.id;
        stageOption['name'] = name;
        stageOption['numberAllowed'] = numberAllowed;
        restaurant!.restaurantOptions!.update(id, (_) => stageOption);
      } else {
        restaurant!.restaurantOptions!.putIfAbsent(id, () => option.toMap());
      }
      optionStream!.broadcastEvent(restaurant!.restaurantOptions as Map<String?, dynamic>?);
      Restaurant.setRestaurant(database, restaurant);
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText => 'Save';

  bool get canSave => optionNameValidator.isValid(name) &&
                      numberAllowedValidator.isValid(numberAllowed);

  String? get optionNameErrorText {
    bool showErrorText = !optionNameValidator.isValid(name);
    return showErrorText ? invalidOptionNameText : null;
  }

  String? get numberAllowedErrorText {
    bool showErrorText = !numberAllowedValidator.isValid(numberAllowed);
    return showErrorText ? invalidNumberAllowedText : null;
  }

  void updateOptionName(String name) => updateWith(name: name);

  void updateNumberAllowed(int? numberAllowed) => updateWith(numberAllowed: numberAllowed);

  void updateWith({
    String? name,
    int? numberAllowed,
    bool? isLoading,
    bool? submitted,
  }) {
    this.name = name ?? this.name;
    this.numberAllowed = numberAllowed ?? this.numberAllowed;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
