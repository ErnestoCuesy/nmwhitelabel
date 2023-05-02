import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/utilities/map_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapRoute extends StatefulWidget {
  final Position? currentLocation;
  final Position? destination;

  MapRoute({this.currentLocation, this.destination});

  @override
  _MapRouteState createState() => _MapRouteState();
}

class _MapRouteState extends State<MapRoute> {
  late Session session;
  late MapUtils mapUtils;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _callBack() {
    setState(() {
      markers = mapUtils.markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    mapUtils = MapUtils(
      mediaSize: MediaQuery.of(context).size,
      currentLocation: widget.currentLocation,
      destination: widget.destination,
      callBack: _callBack,
      markerCoordinates: session.currentRestaurant!.markerCoordinates,
      markerNames: session.currentRestaurant!.markerNames,
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: GoogleMap(
        onMapCreated: mapUtils.onMapCreated,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        cameraTargetBounds: CameraTargetBounds(mapUtils.createTargetBounds()),
        initialCameraPosition: CameraPosition(
            target: LatLng(
                (widget.currentLocation!.latitude +
                        widget.destination!.latitude) /
                    2,
                (widget.currentLocation!.longitude +
                        widget.destination!.longitude) /
                    2),
            zoom: 18.0),
        markers: Set<Marker>.of(markers.values),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: useGoogleNavigation,
          child: Icon(Icons.directions)),
    );
  }

  useGoogleNavigation() async {
    Uri googleApiUrlString = Uri.parse(
        "http://maps.google.com/maps?saddr=${widget.currentLocation!.latitude},${widget.currentLocation!.longitude}&daddr=${widget.destination!.latitude},${widget.destination!.longitude}");
    print(googleApiUrlString);
    if (await canLaunchUrl(googleApiUrlString)) {
      await launchUrl(googleApiUrlString, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $googleApiUrlString';
    }
  }
}
