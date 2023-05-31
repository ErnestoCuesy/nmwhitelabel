import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/custom_raised_button.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/images/item_image_page.dart';
import 'package:nearbymenus/app/pages/map/capture_map_markers.dart';
import 'package:nearbymenus/app/pages/map/map_geofence.dart';
import 'package:nearbymenus/app/pages/menu_browser/menu_browser.dart';
import 'package:nearbymenus/app/pages/menu_builder/menu/menu_page.dart';
import 'package:nearbymenus/app/pages/option_builder/option/option_page.dart';
import 'package:nearbymenus/app/pages/orders/active_orders.dart';
import 'package:nearbymenus/app/pages/orders/inactive_orders.dart';
import 'package:nearbymenus/app/pages/orders/order_totals.dart';
import 'package:nearbymenus/app/pages/sign_in/conversion_process.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/services/navigation_service.dart';
import 'package:provider/provider.dart';

class RestaurantAdministratorPage extends StatefulWidget {
  final List<Restaurant>? restaurantList;

  const RestaurantAdministratorPage({Key? key, this.restaurantList})
      : super(key: key);

  @override
  _RestaurantAdministratorPageState createState() =>
      _RestaurantAdministratorPageState();
}

class _RestaurantAdministratorPageState
    extends State<RestaurantAdministratorPage> {
  Auth? auth;
  Session? session;
  Database? database;
  NavigationService? navigationService;
  Restaurant? get restaurant => session!.currentRestaurant;
  double buttonSize = 180.0;

  List<Widget> _buildContents(BuildContext context) {
    return [
      Text(restaurant!.name!,
          style: Theme.of(context).textTheme.headlineMedium),
      SizedBox(
        height: 32.0,
      ),
      if (FlavourConfig.isManager())
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRaisedButton(
              height: buttonSize,
              width: buttonSize,
              color: Theme.of(context).buttonTheme.colorScheme!.surface,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MenuPage(),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menu Builder',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Icon(
                    Icons.format_list_bulleted,
                    size: 36.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            CustomRaisedButton(
              height: buttonSize,
              width: buttonSize,
              color: Theme.of(context).buttonTheme.colorScheme!.surface,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => OptionPage(),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Option Builder',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Icon(
                    Icons.check_box,
                    size: 36.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      if (FlavourConfig.isManager())
        SizedBox(
          height: 16.0,
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (session!.userDetails!.role != ROLE_VENUE)
            CustomRaisedButton(
              height: buttonSize,
              width: buttonSize,
              color: Theme.of(context).buttonTheme.colorScheme!.surface,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MenuBrowser(),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menu Browser',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Icon(
                    Icons.import_contacts,
                    size: 36.0,
                  ),
                ],
              ),
            ),
          SizedBox(
            width: 16.0,
          ),
          if (FlavourConfig.isManager()) _imageButton(),
        ],
      ),
      SizedBox(
        height: 16.0,
      ),
      if (FlavourConfig.isManager() || session!.userDetails!.role == ROLE_STAFF)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRaisedButton(
              height: buttonSize,
              width: buttonSize,
              color: Theme.of(context).buttonTheme.colorScheme!.surface,
              onPressed: () => _convertUser(context, _activeOrders),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Active Orders',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Icon(
                    Icons.assignment,
                    size: 36.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            CustomRaisedButton(
              height: buttonSize,
              width: buttonSize,
              color: Theme.of(context).buttonTheme.colorScheme!.surface,
              onPressed: () => _convertUser(context, _inactiveOrders),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Inactive Orders',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Icon(
                    Icons.assignment,
                    size: 36.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      SizedBox(
        height: 16.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _salesButton(),
        ],
      ),
      SizedBox(
        height: 16.0,
      ),
      _markersAndGeofencingRow(),
      if (FlavourConfig.isManager()) _copyRestaurantMenu(),
    ];
  }

  Widget _markersAndGeofencingRow() {
    Widget row;
    row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (FlavourConfig.isManager())
        CustomRaisedButton(
          height: buttonSize,
          width: buttonSize,
          color: Theme.of(context).buttonTheme.colorScheme!.surface,
          onPressed: () => _convertUser(context, _captureMapMarkers),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Map Markers',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
              SizedBox(
                height: 8.0,
              ),
              Icon(
                Icons.location_on,
                size: 36.0,
              ),
            ],
          ),
        ),
      if (FlavourConfig.isManager())
        SizedBox(
          width: 16.0,
        ),
      CustomRaisedButton(
        height: buttonSize,
        width: buttonSize,
        color: Theme.of(context).buttonTheme.colorScheme!.surface,
        onPressed: () => _convertUser(context, _captureMapGeofence),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Geofencing',
              style: Theme.of(context).primaryTextTheme.titleLarge,
            ),
            SizedBox(
              height: 8.0,
            ),
            Icon(
              Icons.location_searching_outlined,
              size: 36.0,
            ),
          ],
        ),
      ),
    ]);
    if (!kIsWeb) {
      if (Platform.isMacOS) {
        return SizedBox(
          child: Placeholder(),
          height: buttonSize,
          width: buttonSize,
        );
      } else {
        return row;
      }
    } else {
      return SizedBox(
        child: Placeholder(),
        height: buttonSize,
        width: buttonSize,
      );
    }
  }

  Widget _salesButton() {
    Widget button;
    button = CustomRaisedButton(
      height: buttonSize,
      width: buttonSize,
      color: Theme.of(context).buttonTheme.colorScheme!.surface,
      onPressed: () => _convertUser(context, _orderTotals),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sales',
            style: Theme.of(context).primaryTextTheme.titleLarge,
          ),
          SizedBox(
            height: 8.0,
          ),
          Icon(
            Icons.attach_money,
            size: 36.0,
          ),
        ],
      ),
    );
    if (!kIsWeb) {
      if (FlavourConfig.isManager() && !Platform.isMacOS) {
        return button;
      } else {
        return SizedBox(
          child: Placeholder(),
          height: buttonSize,
          width: buttonSize,
        );
      }
    } else {
      return SizedBox(
        child: Placeholder(),
        height: buttonSize,
        width: buttonSize,
      );
    }
  }

  Widget _imageButton() {
    Widget button;
    button = CustomRaisedButton(
      height: buttonSize,
      width: buttonSize,
      color: Theme.of(context).buttonTheme.colorScheme!.surface,
      onPressed: () => _convertUser(context, _images),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Images',
            style: Theme.of(context).primaryTextTheme.titleLarge,
          ),
          SizedBox(
            height: 8.0,
          ),
          Icon(
            Icons.image,
            size: 36.0,
          ),
        ],
      ),
    );
    if (!kIsWeb) {
      if (FlavourConfig.isManager() && !Platform.isMacOS) {
        return button;
      } else {
        return SizedBox(
          child: Placeholder(),
          height: buttonSize,
          width: buttonSize,
        );
      }
    } else {
      return SizedBox(
        child: Placeholder(),
        height: buttonSize,
        width: buttonSize,
      );
    }
  }

  Widget _copyRestaurantMenu() {
    return PopupMenuButton<Restaurant>(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.content_copy),
              Text('Copy menu to another restaurant'),
            ],
          ),
        ),
        onSelected: (Restaurant selectedRestaurant) {
          print(selectedRestaurant.name);
          selectedRestaurant.restaurantMenus =
              session!.currentRestaurant!.restaurantMenus;
          selectedRestaurant.restaurantOptions =
              session!.currentRestaurant!.restaurantOptions;
          database!.setRestaurant(selectedRestaurant);
        },
        itemBuilder: (BuildContext context) {
          return widget.restaurantList!.map((Restaurant restaurant) {
            if (restaurant.id != session!.currentRestaurant!.id) {
              return PopupMenuItem<Restaurant>(
                child: Text(restaurant.name!),
                value: restaurant,
              );
            } else {
              return PopupMenuItem<Restaurant>(
                child: Text('-'),
              );
            }
          }).toList();
        });
  }

  void _images(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ItemImagePage(
          viewOnly: false,
        ),
      ),
    );
  }

  void _activeOrders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ActiveOrders(),
      ),
    );
  }

  void _inactiveOrders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => InactiveOrders(),
      ),
    );
  }

  void _orderTotals(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => OrderTotals(),
      ),
    );
  }

  void _captureMapMarkers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CaptureMapMarkers(),
      ),
    );
  }

  void _captureMapGeofence(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CaptureMapGeofence(),
      ),
    );
  }

  void _convertUser(
      BuildContext context, Function(BuildContext) nextAction) async {
    if (!session!.userProcessComplete) {
      final ConversionProcess conversionProcess = ConversionProcess(
        navigationService: navigationService,
        session: session,
        auth: auth,
        database: database,
        captureUserDetails: true,
      );
      if (!await conversionProcess.userCanProceed()) {
        return;
      }
    }
    nextAction(context);
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context) as Auth?;
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    navigationService = Provider.of<NavigationService>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Restaurant Management',
            style:
                TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildContents(context),
              ),
            ),
          ),
        ));
  }
}
