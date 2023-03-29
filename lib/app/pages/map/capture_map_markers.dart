import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbymenus/app/models/map_marker.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/map/capture_marker_name.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class CaptureMapMarkers extends StatefulWidget {
  @override
  _CaptureMapMarkersState createState() => _CaptureMapMarkersState();
}

class _CaptureMapMarkersState extends State<CaptureMapMarkers> {
  late Session session;
  late Database database;
  // ignore: cancel_subscriptions
  StreamSubscription<Position>? _positionStreamSubscription;
  Position _lastPosition = Position(
      latitude: 0,
      longitude: 0,
      heading: 0,
      speed: 0,
      altitude: 0,
      speedAccuracy: 0,
      accuracy: 0,
      timestamp: DateTime.now());
  static const String EMPTY_NAME = '>> Tap to capture position name';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    if (session.currentRestaurant!.markerCoordinates!.length == 0) {
      session.currentRestaurant!.markerCoordinates = List<Position>.generate(
          5,
          (index) => Position(
              latitude: 0,
              longitude: 0,
              speed: 0,
              speedAccuracy: 0,
              altitude: 0,
              accuracy: 0,
              heading: 0,
              timestamp: DateTime.now()));
      session.currentRestaurant!.markerNames =
          List<String?>.generate(5, (index) => EMPTY_NAME);
      database.setRestaurant(session.currentRestaurant);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Markers'),
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          'Latitude :',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        '${_lastPosition.latitude}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          'Longitude:',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        '${_lastPosition.longitude}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                  itemCount:
                      session.currentRestaurant!.markerCoordinates!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(
                          session.currentRestaurant!.markerNames![index]!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${session.currentRestaurant!.markerCoordinates![index].latitude}, ${session.currentRestaurant!.markerCoordinates![index].longitude}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () => _capturePositionName(context, index),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  void _capturePositionName(BuildContext context, int index) async {
    MapMarker? mapMarker;
    await Navigator.of(context)
        .push(MaterialPageRoute<MapMarker>(
            fullscreenDialog: true,
            builder: (context) => CaptureMarkerName(
                  name: session.currentRestaurant!.markerNames![index],
                )))
        .then((value) {
      mapMarker = value;
    });
    if (mapMarker != null) {
      if (mapMarker!.isActive!) {
        setState(() {
          session.currentRestaurant!.markerNames![index] = mapMarker!.name;
          session.currentRestaurant!.markerCoordinates![index] = Position(
              latitude: _lastPosition.latitude,
              longitude: _lastPosition.longitude,
              speed: 0,
              accuracy: 0,
              heading: 0,
              speedAccuracy: 0,
              altitude: 0,
              timestamp: DateTime.now());
        });
      } else {
        setState(() {
          session.currentRestaurant!.markerNames![index] = EMPTY_NAME;
          session.currentRestaurant!.markerCoordinates![index] = Position(
              latitude: 0,
              longitude: 0,
              speed: 0,
              accuracy: 0,
              speedAccuracy: 0,
              heading: 0,
              altitude: 0,
              timestamp: DateTime.now());
        });
      }
      database.setRestaurant(session.currentRestaurant);
    }
  }

  void _startListening() {
    if (_positionStreamSubscription == null) {
      final Stream<Position> positionStream = Geolocator.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription!.cancel();
        _positionStreamSubscription = null;
      }).listen((Position position) => setState(() {
            _lastPosition = position;
          }));
      _positionStreamSubscription!.pause();
    }

    setState(() {
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
      } else {
        _positionStreamSubscription!.pause();
      }
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    super.dispose();
  }
}
