import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nmwhitelabel/app/services/database.dart';

class Restaurant {
  final String? id;
  final String? managerId;
  final String? name;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? address4;
  final String? typeOfFood;
  final Position? coordinates;
  final int? deliveryRadius;
  final TimeOfDay? workingHoursFrom;
  final TimeOfDay? workingHoursTo;
  final String? telephoneNumber;
  final String? notes;
  final bool? active;
  final bool? open;
  final bool? acceptingStaffRequests;
  final bool? acceptCash;
  final bool? acceptCard;
  final bool? acceptOther;
  final bool? foodDeliveries;
  final bool? foodCollection;
  final bool? allowCancellations;
  final String? vatNumber;
  final String? registrationNumber;
  final Map<dynamic, dynamic>? foodDeliveryFlags;
  final Map<dynamic, dynamic>? restaurantFlags;
  final Map<dynamic, dynamic>? paymentFlags;
  Map<dynamic, dynamic>? restaurantMenus;
  Map<dynamic, dynamic>? restaurantOptions;
  List<Position>? markerCoordinates;
  List<String?>? markerNames;
  bool? itemImagesInitialized;
  bool? adminVerified;

  Restaurant({
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
    this.active,
    this.open,
    this.acceptingStaffRequests,
    this.acceptCash,
    this.acceptCard,
    this.acceptOther,
    this.foodDeliveries,
    this.foodCollection,
    this.allowCancellations,
    this.vatNumber,
    this.registrationNumber,
    this.restaurantFlags,
    this.paymentFlags,
    this.restaurantMenus,
    this.foodDeliveryFlags,
    this.restaurantOptions,
    this.itemImagesInitialized,
    this.adminVerified,
    this.markerCoordinates,
    this.markerNames,
  });

  static Restaurant fromMap(Map<dynamic, dynamic>? value, String documentId) {
    // if (value == null) {
    //   return null;
    // }
    final geoPoint = value!['coordinates'] as GeoPoint;
    final int? deliveryRadius = value['deliveryRadius'];
    final hoursFromHours = value['hoursFromHours'];
    final hoursFromMinutes = value['hoursFromMinutes'];
    final hoursToHours = value['hoursToHours'];
    final hoursToMinutes = value['hoursToMinutes'];
    final markerCoordinates = value['markerCoordinates'] as List<dynamic>? ?? <dynamic>[];
    final markerNames = value['markerNames'] as List<dynamic>? ?? <dynamic>[];
    List<Position> markerPositionList = List<Position>.from(markerCoordinates.map((element)
          => Position(
            latitude: element.latitude,
            longitude: element.longitude,
            speed: 0,
            heading: 0,
            accuracy: 0,
            speedAccuracy: 0,
            altitude: 0,
            timestamp: DateTime.now()
            )));
    List<String> markerNamesList = List<String>.from(markerNames.map((e) => e.toString()));
    return Restaurant(
        id: documentId,
        managerId: value['managerId'],
        name: value['name'],
        typeOfFood: value['typeOfFood'],
        address1: value['address1'],
        address2: value['address2'],
        address3: value['address3'],
        address4: value['address4'],
        coordinates: Position(
            latitude: geoPoint.latitude,
            longitude: geoPoint.longitude,
            altitude: 0,
            speedAccuracy: 0,
            speed: 0,
            heading: 0,
            accuracy: 0,
            timestamp: DateTime.now()
            ),
        deliveryRadius: deliveryRadius,
        workingHoursFrom: TimeOfDay(hour: hoursFromHours, minute: hoursFromMinutes),
        workingHoursTo: TimeOfDay(hour: hoursToHours, minute: hoursToMinutes),
        telephoneNumber: value['telephoneNumber'],
        notes: value['notes'],
        active: value['restaurantFlags']['active'],
        open: value['restaurantFlags']['open'],
        acceptingStaffRequests: value['restaurantFlags']['acceptingStaffRequests'],
        acceptCash: value['paymentFlags']['Cash'],
        acceptCard: value['paymentFlags']['Card'],
        acceptOther: value['paymentFlags']['Other'],
        foodDeliveries: value['foodDeliveryFlags']['Deliver'] ?? false,
        foodCollection: value['foodDeliveryFlags']['Collect'] ?? false,
        allowCancellations: value['allowCancellations'] ?? false,
        vatNumber: value['vatNumber'] ?? '',
        registrationNumber: value['registrationNumber'] ?? '',
        restaurantFlags: value['restaurantFlags'] ?? {},
        paymentFlags: value['paymentFlags'] ?? {},
        restaurantMenus: value['restaurantMenus'] ?? {},
        restaurantOptions: value['restaurantOptions'] ?? {},
        foodDeliveryFlags: value['foodDeliveryFlags'] ?? {},
        itemImagesInitialized: value['itemImagesInitialized'] ?? false,
        adminVerified: value['adminVerified'] ?? false,
        markerCoordinates: markerPositionList,
        markerNames: markerNamesList
    );
  }

  Map<String, dynamic> toMap() {
    final GeoPoint geoPoint =
        GeoPoint(coordinates!.latitude, coordinates!.longitude);
    final List<GeoPoint> geoPointList = List<GeoPoint>.from(markerCoordinates!.map((e)
          => GeoPoint(e.latitude, e.longitude)));
    return <String, dynamic>{
      'id': id,
      'managerId': managerId,
      'name': name,
      'typeOfFood': typeOfFood,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'address4': address4,
      'coordinates': geoPoint,
      'deliveryRadius': deliveryRadius,
      'hoursFromHours': workingHoursFrom!.hour,
      'hoursFromMinutes': workingHoursFrom!.minute,
      'hoursToHours': workingHoursTo!.hour,
      'hoursToMinutes': workingHoursTo!.minute,
      'telephoneNumber': telephoneNumber,
      'notes': notes,
      'restaurantFlags': restaurantFlags,
      'paymentFlags': paymentFlags,
      'restaurantMenus': restaurantMenus ?? {},
      'restaurantOptions': restaurantOptions ?? {},
      'foodDeliveryFlags': foodDeliveryFlags ?? {},
      'itemImagesInitialized': itemImagesInitialized ?? false,
      'allowCancellations': allowCancellations,
      'vatNumber': vatNumber,
      'registrationNumber': registrationNumber,
      'adminVerified': adminVerified ?? false,
      'markerCoordinates': geoPointList,
      'markerNames': markerNames,
    };
  }

  static Future<void> setRestaurant(Database database, Restaurant? restaurant) async {
    await database.setRestaurant(restaurant);
  }

  bool get isOpen {
    final double hFrom = this.workingHoursFrom!.hour.toDouble() + this.workingHoursFrom!.minute.toDouble() / 60;
    final double hTo = this.workingHoursTo!.hour.toDouble() + this.workingHoursTo!.minute.toDouble() / 60;
    final double now = TimeOfDay.now().hour.toDouble() + TimeOfDay.now().minute.toDouble() / 60;
    bool openFlag = true;
    if (!this.open!) {
      openFlag = false;
    } else if (now < hFrom || now > hTo){
      openFlag = false;
    }
    return openFlag;
  }
}
