import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/menu_observable_stream.dart';
import 'package:provider/provider.dart';

class ReorderMenu extends StatefulWidget {
  final MenuObservableStream? menuStream;
  final List<Menu>? menuList;

  const ReorderMenu({Key? key, this.menuStream, this.menuList}) : super(key: key);

  @override
  _ReorderMenuState createState() => _ReorderMenuState();
}

class _ReorderMenuState extends State<ReorderMenu> {
  late Session session;
  late Database database;
  List<Menu>? get menuList => widget.menuList;
  Restaurant? get restaurant => session.currentRestaurant;

  Card _buildTenableListTile(int index, Menu menu) =>
      Card(
        key: ValueKey(menu.id),
        child: ListTile(
          isThreeLine: false,
          leading: Text('#$index'),
          title: Text(
            menu.name!,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      );

  List<Card> _getListItems() => menuList!
      .asMap()
      .map((index, menu) => MapEntry(index, _buildTenableListTile(index, menu)))
      .values
      .toList();

  void _save(BuildContext context) {
    menuList!.forEach((menu) {
      restaurant!.restaurantMenus![menu.id]['sequence'] = menu.sequence;
    });
    widget.menuStream!.broadcastEvent(restaurant!.restaurantMenus as Map<String?, dynamic>?);
    Restaurant.setRestaurant(database, restaurant);
    Navigator.of(context).pop();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      Menu item = menuList![oldIndex];
      menuList!.removeAt(oldIndex);
      menuList!.insert(newIndex, item);
      for (int index = 0; index < menuList!.length; index++) {
        menuList![index].sequence = index;
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
