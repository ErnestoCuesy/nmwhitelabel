import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';

class NearRestaurantBloc {
  final Stream<List<Restaurant>>? source;
  final Position? userCoordinates;
  final _stream = StreamController<List<Restaurant>>();

  NearRestaurantBloc({
    this.source,
    this.userCoordinates,
  }) {
    List<Restaurant> resList = [];
    source!.forEach((rest) {
      resList.clear();
      rest.forEach((res) async {
        double distance = Geolocator.distanceBetween(
          userCoordinates!.latitude,
          userCoordinates!.longitude,
          res.coordinates!.latitude,
          res.coordinates!.longitude,
        );
        if (FlavourConfig.isAdmin()) {
          resList.add(res);
        } else if (res.active! && distance < res.deliveryRadius!) {
          resList.add(res);
        }
        _stream.add(resList);
      });
    });
  }

  Stream<List<Restaurant>> get stream => _stream.stream;
}
