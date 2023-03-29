import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_trailing_icon.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/option_builder/option/option_details_page.dart';
import 'package:nmwhitelabel/app/pages/option_builder/option_item/option_item_page.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/option_observable_stream.dart';
import 'package:provider/provider.dart';

class OptionPage extends StatefulWidget {
  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  late Session session;
  late Database database;
  OptionObservableStream? optionStream;
  Restaurant? get restaurant => session.currentRestaurant;

  void _createOptionDetailsPage(BuildContext context, Option option) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => OptionDetailsPage(
          restaurant: restaurant,
          option: option,
          optionStream: optionStream,
        ),
      ),
    );
  }

  Future<void> _deleteOption(BuildContext context, Option option) async {
    try {
      restaurant!.restaurantOptions!.remove(option.id);
      optionStream!.broadcastEvent(
          restaurant!.restaurantOptions as Map<String?, dynamic>?);
      Restaurant.setRestaurant(database, restaurant);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<bool?> _confirmDismiss(BuildContext context, Option option) async {
    var message = '';
    var inUse = false;
    var hasChildren = false;
    if (restaurant!.restaurantOptions != null &&
        restaurant!.restaurantOptions!.isNotEmpty) {
      if (restaurant!.restaurantOptions![option.id]['usedByMenuItems'].length >
          0) {
        inUse = true;
        message =
            'Please first unselect this option from the menu items that are using it.';
      }
      if (!inUse) {
        restaurant!.restaurantOptions![option.id].forEach((key, value) {
          if (key.toString().length > 20) {
            hasChildren = true;
            message = 'Please delete all the option items first.';
          }
        });
      }
    }
    late bool? result;
    if (inUse || hasChildren) {
      result = await (PlatformExceptionAlertDialog(
        title: 'Option is in use or is not empty',
        exception: PlatformException(
          code: 'MAP_IS_NOT_EMPTY',
          message: message,
          details: message,
        ),
      ).show(context));
      result = !result!;
    } else {
      result = await PlatformAlertDialog(
        title: 'Confirm option deletion',
        content: 'Do you really want to delete this option?',
        cancelActionText: 'No',
        defaultActionText: 'Yes',
      ).show(context);
    }
    return result;
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<Option>>(
      stream: optionStream!.stream,
      builder: (context, snapshot) {
        return ListItemsBuilder<Option>(
            title: 'No options found',
            message: 'Tap the + button to add a new option',
            snapshot: snapshot,
            itemBuilder: (context, option) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key('option-${option.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDismiss(context, option),
                onDismissed: (direction) => _deleteOption(context, option),
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  child: ListTile(
                    isThreeLine: false,
                    // leading: Icon(Icons.link),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          option.name!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => OptionItemPage(
                            restaurant: restaurant,
                            option: option,
                          ),
                        ),
                      ),
                      icon: PlatformTrailingIcon(),
                    ),
                    onTap: () => _createOptionDetailsPage(context, option),
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    optionStream = OptionObservableStream(
        observable: session.currentRestaurant!.restaurantOptions
            as Map<String?, dynamic>?);
    optionStream!.init();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${restaurant!.name}',
          style:
              TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            iconSize: 32.0,
            padding: const EdgeInsets.only(right: 32.0),
            onPressed: () => _createOptionDetailsPage(context, Option()),
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}
