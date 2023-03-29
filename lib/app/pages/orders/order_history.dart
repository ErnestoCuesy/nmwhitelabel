import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/order.dart';
import 'package:nmwhitelabel/app/pages/orders/view_order.dart';
import 'package:nmwhitelabel/app/pages/user/upsell_screen.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/utilities/format.dart';
import 'package:provider/provider.dart';

class OrderHistory extends StatefulWidget {
  final Stream<List<Order>>? stream;
  final String? restaurantName;
  final bool? showLocked;
  final bool? showActive;

  const OrderHistory(
      {Key? key,
      this.stream,
      this.restaurantName,
      this.showLocked,
      this.showActive})
      : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  late Database database;
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  Stream<List<Order>>? get stream => widget.stream;
  List<Order>? blockedOrders;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildContents(BuildContext context) {
    String messageString = '';
    if (widget.showLocked!) {
      messageString = 'locked';
    } else {
      if (widget.showActive!) {
        messageString = 'active';
      } else {
        messageString = 'inactive';
      }
    }
    return StreamBuilder<List<Order>>(
      stream: stream,
      builder: (context, snapshot) {
        blockedOrders = snapshot.data;
        return ListItemsBuilder<Order>(
            title: 'Orders',
            message: 'There are no $messageString orders',
            snapshot: snapshot,
            itemBuilder: (context, order) {
              return Card(
                color: _determineTileColor(order),
                margin: EdgeInsets.all(12.0),
                child: ListTile(
                  isThreeLine: true,
                  leading: _determineIcon(order),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order # ${order.orderNumber}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '${order.restaurantName}, ${order.orderItems!.length} items',
                          //style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: Text(
                            Format.formatDateTime(order.timestamp!.toInt()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            order.statusString,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Text(
                    f.format(order.orderTotal -
                        (order.orderTotal * order.discount!) +
                        order.tip!),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  //onTap: role != ROLE_PATRON && order.isBlocked ? null : () => _viewOrder(context, order),
                  onTap: () async {
                    if (!order.isBlocked! || FlavourConfig.isPatron()) {
                      _viewOrder(context, order);
                    } else {
                      if (FlavourConfig.isManager()) {
                        if (!widget.showLocked!) {
                          await PlatformExceptionAlertDialog(
                            title: 'Locked order',
                            exception: PlatformException(
                              code: 'LOCKED_ORDER',
                              message:
                                  'Please go to your profile page and buy a bundle to unlock your orders.',
                              details:
                                  'Please go to your profile page and buy a bundle to unlock your orders.',
                            ),
                          ).show(context);
                        } else {
                          _unlockOrders(context);
                        }
                      } else if (FlavourConfig.isStaff()) {
                        await PlatformExceptionAlertDialog(
                          title: 'Locked order',
                          exception: PlatformException(
                            code: 'LOCKED_ORDER',
                            message:
                                'Order locked. Please notify your restaurant manager.',
                            details:
                                'Order locked. Please notify your restaurant manager.',
                          ),
                        ).show(context);
                      }
                    }
                  },
                ),
              );
            });
      },
    );
  }

  Color? _determineTileColor(Order order) {
    Color? tileColor;
    if (FlavourConfig.isPatron()) {
      tileColor = Colors.black45;
    } else {
      if (order.isBlocked!) {
        tileColor = Colors.brown;
      } else {
        switch (order.status) {
          case ORDER_PLACED:
            tileColor = Colors.deepOrange;
            break;
          case ORDER_ACCEPTED:
            tileColor = Colors.pinkAccent;
            break;
          case ORDER_READY:
            tileColor = Colors.green;
            break;
          case ORDER_REJECTED_BUSY:
          case ORDER_REJECTED_STOCK:
            tileColor = Colors.white12;
            break;
          case ORDER_CANCELLED:
            tileColor = Colors.black12;
            break;
        }
      }
    }
    return tileColor;
  }

  Icon _determineIcon(Order order) {
    Icon tileIcon;
    if (!FlavourConfig.isPatron() && order.isBlocked!) {
      tileIcon = Icon(Icons.lock);
    } else {
      switch (order.status) {
        case ORDER_PLACED:
          tileIcon = Icon(Icons.assignment_late);
          break;
        case ORDER_REJECTED_BUSY:
        case ORDER_REJECTED_STOCK:
          tileIcon = Icon(Icons.clear);
          break;
        case ORDER_READY:
          tileIcon = Icon(Icons.check);
          break;
        case ORDER_CANCELLED:
          tileIcon = Icon(Icons.delete_forever);
          break;
        default:
          tileIcon = Icon(Icons.receipt);
          break;
      }
    }
    return tileIcon;
  }

  void _viewOrder(BuildContext context, Order order) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          fullscreenDialog: false,
          builder: (context) => ViewOrder.create(
                context: context,
                order: order,
              )),
    );
  }

  Future<void> _unlockOrders(BuildContext context) async {
    if (blockedOrders!.length > 0) {
      await database.ordersLeft(database.userId).then((value) {
        int ordersLeft = 0;
        if (value != null) {
          ordersLeft = value;
        }
        print('Orders left: $ordersLeft');
        print('Blocked orders: ${blockedOrders!.length}');
        if (ordersLeft >= blockedOrders!.length) {
          blockedOrders!.forEach((order) {
            order.isBlocked = false;
            database.setOrder(order);
          });
          // _scaffoldKey.currentState.showSnackBar(
          //   SnackBar(
          //     content: Text(
          //         '${blockedOrders.length} orders unlocked'
          //     ),
          //   ),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${blockedOrders!.length} orders unlocked'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpsellScreen(
                ordersLeft: ordersLeft,
                blockedOrders: blockedOrders!.length,
              ),
            ),
          );
        }
      }).catchError((_) => null);
    } else {
      await PlatformExceptionAlertDialog(
        title: 'Locked orders',
        exception: PlatformException(
          code: 'ORDER_BUNDLED_PURCHASE_SUCCESS',
          message: 'There are no locked orders at the moment.',
          details: 'There are no locked orders at the moment',
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    database = Provider.of<Database>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.showLocked!
              ? 'Locked orders'
              : '${widget.restaurantName} Orders',
          style:
              TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        actions: [
          if (widget.showLocked!)
            Padding(
              padding: const EdgeInsets.only(right: 26.0),
              child: IconButton(
                iconSize: 24.0,
                icon: Icon(Icons.lock_open),
                onPressed: () => _unlockOrders(context),
              ),
            ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}
