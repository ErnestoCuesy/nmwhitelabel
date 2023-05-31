import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:provider/provider.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';
import '../../models/session.dart';
import '../../services/database.dart';
import 'map_utils.dart';

class CaptureMapGeofence extends StatefulWidget {
  const CaptureMapGeofence();

  @override
  // ignore: library_private_types_in_public_api
  _CaptureMapGeofenceState createState() => _CaptureMapGeofenceState();
}

class _CaptureMapGeofenceState extends State<CaptureMapGeofence> {
  late Session session;
  late Database database;
  late MapUtils mapUtils;
  Position? currentLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List<toolkit.LatLng> polygon = [];

  Future<BitmapDescriptor> get chequeredFlag async {
    return BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/chequered-flag.png');
  }

  _setMarker(LatLng position) async {
    Marker marker = Marker(
      markerId: MarkerId(position.latitude.toString()),
      position: position,
      icon: await chequeredFlag,
    );
    setState(() {
      markers[MarkerId(position.latitude.toString())] = marker;
      polygon.add(toolkit.LatLng(position.latitude, position.longitude));
    });
  }

  _testTap(LatLng position) {
    toolkit.LatLng tkLatLng =
        toolkit.LatLng(position.latitude, position.longitude);
    SnackBar snackBar;
    if (toolkit.PolygonUtil.containsLocation(tkLatLng, polygon, false)) {
      snackBar = const SnackBar(
        content: Text('In bounds'),
        duration: Duration(milliseconds: 200),
      );
    } else {
      snackBar = const SnackBar(
        content: Text('Out of bounds'),
        duration: Duration(milliseconds: 200),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _testCurrentLocation() {
    _testTap(LatLng(currentLocation!.latitude, currentLocation!.longitude));
  }

  _resetMarkers() {
    setState(() {
      markers.clear();
      polygon.clear();
      session.currentRestaurant!.geofencingCoordinates!.clear();
      database.setRestaurant(session.currentRestaurant);
      _addCurrentLocationMarker();
    });
  }

  _saveMarkers() {
    List<Position>? geofencingCoordinates = [];
    for (var coordinate in polygon) {
      geofencingCoordinates.add(Position(
          longitude: coordinate.longitude,
          latitude: coordinate.latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0));
    }
    session.currentRestaurant!.geofencingCoordinates = geofencingCoordinates;
    database.setRestaurant(session.currentRestaurant);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Geofence saved'),
      duration: Duration(milliseconds: 200),
    ));
  }

  _addCurrentLocationMarker() {
    Marker marker = Marker(
      markerId: MarkerId(currentLocation!.latitude.toString()),
      position: LatLng(currentLocation!.latitude, currentLocation!.longitude),
    );
    markers[MarkerId(currentLocation!.latitude.toString())] = marker;
  }

  _loadMarkers() async {
    if (polygon.isNotEmpty) return;
    currentLocation = session.currentRestaurant!.coordinates;
    var geofencingCoordinates =
        session.currentRestaurant!.geofencingCoordinates;
    for (var coordinate in geofencingCoordinates!) {
      var position1 = toolkit.LatLng(coordinate.latitude, coordinate.longitude);
      var position2 = LatLng(coordinate.latitude, coordinate.longitude);
      polygon.add(position1);
      Marker marker = Marker(
        markerId: MarkerId(coordinate.latitude.toString()),
        position: position2,
        icon: await chequeredFlag,
      );
      markers[MarkerId(position2.latitude.toString())] = marker;
    }
  }

  void _callBack() {
    setState(() {});
  }

  Widget _speedDial() {
    return SpeedDialFabWidget(
      primaryBackgroundColor: Theme.of(context).colorScheme.background,
      primaryForegroundColor: Theme.of(context).colorScheme.onBackground,
      secondaryBackgroundColor: Theme.of(context).colorScheme.background,
      secondaryForegroundColor: Theme.of(context).colorScheme.onBackground,
      secondaryIconsList: const [
        Icons.location_on,
        Icons.location_off,
        Icons.where_to_vote,
      ],
      secondaryIconsOnPress: [
        _testCurrentLocation,
        _resetMarkers,
        _saveMarkers,
      ],
      secondaryIconsText: const [
        'Test current location',
        'Reset',
        'Save',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    _loadMarkers();
    mapUtils = MapUtils(
      mediaSize: MediaQuery.of(context).size,
      currentLocation: currentLocation,
      callBack: _callBack,
    );
    _addCurrentLocationMarker();
    return Scaffold(
      appBar: AppBar(
        title: Text('Geofencing'),
      ),
      body: GoogleMap(
        onMapCreated: mapUtils.onMapCreated,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        initialCameraPosition: CameraPosition(
            target:
                LatLng(currentLocation!.latitude, currentLocation!.longitude),
            zoom: 18.0),
        markers: Set<Marker>.of(markers.values),
        onLongPress: _setMarker,
        onTap: _testTap,
      ),
      floatingActionButton: _speedDial(),
    );
  }
}
