import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/order.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/menu_browser/menu_item_view.dart';
import 'package:nmwhitelabel/app/pages/orders/view_order.dart';
import 'package:nmwhitelabel/app/pages/sign_in/conversion_process.dart';
import 'package:nmwhitelabel/app/services/auth.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/navigation_service.dart';
import 'package:provider/provider.dart';

class MenuBrowser extends StatefulWidget {

  @override
  _MenuBrowserState createState() => _MenuBrowserState();
}

class _MenuBrowserState extends State<MenuBrowser> {
  Auth? auth;
  Session? session;
  Database? database;
  NavigationService? navigationService;
  Restaurant? restaurant;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  Map<String, dynamic>? menu;
  bool _menuSelected = false;
  late List<bool> _selectedMenu;
  Orientation? _previousOrientation;

  bool get orderOnHold =>
      session!.currentOrder != null &&
      session!.currentOrder!.orderItems!.length > 0 &&
      session!.currentOrder!.restaurantId == session!.currentRestaurant!.id &&
      session!.currentOrder!.status == ORDER_ON_HOLD;

  Widget _buildContents(BuildContext context, Map<dynamic, dynamic> menus,
    Map<dynamic, dynamic>? options, dynamic sortedKeys) {
    return OrientationBuilder(
      builder: (context, orientation) {
        bool isLargeScreen = MediaQuery.of(context).size.width > 600;
        return Row(
          children: [
            Expanded(
              child: ListView.builder(
                controller: ScrollController(),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: sortedKeys.length,
                itemBuilder: (BuildContext context, int index) {
                  menu = menus[sortedKeys[index]];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 1.0),
                    child: Card(
                      color: (_selectedMenu[index] && isLargeScreen) ? Colors.grey : Theme.of(context).canvasColor,
                      margin: EdgeInsets.all(12.0),
                      child: ListTile(
                        isThreeLine: false,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              menu!['name'],
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            menu!['notes'],
                          ),
                        ),
                        onTap: () {
                          if (!isLargeScreen) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                fullscreenDialog: false,
                                builder: (context) =>
                                    MenuItemView(
                                      menu: menus[sortedKeys[index]],
                                      isLargeScreen: false,
                                    ),
                              ),
                            );
                          } else {
                            setState(() {
                              menu = menus[sortedKeys[index]];
                              _menuSelected = true;
                              _selectedMenu = List.filled(_selectedMenu.length, false);
                              _selectedMenu[index] = true;
                            });
                          }
                        },
                        trailing: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLargeScreen)
            Expanded(
              child: _menuSelected ? MenuItemView(menu: menu, isLargeScreen: true,) : Container(),
            )
          ],
        );
      },
    );
  }

  void _shoppingCartAction(BuildContext context) async {
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
      } else {
        session!.userProcessComplete = true;
      }
    }
    if (orderOnHold) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: false,
          builder: (context) => ViewOrder.create(
            context: context,
            order: session!.currentOrder,
            scaffoldKey: _scaffoldKey,
          ),
        ),
      );
    } else {
      session!.userDetails!.orderOnHold = null;
      database!.setUserDetails(session!.userDetails);
      await PlatformExceptionAlertDialog(
        title: 'Empty Order',
        exception: PlatformException(
          code: 'ORDER_IS_EMPTY',
          message:
          'Please tap on the menu items you wish to order first.',
          details:
          'Please tap on the menu items you wish to order first.',
        ),
      ).show(context);
    }
  }

  void _checkExistingOrder() {
    final double timestamp = dateFromCurrentDate() / 1.0;
    var orderNumber = documentIdFromCurrentDate();
    if (session!.currentOrder == null) {
      session!.currentOrder = session!.emptyOrder(orderNumber, timestamp, database!.userId);
    }
    session!.currentOrder!.userId = database!.userId;
    if (session!.userDetails!.orderOnHold != null && session!.userDetails!.orderOnHold!.length > 0) {
      session!.currentOrder = Order.fromMap(session!.userDetails!.orderOnHold, null);
    }
    session!.broadcastOrderCounter(session!.currentOrder!.orderItems!.length);
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context) as Auth?;
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    navigationService = Provider.of<NavigationService>(context);
    Map<dynamic, dynamic>? menus;
    Map<dynamic, dynamic>? options;
    Map<dynamic, dynamic> sortedMenus = Map<dynamic, dynamic>();
    _checkExistingOrder();
    restaurant = session!.currentRestaurant;
    menus = restaurant!.restaurantMenus;
    options = restaurant!.restaurantOptions;
    sortedMenus.clear();
    menus!.forEach((key, value) {
      if (value['hidden'] == false) {
        sortedMenus.putIfAbsent(value['sequence'], () => value);
      }
    });
    var sortedKeys = sortedMenus.keys.toList()..sort();
    if (!_menuSelected) {
      _selectedMenu = List<bool>.generate(
          session!.currentRestaurant!.restaurantMenus!.length, (index) => false);
    }
    if (MediaQuery.of(context).orientation != _previousOrientation) {
      _menuSelected = false;
      _selectedMenu = List.filled(_selectedMenu.length, false);
      _previousOrientation = MediaQuery.of(context).orientation;
    }
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              '${restaurant!.name}',
              style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
            ),
            actions: [
              if (!FlavourConfig.isAdmin())
              Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: IconButton(
                  icon: Icon(Icons.add_shopping_cart, size: 32.0,),
                  onPressed: () => _shoppingCartAction(context),
                ),
              ),
            ],
          ),
          body: _buildContents(context, sortedMenus, options, sortedKeys),
        ),
        StreamBuilder<int>(
          stream: session!.orderCounterObservable,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data! > 0) {
              return Positioned(
                right: 18,
                top: 5,
                child: Container(
                  height: 20.0,
                  width: 20.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 35.0, right: 5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.red
                  ),
                  child: Text(
                    snapshot.data.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              );
            } else {
              return Positioned(
                right: 18,
                top: 5,
                child: Container(height: 20.0, width: 20.0,),
              );
            }
          }
        ),
      ]
    );
  }
}
