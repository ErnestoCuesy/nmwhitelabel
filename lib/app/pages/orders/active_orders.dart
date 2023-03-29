import 'package:flutter/material.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/orders/order_history.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class ActiveOrders extends StatefulWidget {
  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  late Session session;
  late Database database;

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    if (FlavourConfig.isPatron()) {
      return OrderHistory(
        stream:
            database.userOrders(session.currentRestaurant!.id, database.userId),
        restaurantName: session.currentRestaurant!.name,
        showLocked: false,
        showActive: true,
      );
    } else {
      return OrderHistory(
        stream: database.activeRestaurantOrders(session.currentRestaurant!.id),
        restaurantName: session.currentRestaurant!.name,
        showLocked: false,
        showActive: true,
      );
    }
  }
}
