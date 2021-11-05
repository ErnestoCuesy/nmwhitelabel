import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_trailing_icon.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu/reorder_menu.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu_item/menu_item_page.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu/menu_details_page.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/menu_observable_stream.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Session session;
  late Database database;
  MenuObservableStream? menuStream;
  Restaurant? get restaurant => session.currentRestaurant;
  List<Menu>? _menuList;
  int? _sequence;

  void _createMenuDetailsPage(BuildContext context, Menu menu, int? sequence) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => MenuDetailsPage(
          restaurant: restaurant,
          menu: menu,
          menuStream: menuStream,
          sequence: sequence,
        ),
      ),
    );
  }

  Future<void> _deleteMenu(BuildContext context, Menu menu) async {
    try {
      restaurant!.restaurantMenus!.remove(menu.id);
      menuStream!.broadcastEvent(restaurant!.restaurantMenus as Map<String?, dynamic>?);
      Restaurant.setRestaurant(database, restaurant);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<bool?> _confirmDismiss(BuildContext context, Menu menu) async {
    var hasStuff = false;
    restaurant!.restaurantMenus![menu.id].forEach((key, value) {
      if (key.toString().length > 20){
        hasStuff = true;
      }
    });
    if (hasStuff) {
      return !await (PlatformExceptionAlertDialog(
        title: 'Menu is not empty',
        exception: PlatformException(
          code: 'MAP_IS_NOT_EMPTY',
          message:  'Please delete all the menu items first.',
          details:  'Please delete all the menu items first.',
        ),
      ).show(context) as FutureOr<bool>);
    } else {
      return await PlatformAlertDialog(
        title: 'Confirm menu deletion',
        content: 'Do you really want to delete this menu?',
        cancelActionText: 'No',
        defaultActionText: 'Yes',
      ).show(context);
    }
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<Menu>>(
      stream: menuStream!.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          _menuList = snapshot.data;
          _sequence = _menuList!.length;
        }
        return ListItemsBuilder<Menu>(
            title: 'No menus found',
            message: 'Tap the + button to add a new menu',
            snapshot: snapshot,
            itemBuilder: (context, menu) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key('menu-${menu.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDismiss(context, menu),
                onDismissed: (direction) => _deleteMenu(context, menu),
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  child: ListTile(
                    isThreeLine: false,
                    leading: menu.hidden! ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          menu.name!,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text(menu.notes ?? ''),
                    ),
                    trailing: IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => MenuItemPage(
                            restaurant: restaurant,
                            menu: menu,
                          ),
                        ),
                      ),
                      icon: PlatformTrailingIcon(),
                    ),
                    onTap: () => _createMenuDetailsPage(context, menu, menu.sequence),
                  ),
                ),
              );
            });
      },
    );
  }

  void _reorderMenu(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => ReorderMenu(
            menuStream: menuStream,
            menuList: _menuList,
          ),
        )
    );
  }

  bool _menuIsReorderable() {
    int counter = 0;
    Map<String?, dynamic> menuFields = restaurant!.restaurantMenus as Map<String?, dynamic>;
    menuFields.forEach((key, value) {
      if (key!.length > 20) {
        counter++;
      }
    });
    return counter > 1;
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    menuStream = MenuObservableStream(observable: session.currentRestaurant!.restaurantMenus as Map<String?, dynamic>?);
    menuStream!.init();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${restaurant!.name}',
          style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            iconSize: 32.0,
            onPressed: () => _createMenuDetailsPage(context, Menu(), _sequence),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 32.0),
            child: _menuIsReorderable() ? IconButton(
              icon: Icon(
                  Icons.import_export,
              ),
              iconSize: 32.0,
              onPressed: () => _reorderMenu(context),
            ) : Container(),
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}
