import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/menu_item.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/menu_item_observable_stream.dart';
import 'package:provider/provider.dart';

class ReorderMenuItem extends StatefulWidget {
  final MenuItemObservableStream? menuItemStream;
  final List<MenuItem>? menuItemList;

  const ReorderMenuItem({Key? key, this.menuItemStream, this.menuItemList}) : super(key: key);

  @override
  _ReorderMenuItemState createState() => _ReorderMenuItemState();
}

class _ReorderMenuItemState extends State<ReorderMenuItem> {
  late Session session;
  late Database database;
  List<MenuItem>? get menuItemList => widget.menuItemList;
  Restaurant? get restaurant => session.currentRestaurant;

  Card _buildTenableListTile(int index, MenuItem menuItem) =>
      Card(
        key: ValueKey(menuItem.id),
        child: ListTile(
          isThreeLine: false,
          leading: Text('#$index'),
          title: Text(
            menuItem.name!,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      );

  List<Card> _getListItems() => menuItemList!
      .asMap()
      .map((index, menu) => MapEntry(index, _buildTenableListTile(index, menu)))
      .values
      .toList();

  void _save(BuildContext context) {
    String? menuId;
    menuItemList!.forEach((menuItem) {
      menuId = menuItem.menuId;
      restaurant!.restaurantMenus![menuId][menuItem.id]['sequence'] = menuItem.sequence;
    });
    widget.menuItemStream!.broadcastEvent(restaurant!.restaurantMenus![menuId]);
    Restaurant.setRestaurant(database, restaurant);
    Navigator.of(context).pop();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      MenuItem item = menuItemList![oldIndex];
      menuItemList!.removeAt(oldIndex);
      menuItemList!.insert(newIndex, item);
      for (int index = 0; index < menuItemList!.length; index++) {
        menuItemList![index].sequence = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Drag and drop to reorder'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.check),
              iconSize: 32.0,
              onPressed: () => _save(context),
            ),
          ),
        ],
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        children: _getListItems(),
      ),
    );
  }
}
