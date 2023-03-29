import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/custom_raised_button.dart';
import 'package:nmwhitelabel/app/common_widgets/empty_content.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/models/user_message.dart';
import 'package:nmwhitelabel/app/pages/images/item_image_page.dart';
import 'package:nmwhitelabel/app/pages/menu_browser/menu_browser.dart';
import 'package:nmwhitelabel/app/pages/orders/active_orders.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:provider/provider.dart';

class RestaurantOptionsPage extends StatefulWidget {
  @override
  _RestaurantOptionsPageState createState() => _RestaurantOptionsPageState();
}

class _RestaurantOptionsPageState extends State<RestaurantOptionsPage> {
  late Session session;
  late Database database;
  late List<Restaurant> _restaurantList;

  void _loadRestaurants() async {
    await database
        .restaurantSnapshot()
        .then((value) => _restaurantList = value);
  }

  void _expandableMenuBrowserPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) =>
            session.currentRestaurant!.restaurantMenus!.isNotEmpty
                ? MenuBrowser()
                : Scaffold(
                    appBar: AppBar(
                      title: Text(''),
                    ),
                    body: EmptyContent(
                      title: 'Empty menu',
                      message: 'This restaurant hasn\'t loaded any menus yet',
                    ),
                  ),
      ),
    );
  }

  void _orderHistoryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => ActiveOrders(),
      ),
    );
  }

  List<Widget> _buildContents(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(session.currentRestaurant!.name!,
            style: FlavourConfig.isAdmin()
                ? Theme.of(context).textTheme.headlineMedium
                : Theme.of(context).primaryTextTheme.headlineMedium),
      ),
      SizedBox(
        height: 32.0,
      ),
      CustomRaisedButton(
        height: 150.0,
        width: 250.0,
        color: Theme.of(context).buttonTheme.colorScheme!.surface,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => ItemImagePage(
              viewOnly: true,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Food Gallery',
              style: Theme.of(context).textTheme.titleLarge,
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
      ),
      SizedBox(
        height: 32.0,
      ),
      CustomRaisedButton(
        height: 150.0,
        width: 250.0,
        color: Theme.of(context).buttonTheme.colorScheme!.surface,
        onPressed: () => _expandableMenuBrowserPage(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 16.0,
            ),
            Icon(
              Icons.import_contacts,
              size: 36.0,
            ),
          ],
        ),
      ),
      if (!FlavourConfig.isAdmin())
        SizedBox(
          height: 32.0,
        ),
      if (!FlavourConfig.isAdmin())
        CustomRaisedButton(
          height: 150.0,
          width: 250.0,
          color: Theme.of(context).buttonTheme.colorScheme!.surface,
          onPressed: () => _orderHistoryPage(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Order History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 16.0,
              ),
              Icon(
                Icons.assignment,
                size: 36.0,
              ),
            ],
          ),
        ),
      if (FlavourConfig.isAdmin())
        SizedBox(
          height: 32.0,
        ),
      if (FlavourConfig.isAdmin())
        CustomRaisedButton(
          height: 150.0,
          width: 250.0,
          color: Theme.of(context).buttonTheme.colorScheme!.surface,
          onPressed: () => _approveRestaurant(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.currentRestaurant!.adminVerified!
                    ? 'Block Restaurant'
                    : 'Approve Restaurant',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 16.0,
              ),
              Icon(
                session.currentRestaurant!.adminVerified!
                    ? Icons.block
                    : Icons.assignment_turned_in,
                size: 36.0,
              ),
            ],
          ),
        ),
      if (FlavourConfig.isAdmin())
        SizedBox(
          height: 32.0,
        ),
      if (FlavourConfig.isAdmin())
        CustomRaisedButton(
          height: 150.0,
          width: 250.0,
          color: Theme.of(context).buttonTheme.colorScheme!.surface,
          onPressed: () => _deleteRestaurant(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Delete Restaurant',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 16.0,
              ),
              Icon(
                Icons.delete_forever,
                size: 36.0,
              ),
            ],
          ),
        ),
      if (FlavourConfig.isAdmin())
        SizedBox(
          height: 32.0,
        ),
      if (FlavourConfig.isAdmin()) _copyRestaurantMenu()
    ];
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
              session.currentRestaurant!.restaurantMenus;
          selectedRestaurant.restaurantOptions =
              session.currentRestaurant!.restaurantOptions;
          database.setRestaurant(selectedRestaurant);
        },
        itemBuilder: (BuildContext context) {
          return _restaurantList.map((Restaurant restaurant) {
            if (restaurant.id != session.currentRestaurant!.id) {
              return PopupMenuItem<Restaurant>(
                child: Text(restaurant.name!),
                value: restaurant,
              );
            } else {
              return PopupMenuItem<Restaurant>(
                child: Text(restaurant.name!),
                value: restaurant,
              );
            }
          }).toList();
        });
  }

  void _deleteRestaurant(BuildContext context) async {
    if (await (PlatformAlertDialog(
      title: 'Confirm restaurant deletion',
      content: 'Do you really want to delete this restaurant?',
      cancelActionText: 'No',
      defaultActionText: 'Yes',
    ).show(context) as FutureOr<bool>)) {
      database.deleteRestaurant(session.currentRestaurant);
    }
  }

  void _approveRestaurant() {
    session.currentRestaurant!.adminVerified =
        !session.currentRestaurant!.adminVerified!;
    session.currentRestaurant!.restaurantFlags!
        .update('active', (value) => session.currentRestaurant!.adminVerified);
    database.setRestaurant(session.currentRestaurant);
    String message;
    if (session.currentRestaurant!.adminVerified!) {
      message = 'We have approved your restaurant';
    } else {
      message =
          'We have blocked your restaurant due to non-conformance to our Terms and Conditions';
    }
    final double timestamp = dateFromCurrentDate() / 1.0;
    database.setMessageDetails(UserMessage(
      id: documentIdFromCurrentDate(),
      timestamp: timestamp,
      fromUid: database.userId,
      toUid: session.currentRestaurant!.managerId,
      restaurantId: session.currentRestaurant!.id,
      fromRole: ROLE_ADMIN,
      toRole: ROLE_MANAGER,
      fromName: '${session.userDetails!.name}',
      delivered: false,
      type: message,
      authFlag: false,
      attendedFlag: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    String roleOptions = ' options';
    if (FlavourConfig.isAdmin()) {
      roleOptions = 'Administrator' + roleOptions;
      _loadRestaurants();
    } else if (FlavourConfig.isPatron()) {
      roleOptions = 'Patron' + roleOptions;
    } else {
      roleOptions = 'Staff' + roleOptions;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            roleOptions,
            style:
                TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
          ),
        ),
        body: StreamBuilder<Restaurant>(
            stream: database
                .selectedRestaurantStream(session.currentRestaurant!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: PlatformProgressIndicator());
              } else {
                if (snapshot.hasData) {
                  session.currentRestaurant = snapshot.data;
                  return SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildContents(context),
                      ),
                    ),
                  );
                } else {
                  return EmptyContent(
                    title: 'Restaurant not found',
                    message: '',
                  );
                }
              }
            }));
  }
}
