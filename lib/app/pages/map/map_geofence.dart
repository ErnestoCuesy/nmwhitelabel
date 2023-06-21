import 'dart:collection';

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
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  List<toolkit.LatLng> _polygonPointsForTesting = [];
  List<LatLng> _polygonPointsForDrawing = [];
  Set<Polygon> _polygon = HashSet<Polygon>();

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
      _markers[MarkerId(position.latitude.toString())] = marker;
      _polygonPointsForTesting
          .add(toolkit.LatLng(position.latitude, position.longitude));
      _polygonPointsForDrawing
          .add(LatLng(position.latitude, position.longitude));
    });
  }

  _testTap(LatLng position) {
    toolkit.LatLng tkLatLng =
        toolkit.LatLng(position.latitude, position.longitude);
    SnackBar snackBar;
    if (toolkit.PolygonUtil.containsLocation(
        tkLatLng, _polygonPointsForTesting, false)) {
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
    setState(() {
      _addPolygon();
    });
    _testTap(LatLng(currentLocation!.latitude, currentLocation!.longitude));
  }

  _resetMarkers() {
    setState(() {
      _markers.clear();
      _polygonPointsForTesting.clear();
      _polygonPointsForDrawing.clear();
      _polygon.clear();
      session.currentRestaurant!.geofencingCoordinates!.clear();
      database.setRestaurant(session.currentRestaurant);
      _addCurrentLocationMarker();
    });
  }

  _saveMarkers() {
    List<Position>? geofencingCoordinates = [];
    for (var coordinate in _polygonPointsForTesting) {
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
    _markers[MarkerId(currentLocation!.latitude.toString())] = marker;
  }

  _loadMarkers() async {
    if (_polygonPointsForTesting.isNotEmpty) return;
    currentLocation = session.currentRestaurant!.coordinates;
    var geofencingCoordinates =
        session.currentRestaurant!.geofencingCoordinates;
    for (var coordinate in geofencingCoordinates!) {
      var position1 = toolkit.LatLng(coordinate.latitude, coordinate.longitude);
      var position2 = LatLng(coordinate.latitude, coordinate.longitude);
      _polygonPointsForTesting.add(position1);
      _polygonPointsForDrawing.add(position2);
      Marker marker = Marker(
        markerId: MarkerId(coordinate.latitude.toString()),
        position: position2,
        icon: await chequeredFlag,
      );
      _markers[MarkerId(position2.latitude.toString())] = marker;
    }
    _addPolygon();
  }

  void _addPolygon() {
    if (_polygonPointsForDrawing.isNotEmpty) {
      _polygon.add(Polygon(
        // given polygonId
        polygonId: PolygonId('1'),
        // initialize the list of points to display polygon
        points: _polygonPointsForDrawing,
        // given color to polygon
        fillColor: Colors.green.withOpacity(0.3),
        // given border color to polygon
        strokeColor: Colors.green,
        geodesic: true,
        // given width of border
        strokeWidth: 4,
      ));
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
        markers: Set<Marker>.of(_markers.values),
        polygons: _polygon,
        onLongPress: _setMarker,
        onTap: _testTap,
      ),
      floatingActionButton: _speedDial(),
    );
  }
}
