import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/models/user_message.dart';
import 'package:nmwhitelabel/app/utilities/validators.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class RestaurantDetailsModel with RestaurantDetailsValidators, ChangeNotifier {
  final Database database;
  final Session? session;
  String? id;
  String? managerId;
  String? name;
  String? address1;
  String? address2;
  String? address3;
  String? address4;
  String? typeOfFood;
  Position? coordinates;
  int? deliveryRadius;
  TimeOfDay? workingHoursFrom;
  TimeOfDay? workingHoursTo;
  String? telephoneNumber;
  String? notes;
  bool active;
  bool open;
  bool acceptingStaffRequests;
  bool acceptCash;
  bool acceptCard;
  bool acceptOther;
  bool foodDeliveries;
  bool foodCollection;
  bool allowCancellations;
  String? vatNumber;
  String? registrationNumber;
  bool adminVerified;
  Map<dynamic, dynamic>? restaurantMenus;
  Map<dynamic, dynamic>? restaurantOptions;
  List<Position>? markerCoordinates;
  List<String?>? markerDescription;
  bool isLoading;
  bool submitted;
  bool dataHasChanged = false;

  RestaurantDetailsModel({
    required this.database,
    this.session,
    this.id,
    this.managerId,
    this.name,
    this.address1,
    this.address2,
    this.address3,
    this.address4,
    this.typeOfFood,
    this.coordinates,
    this.deliveryRadius,
    this.workingHoursFrom,
    this.workingHoursTo,
    this.telephoneNumber,
    this.notes,
    this.active = false,
    this.open = false,
    this.acceptingStaffRequests = false,
    this.acceptCash = false,
    this.acceptCard = false,
    this.acceptOther = false,
    this.foodDeliveries = false,
    this.foodCollection = false,
    this.allowCancellations = false,
    this.vatNumber,
    this.registrationNumber,
    this.adminVerified = false,
    this.restaurantMenus,
    this.restaurantOptions,
    this.markerCoordinates,
    this.markerDescription,
    this.isLoading = false,
    this.submitted = false,
  });

  Future<void> save(bool useCurrentLocation) async {
    updateWith(isLoading: true, submitted: true);
    if (id == null || id == '') {
      id = documentIdFromCurrentDate();
    }
    try {
      await database.setRestaurant(
        Restaurant(
          id: id,
          managerId: database.userId,
          name: name,
          address1: address1,
          address2: address2,
          address3: address3,
          address4: address4,
          typeOfFood: typeOfFood,
          coordinates: useCurrentLocation ? session!.position : coordinates,
          deliveryRadius: deliveryRadius,
          workingHoursFrom: workingHoursFrom,
          workingHoursTo: workingHoursTo,
          telephoneNumber: telephoneNumber,
          notes: notes,
          open: open,
          active: active,
          acceptingStaffRequests: acceptingStaffRequests,
          acceptCash: acceptCash,
          acceptCard: acceptCard,
          acceptOther: acceptOther,
          foodDeliveries: foodDeliveries,
          foodCollection: foodCollection,
          allowCancellations: allowCancellations,
          vatNumber: vatNumber,
          registrationNumber: registrationNumber,
          adminVerified: adminVerified,
          restaurantFlags: {
            'open': open,
            'active': active,
            'acceptingStaffRequests': acceptingStaffRequests,
          },
          paymentFlags: {
            'Cash': acceptCash,
            'Card': acceptCard,
            'Other': acceptOther,
          },
          restaurantMenus: restaurantMenus,
          foodDeliveryFlags: {
            'Deliver': foodDeliveries,
            'Collect': foodCollection,
          },
          restaurantOptions: restaurantOptions,
          markerCoordinates: markerCoordinates,
          markerNames: markerDescription,
        ),
      );
      if (!adminVerified) {
        final double timestamp = dateFromCurrentDate() / 1.0;
        database.setMessageDetails(UserMessage(
          id: documentIdFromCurrentDate(),
          timestamp: timestamp,
          fromUid: database.userId,
          toUid: '',
          restaurantId: id,
          fromRole: ROLE_MANAGER,
          toRole: ROLE_ADMIN,
          fromName: '${session!.userDetails!.name} (${session!.userDetails!.email})',
          delivered: false,
          type: 'Admin verification required for $name',
          authFlag: false,
          attendedFlag: false,
        ));
      }
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText => 'Save';

  bool get canSave {
    bool canSubmitFlag = false;
    if (restaurantNameValidator.isValid(name) &&
        restaurantAddress1Validator.isValid(address1) &&
        typeOfFoodValidator.isValid(typeOfFood) &&
        deliveryRadiusValidator.isValid(deliveryRadius) &&
        telephoneNumberValidator.isValid(telephoneNumber) &&
        workingHoursFrom != null &&
        workingHoursTo != null &&
        _validPaymentMethods() &&
        _validDeliveryOption() &&
        !isLoading) {
      canSubmitFlag = true;
    }
    return canSubmitFlag;
  }

  bool _validPaymentMethods() {
    return acceptCard || acceptCash || acceptOther;
  }

  bool _validDeliveryOption() {
    return foodCollection || foodDeliveries;
  }

  String? get restaurantNameErrorText {
    bool showErrorText = !restaurantNameValidator.isValid(name);
    return showErrorText ? invalidRestaurantNameErrorText : null;
  }

  String? get restaurantAddress1ErrorText {
    bool showErrorText =
        !restaurantAddress1Validator.isValid(address1);
    return showErrorText ? invalidRestaurantAddress1ErrorText : null;
  }

  String? get typeOfFoodErrorText {
    bool showErrorText = !typeOfFoodValidator.isValid(typeOfFood);
    return showErrorText ? invalidTypeOfFoodErrorText : null;
  }

  String? get deliveryRadiusErrorText {
    bool showErrorText = !deliveryRadiusValidator.isValid(deliveryRadius);
    return showErrorText ? invalidDeliveryRadiusErrorText : null;
  }

  String? get telephoneNumberErrorText {
    bool showErrorText = !telephoneNumberValidator.isValid(telephoneNumber);
    return showErrorText ? invalidTelephoneNumberErrorText : null;
  }

  void updateRestaurantName(String name) => updateWith(name: name);

  void updateAddress1(String address1) =>
      updateWith(address1: address1);

  void updateAddress2(String address2) =>
      updateWith(address2: address2);

  void updateAddress3(String address3) =>
      updateWith(address3: address3);

  void updateAddress4(String address4) =>
      updateWith(address4: address4);

  void updateTypeOfFood(String typeOfFood) =>
      updateWith(typeOfFood: typeOfFood);

  void updateCoordinates(Position coordinates) =>
      updateWith(coordinates: coordinates);

  void updateDeliveryRadius(int? deliveryRadius) =>
      updateWith(deliveryRadius: deliveryRadius);

  void updateWorkingHoursFrom(TimeOfDay workingHoursFrom) =>
      updateWith(workingHoursFrom: workingHoursFrom);

  void updateWorkingHoursTo(TimeOfDay workingHoursTo) =>
      updateWith(workingHoursTo: workingHoursTo);

  void updateTelephoneNumber(String telephoneNumber) =>
      updateWith(telephoneNumber: telephoneNumber);

  void updateNotes(String notes) => updateWith(notes: notes);

  void updateActive(bool active) => updateWith(active: active && adminVerified);

  void updateOpen(bool open) => updateWith(open: open);

  void updateAcceptingStaffRequests(bool acceptingStaffRequests) =>
      updateWith(acceptingStaffRequests: acceptingStaffRequests);

  void updateAcceptCash(bool? acceptCash) => updateWith(acceptCash: acceptCash);

  void updateAcceptCard(bool? acceptCard) => updateWith(acceptCard: acceptCard);

  void updateAcceptOther(bool? acceptOther) => updateWith(acceptOther: acceptOther);

  void updateFoodDeliveries(bool? foodDeliveries) => updateWith(foodDeliveries: foodDeliveries);

  void updateFoodCollection(bool? foodCollection) => updateWith(foodCollection: foodCollection);

  void updateAllowCancellations(bool? allowCancellations) => updateWith(allowCancellations: allowCancellations);

  void updateVatNumber(String vatNumber) => updateWith(vatNumber: vatNumber);

  void updateRegistrationNumber(String registrationNumber) => updateWith(registrationNumber: registrationNumber);

  void updateWith({
    String? name,
    String? address1,
    String? address2,
    String? address3,
    String? address4,
    String? typeOfFood,
    Position? coordinates,
    int? deliveryRadius,
    TimeOfDay? workingHoursFrom,
    TimeOfDay? workingHoursTo,
    String? telephoneNumber,
    String? notes,
    bool? active,
    bool? open,
    bool? acceptingStaffRequests,
    bool? acceptCash,
    bool? acceptCard,
    bool? acceptOther,
    bool? foodDeliveries,
    bool? foodCollection,
    bool? allowCancellations,
    String? vatNumber,
    String? registrationNumber,
    bool? isLoading,
    bool? submitted,
  }) {
    this.name = name ?? this.name;
    this.address1 = address1 ?? this.address1;
    this.address2 = address2 ?? this.address2;
    this.address3 = address3 ?? this.address3;
    this.address4 = address4 ?? this.address4;
    this.typeOfFood = typeOfFood ?? this.typeOfFood;
    this.coordinates = coordinates ?? this.coordinates;
    this.deliveryRadius = deliveryRadius ?? this.deliveryRadius;
    this.workingHoursFrom = workingHoursFrom ?? this.workingHoursFrom;
    this.workingHoursTo = workingHoursTo ?? this.workingHoursTo;
    this.telephoneNumber = telephoneNumber ?? this.telephoneNumber;
    this.notes = notes ?? this.notes;
    this.active = active ?? this.active;
    this.open = open ?? this.open;
    this.acceptingStaffRequests =
        acceptingStaffRequests ?? this.acceptingStaffRequests;
    this.acceptCash = acceptCash ?? this.acceptCash;
    this.acceptCard = acceptCard ?? this.acceptCard;
    this.acceptOther = acceptOther ?? this.acceptOther;
    this.foodDeliveries = foodDeliveries ?? this.foodDeliveries;
    this.foodCollection = foodCollection ?? this.foodCollection;
    this.allowCancellations = allowCancellations ?? this.allowCancellations;
    this.vatNumber = vatNumber ?? this.vatNumber;
    this.registrationNumber = registrationNumber ?? this.registrationNumber;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    dataHasChanged = true;
    notifyListeners();
  }
}
