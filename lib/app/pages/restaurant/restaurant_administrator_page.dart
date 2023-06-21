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
  double iconSize = 36.0;

  void _checkAndProceed(
      {required Widget nextAction, required bool convertUser}) async {
    if (convertUser) {
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
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => nextAction,
      ),
    );
  }

  Widget _restaurantAdministratorButton(
      {required String text,
      required Icon icon,
      required Widget nextAction,
      required bool convertUser}) {
    return CustomRaisedButton(
      height: buttonSize,
      width: buttonSize,
      color: Theme.of(context).buttonTheme.colorScheme!.surface,
      onPressed: () =>
          _checkAndProceed(nextAction: nextAction, convertUser: convertUser),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: Theme.of(context).primaryTextTheme.titleLarge,
          ),
          SizedBox(
            height: 8.0,
          ),
          icon,
        ],
      ),
    );
  }

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
            _restaurantAdministratorButton(
              text: 'Menu Builder',
              icon: Icon(
                Icons.format_list_bulleted,
                size: iconSize,
              ),
              nextAction: MenuPage(),
              convertUser: false,
            ),
            SizedBox(
              width: 16.0,
            ),
            _restaurantAdministratorButton(
              text: 'Option Builder',
              icon: Icon(
                Icons.check_box,
                size: iconSize,
              ),
              nextAction: OptionPage(),
              convertUser: false,
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
            _restaurantAdministratorButton(
              text: 'Menu Browser',
              icon: Icon(
                Icons.import_contacts,
                size: iconSize,
              ),
              nextAction: MenuBrowser(),
              convertUser: false,
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
            _restaurantAdministratorButton(
              text: 'Active Orders',
              icon: Icon(
                Icons.assignment,
                size: iconSize,
              ),
              nextAction: ActiveOrders(),
              convertUser: true,
            ),
            SizedBox(
              width: 16.0,
            ),
            _restaurantAdministratorButton(
              text: 'Inactive Orders',
              icon: Icon(
                Icons.assignment,
                size: iconSize,
              ),
              nextAction: InactiveOrders(),
              convertUser: true,
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
        _restaurantAdministratorButton(
          text: 'Map Markers',
          icon: Icon(
            Icons.location_on,
            size: iconSize,
          ),
          nextAction: CaptureMapMarkers(),
          convertUser: true,
        ),
      if (FlavourConfig.isManager())
        SizedBox(
          width: 16.0,
        ),
      _restaurantAdministratorButton(
        text: 'Geofencing',
        icon: Icon(
          Icons.location_searching_outlined,
          size: iconSize,
        ),
        nextAction: CaptureMapGeofence(),
        convertUser: true,
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
    return _restaurantAdministratorButton(
      text: 'Sales',
      icon: Icon(
        Icons.attach_money,
        size: iconSize,
      ),
      nextAction: OrderTotals(),
      convertUser: true,
    );
  }

  Widget _imageButton() {
    return _restaurantAdministratorButton(
      text: 'Images',
      icon: Icon(
        Icons.image,
        size: iconSize,
      ),
      nextAction: ItemImagePage(viewOnly: false),
      convertUser: true,
    );
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
