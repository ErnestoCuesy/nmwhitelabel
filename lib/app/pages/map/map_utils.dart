import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {
  final Position? currentLocation;
  final Size? mediaSize;
  final Function? callBack;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  MapUtils({this.currentLocation, this.mediaSize, this.callBack});

  onMapCreated(GoogleMapController controller) async {
    const double padding = 150.0;
    final double width = mediaSize!.width - padding;
    final double height = mediaSize!.height - padding;

    // Create map bounds
    final bounds = createTargetBounds();

    // Determine correct level of zoom
    double zoom =
        _getBoundsZoomLevel(bounds.northeast, bounds.southwest, width, height);
    controller.moveCamera(CameraUpdate.zoomTo(zoom));

    callBack!();
  }

  LatLngBounds createTargetBounds() {
    // Assume sw (curr) lat and long are less than ne (dest)
    LatLng curr = LatLng(currentLocation!.latitude, currentLocation!.longitude);
    LatLng dest = LatLng(currentLocation!.latitude, currentLocation!.longitude);

    // Calculate SW latitude bounds
    LatLng sw = LatLng(
        min(curr.latitude, dest.latitude), min(curr.longitude, dest.longitude));

    // Calculate NE latitude bounds
    LatLng ne = LatLng(
        max(curr.latitude, dest.latitude), max(curr.longitude, dest.longitude));

    return LatLngBounds(southwest: sw, northeast: ne);
  }

  double _getBoundsZoomLevel(
      LatLng northeast, LatLng southwest, double width, double height) {
    // ignore: constant_identifier_names
    const int GLOBE_WIDTH = 256; // a constant in Google's map projection
    // ignore: constant_identifier_names
    const double ZOOM_MAX = 21;
    double latFraction =
        (_latRad(northeast.latitude) - _latRad(southwest.latitude)) / pi;
    double lngDiff = northeast.longitude - southwest.longitude;
    double lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;
    double latZoom = _zoom(height, GLOBE_WIDTH, latFraction);
    double lngZoom = _zoom(width, GLOBE_WIDTH, lngFraction);
    double zoom = min(min(latZoom, lngZoom), ZOOM_MAX);
    return zoom;
  }

  double _latRad(double lat) {
    double sinx = sin(lat * pi / 180);
    double radX2 = log((1 + sinx) / (1 - sinx)) / 2;
    return max(min(radX2, pi), -pi) / 2;
  }

  double _zoom(double mapPx, int worldPx, double fraction) {
    return (log(mapPx / worldPx / fraction) / ln2);
  }
}
