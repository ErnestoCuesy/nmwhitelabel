import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/menu_item.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu_item/menu_item_details_form.dart';
import 'package:nmwhitelabel/app/services/menu_item_observable_stream.dart';

class MenuItemDetailsPage extends StatelessWidget {
  final Restaurant? restaurant;
  final Menu? menu;
  final MenuItem? item;
  final MenuItemObservableStream? menuItemStream;
  final int? sequence;

  const MenuItemDetailsPage({
    Key? key,
    this.restaurant,
    this.menu,
    this.item,
    this.menuItemStream,
    this.sequence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter menu item details'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: MenuItemDetailsForm.create(
                context: context,
                menu: menu,
                restaurant: restaurant!,
                item: item,
                menuItemStream: menuItemStream,
                sequence: sequence),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
