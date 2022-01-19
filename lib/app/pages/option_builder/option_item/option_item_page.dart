import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/option_item.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/option_builder/option_item/option_item_details_page.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/option_item_observable_stream.dart';
import 'package:provider/provider.dart';

class OptionItemPage extends StatefulWidget {
  final Restaurant? restaurant;
  final Option? option;

  const OptionItemPage({Key? key, this.restaurant, this.option}) : super(key: key);

  @override
  _OptionItemPageState createState() => _OptionItemPageState();
}

class _OptionItemPageState extends State<OptionItemPage> {
  late Session session;
  late Database database;
  OptionItemObservableStream? optionItemStream;
  String? get optionId => widget.option!.id;
  Restaurant? get restaurant => session.currentRestaurant;
  Option? get menu => Option.fromMap(restaurant!.restaurantOptions![optionId], null);

  void _createOptionItemDetailsPage(BuildContext context, OptionItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => OptionItemDetailsPage(
          restaurant: widget.restaurant,
          option: widget.option,
          optionItem: item,
          optionItemStream: optionItemStream,
        ),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, OptionItem item) async {
    try {
      restaurant!.restaurantOptions![optionId].remove(item.id);
      Restaurant.setRestaurant(database, widget.restaurant);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<bool?> _confirmDismiss(BuildContext context) async {
    return await PlatformAlertDialog(
      title: 'Confirm option item deletion',
      content: 'Do you really want to delete this option item?',
      cancelActionText: 'No',
      defaultActionText: 'Yes',
    ).show(context);
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<OptionItem>>(
      stream: optionItemStream!.stream,
      builder: (context, snapshot) {
        return ListItemsBuilder<OptionItem>(
            title: 'No option items found',
            message: 'Tap the + button to add a new option item',
            snapshot: snapshot,
            itemBuilder: (context, item) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key('item-${item.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDismiss(context),
                onDismissed: (direction) => _deleteItem(context, item),
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  child: ListTile(
                    isThreeLine: false,
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
                      ],
                    ),
                    onTap: () => _createOptionItemDetailsPage(context, item),
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    optionItemStream = OptionItemObservableStream(observable: restaurant!.restaurantOptions![optionId]);
    optionItemStream!.init();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.option!.name}', style: TextStyle(color: Theme
            .of(context)
            .appBarTheme
            .backgroundColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).appBarTheme.backgroundColor,),
            iconSize: 32.0,
            padding: const EdgeInsets.only(right: 32.0),
            onPressed: () => _createOptionItemDetailsPage(context, OptionItem(optionId: widget.option!.id)),
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}