import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/pages/messages/messages_listener.dart';
import 'package:nmwhitelabel/app/pages/restaurant/check_staff_authorization.dart';
import 'package:nmwhitelabel/app/pages/restaurant/restaurant_options_page.dart';
import 'package:nmwhitelabel/app/pages/restaurant/restaurant_list_tile.dart';
import 'package:nmwhitelabel/app/services/near_restaurant_bloc.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:provider/provider.dart';

class RestaurantQuery extends StatefulWidget {

  @override
  _RestaurantQueryState createState() => _RestaurantQueryState();
}

class _RestaurantQueryState extends State<RestaurantQuery> {
  late Session session;
  late Database database;
  late NearRestaurantBloc bloc;
  String role = ROLE_PATRON;

  void _menuAndOrdersPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => MessagesListener(child: RestaurantOptionsPage(),),
      ),
    );
  }

  void _staffAuthorizationPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => CheckStaffAuthorization(),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<Restaurant>>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          return ListItemsBuilder<Restaurant>(
            title: 'No nearby restaurants found',
            message: 'You seem to be far away from them. Make sure location services are on and restart the app.',
            snapshot: snapshot,
            itemBuilder: (context, restaurant) {
              return Card(
                color: restaurant.adminVerified! ? Colors.transparent : Colors.red,
                child: ListTile(
                  leading: Icon(Icons.restaurant),
                  // title: _buildTitle(index),
                  title: RestaurantListTile(
                    restaurant: restaurant,
                    restaurantFound: true,
                  ),
                  onTap: () {
                    session.currentRestaurant = restaurant;
                    if (role == ROLE_PATRON) {
                      _menuAndOrdersPage(context);
                    } else {
                      _staffAuthorizationPage(context);
                    }
                  },
                ),
              );
            }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    database = Provider.of<Database>(context, listen: true);
    session = Provider.of<Session>(context);
    final userCoordinates = session.position;
    if (FlavourConfig.isManager()) {
      role = ROLE_MANAGER;
    } else if (FlavourConfig.isStaff()) {
      role = ROLE_STAFF;
    }
    bloc = NearRestaurantBloc(
        source: database.patronRestaurants(),
        userCoordinates: userCoordinates,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurants near you',
          style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        elevation: 2.0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildContents(context),
    );
  }

}
