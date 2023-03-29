import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/common_widgets/list_items_builder.dart';
import 'package:nearbymenus/app/common_widgets/platform_alert_dialog.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/restaurant/restaurant_administrator_page.dart';
import 'package:nearbymenus/app/pages/restaurant/restaurant_details_page.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late Session session;
  late Database database;

  void _createRestaurantDetailsPage(
      BuildContext context, Restaurant? restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => RestaurantDetailsPage(
          restaurant: restaurant,
        ),
      ),
    );
  }

  Future<void> _deleteRestaurant(
      BuildContext context, Restaurant? restaurant) async {
    try {
      await database.deleteRestaurant(restaurant);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<bool?> _confirmDismiss(
      BuildContext context, Restaurant? restaurant) async {
    if (restaurant!.acceptingStaffRequests! ||
        restaurant.active! ||
        restaurant.open!) {
      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Disable restaurant status flags first to delete'),
      //   ),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disable restaurant status flags first to delete'),
        ),
      );
      return false;
    } else {
      return await PlatformAlertDialog(
        title: 'Confirm restaurant deletion',
        content:
            'Do you really want to delete this restaurant? Menus and authorizations will also be deleted.',
        cancelActionText: 'No',
        defaultActionText: 'Yes',
      ).show(context);
    }
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<Restaurant?>>(
      stream: database.managerRestaurants(database.userId),
      builder: (context, snapshot) {
        final restaurantList = snapshot.data as List<Restaurant>?;
        session.userDetails!.hasRestaurants = false;
        if (snapshot.hasData && snapshot.data!.length > 0) {
          session.userDetails!.hasRestaurants = true;
        }
        database.setUserDetails(session.userDetails);
        return ListItemsBuilder<Restaurant?>(
            title: 'No restaurants found',
            message: 'Tap the + button to add a new restaurant',
            snapshot: snapshot,
            itemBuilder: (context, restaurant) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key('res-${restaurant?.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDismiss(context, restaurant),
                onDismissed: (direction) =>
                    _deleteRestaurant(context, restaurant),
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  child: ListTile(
                    isThreeLine: true,
                    leading: IconButton(
                      onPressed: () =>
                          _createRestaurantDetailsPage(context, restaurant),
                      icon: Icon(
                        Icons.edit,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          restaurant!.name!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(restaurant.address1!),
                      ],
                    ),
                    // subtitle: Text('${restaurant.restaurantLocation}'),
                    subtitle: Column(
                      children: <Widget>[
                        CheckboxListTile(
                          title: Text('Listing is active'),
                          value: restaurant.active,
                          onChanged: null,
                        ),
                        CheckboxListTile(
                          title: Text('Restaurant shows as open'),
                          value: restaurant.open,
                          onChanged: null,
                        ),
                        CheckboxListTile(
                          title: Text('Accepting staff requests'),
                          value: restaurant.acceptingStaffRequests,
                          onChanged: null,
                        ),
                        Text(
                            'Tap on pencil to edit. Tap on arrow for more. Swipe left to delete.'),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        session.currentRestaurant = restaurant;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                RestaurantAdministratorPage(
                              restaurantList: restaurantList,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward,
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your managed restaurants',
          style:
              TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            iconSize: 32.0,
            padding: const EdgeInsets.only(right: 32.0),
            onPressed: () =>
                _createRestaurantDetailsPage(context, Restaurant()),
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}
