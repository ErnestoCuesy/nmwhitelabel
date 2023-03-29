import 'package:flutter/material.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/orders/order_history.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class InactiveOrders extends StatefulWidget {
  @override
  _InactiveOrdersState createState() => _InactiveOrdersState();
}

class _InactiveOrdersState extends State<InactiveOrders> {
  late Session session;
  late Database database;

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    return OrderHistory(
      stream: database.inactiveRestaurantOrders(session.currentRestaurant!.id),
      restaurantName: session.currentRestaurant!.name,
      showLocked: false,
      showActive: false,
    );
  }
}
