import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/menu_observable_stream.dart';
import 'package:nmwhitelabel/app/utilities/validators.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class MenuDetailsModel with RestaurantMenuValidators, ChangeNotifier {
  final Database database;
  final Session session;
  final MenuObservableStream? menuStream;
  Restaurant? restaurant;
  String? id;
  String? name;
  String? notes;
  int? sequence;
  bool? hidden;
  bool isLoading;
  bool submitted;

  List<int?> menuSequences = [];

  MenuDetailsModel(
      {required this.database,
       required this.session,
       required this.menuStream,
      this.restaurant,
      this.id,
      this.name,
      this.notes,
      this.sequence,
      this.hidden,
      this.isLoading = false,
      this.submitted = false,
  }) {
    restaurant!.restaurantMenus!.forEach((key, value) {
      if (sequence != value['sequence']) {
        menuSequences.add(value['sequence']);
      }
    });
  }

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    if (id == null || id == '') {
      id = documentIdFromCurrentDate();
    }
    final menu = Menu(
      id: id,
      restaurantId: restaurant!.id,
      name: name,
      notes: notes,
      sequence: sequence,
      hidden: hidden,
    );
    try {
      if (restaurant!.restaurantMenus!.containsKey(id)) {
        final stageMenu = restaurant!.restaurantMenus![id];
        print('Staged menu: $stageMenu');
        stageMenu['id'] = id;
        stageMenu['restaurantId'] = restaurant!.id;
        stageMenu['name'] = name;
        stageMenu['notes'] = notes;
        stageMenu['sequence'] = sequence;
        stageMenu['hidden'] = hidden;
        restaurant!.restaurantMenus!.update(id, (_) => stageMenu);
      } else {
        restaurant!.restaurantMenus!.putIfAbsent(id, () => menu.toMap());
      }
      menuStream!.broadcastEvent(restaurant!.restaurantMenus as Map<String?, dynamic>?);
      Restaurant.setRestaurant(database, restaurant);
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText => 'Save';

  bool get canSave => menuNameValidator.isValid(name);

  String? get menuNameErrorText {
    bool showErrorText = !menuNameValidator.isValid(name);
    return showErrorText ? invalidMenuNameText : null;
  }

  void updateMenuName(String name) => updateWith(name: name);

  void updateMenuNotes(String notes) => updateWith(notes: notes);

  void updateSequence(int sequence) => updateWith(sequence: sequence);

  void updateHidden(bool? hidden) => updateWith(hidden: hidden);

  void updateWith({
    String? name,
    String? notes,
    int? sequence,
    bool? hidden,
    bool? isLoading,
    bool? submitted,
  }) {
    this.name = name ?? this.name;
    this.notes = notes ?? this.notes;
    this.sequence = sequence ?? this.sequence;
    this.hidden = hidden ?? this.hidden;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
