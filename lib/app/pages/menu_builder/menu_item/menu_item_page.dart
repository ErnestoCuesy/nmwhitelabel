import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/models/menu_item.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu_item/menu_item_details_page.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu_item/reorder_menu_item.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/menu_item_observable_stream.dart';
import 'package:provider/provider.dart';

class MenuItemPage extends StatefulWidget {
  final Restaurant? restaurant;
  final Menu? menu;

  const MenuItemPage({Key? key, this.restaurant, this.menu}) : super(key: key);

  @override
  _MenuItemPageState createState() => _MenuItemPageState();
}

class _MenuItemPageState extends State<MenuItemPage> {
  late Session session;
  late Database database;
  MenuItemObservableStream? menuItemStream;
  String? get menuId => widget.menu!.id;
  Restaurant? get restaurant => session.currentRestaurant;
  Menu? get menu => Menu.fromMap(restaurant!.restaurantMenus![menuId], null);
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  List<MenuItem>? _menuItemList;
  int? _sequence;

  void _createMenuItemDetailsPage(BuildContext context, MenuItem item, int? sequence) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => MenuItemDetailsPage(
          restaurant: restaurant,
          menu: menu,
          item: item,
          menuItemStream: menuItemStream,
          sequence: sequence,
        ),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, MenuItem item) async {
    try {
      restaurant!.restaurantMenus![menuId].remove(item.id);
      menuItemStream!.broadcastEvent(restaurant!.restaurantMenus![menuId]);
      Restaurant.setRestaurant(database, restaurant);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<bool?> _confirmDismiss(BuildContext context, MenuItem item) async {
    if (item.options!.length > 0) {
      return !await (PlatformExceptionAlertDialog(
        title: 'Menu item has options',
        exception: PlatformException(
          code: 'MAP_IS_NOT_EMPTY',
          message: 'Please first unselect the options in this menu item.',
          details: 'Please first unselect the options in this menu item.',
        ),
      ).show(context) as FutureOr<bool>);
    } else {
      return await PlatformAlertDialog(
        title: 'Confirm menu item deletion',
        content: 'Do you really want to delete this menu item?',
        cancelActionText: 'No',
        defaultActionText: 'Yes',
      ).show(context);
    }
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: menuItemStream!.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          _menuItemList = snapshot.data;
          _sequence = _menuItemList!.length;
        }
        return ListItemsBuilder<MenuItem>(
            title: 'No menu items found',
            message: 'Tap the + button to add a new menu item',
            snapshot: snapshot,
            itemBuilder: (context, item) {
              String adjustedDescription = item.description!;
              if (adjustedDescription.length > 60) {
                adjustedDescription = adjustedDescription.substring(0, 60) + '...(more)';
              }
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key('item-${item.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDismiss(context, item),
                onDismissed: (direction) => _deleteItem(context, item),
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  child: ListTile(
                    isThreeLine: true,
                    leading: item.hidden! ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name!,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                          child: Text(
                            adjustedDescription,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      children: _buildOptions(item),
                    ),
                    trailing: Text(
                      f.format(item.price),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onTap: () => _createMenuItemDetailsPage(context, item, item.sequence),
                  ),
                ),
              );
            }
        );
      },
    );
  }

  List<Widget> _buildOptions(MenuItem item) {
    List<Widget> optionList = [];
    if (item.options!.isNotEmpty) {
      item.options!.forEach((key) {
        final value = restaurant!.restaurantOptions![key];
        if (value != null) {
          optionList.add(CheckboxListTile(
            title: Text('${value['name']}'),
            value: true,
            onChanged: null,
          ));
        }
      });
    }
    return optionList;
  }

  void _reorderMenuItem(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => ReorderMenuItem(
            menuItemStream: menuItemStream,
            menuItemList: _menuItemList,
          ),
        )
    );
  }

  bool _menuIsReorderable() {
    int counter = 0;
    Map<String, dynamic> menuFields = restaurant!.restaurantMenus![menuId];
    menuFields.forEach((key, value) {
      if (key.length > 20) {
        counter++;
      }
    });
    return counter > 1;
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    menuItemStream = MenuItemObservableStream(observable: restaurant!.restaurantMenus![menuId]);
    menuItemStream!.init();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.menu!.name}', style: TextStyle(color: Theme
            .of(context)
            .appBarTheme
            .backgroundColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).appBarTheme.backgroundColor,),
            iconSize: 32.0,
            onPressed: () => _createMenuItemDetailsPage(context, MenuItem(menuId: menuId), _sequence),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 32.0),
            child: _menuIsReorderable() ? IconButton(
              icon: Icon(
                  Icons.import_export,
              ),
              iconSize: 32.0,
              onPressed: () => _reorderMenuItem(context),
            ) : Container(),
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}