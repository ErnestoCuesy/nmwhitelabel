import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/menu.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/pages/menu_builder/menu/menu_details_form.dart';
import 'package:nmwhitelabel/app/services/menu_observable_stream.dart';

class MenuDetailsPage extends StatelessWidget {
  final Restaurant? restaurant;
  final Menu? menu;
  final MenuObservableStream? menuStream;
  final int? sequence;

  const MenuDetailsPage(
      {Key? key, this.menu, this.restaurant, this.menuStream, this.sequence})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter menu details'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: MenuDetailsForm.create(
              context: context,
              restaurant: restaurant,
              menu: menu,
              menuStream: menuStream,
              sequence: sequence,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
