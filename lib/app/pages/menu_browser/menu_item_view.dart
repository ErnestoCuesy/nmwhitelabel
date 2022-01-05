import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/orders/add_to_order.dart';
import 'package:provider/provider.dart';

class MenuItemView extends StatefulWidget {
  final Map<dynamic, dynamic>? menu;
  final bool? isLargeScreen;

  MenuItemView({Key? key, this.menu, this.isLargeScreen}) : super(key: key);

  @override
  _MenuItemViewState createState() => _MenuItemViewState();
}

class _MenuItemViewState extends State<MenuItemView> {
  late Session session;
  Map<dynamic, dynamic> sortedMenuItems  = Map<dynamic, dynamic>();
  Map<dynamic, dynamic>? options;
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  late var sortedKeys;
  int? itemCount;
  String? menuName;

  Map<dynamic, dynamic>? get menu => widget.menu;

  Future<void> _exceptionDialog(BuildContext context, String title, String code, String message) async {
    await PlatformExceptionAlertDialog(
      title: title,
      exception: PlatformException(
        code: code,
        message: message,
        details: message,
      ),
    ).show(context);
  }

  Future<void> _addMenuItemToOrder(BuildContext context, String menuCode, Map<dynamic, dynamic> menuItem) async {
    if (FlavourConfig.isAdmin()) {
      return;
    }
    if (session.currentRestaurant!.isOpen || FlavourConfig.isManager()) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute<String>(
          fullscreenDialog: false,
          builder: (context) =>
              AddToOrder.create(
                context: context,
                menuCode: menuCode,
                item: menuItem,
                options: options,
              ),
        ),
      );
      if (result == 'Yes') {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item added to the order.'),
            ),
          );
      }
    } else {
      _exceptionDialog(
        context,
        'Restaurant is closed',
        'RESTAURANT_IS_CLOSED',
        '${session.currentRestaurant!.name} cannot take your order at this moment. Sorry.',
      );
    }
  }

  String _menuCode(String menuName) {
    RegExp consonantFilter = RegExp(r'([^A|E|I|O|U ])');
    Iterable<Match> matchResult =
    consonantFilter.allMatches(menuName.toUpperCase());
    String result = '';
    for (Match m in matchResult) {
      result = result + m.group(0)!;
    }
    result = result + '    ';
    return '[' + result.substring(0, 4) + '] ';
  }

  Widget _buildContents(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        final menuItem = sortedMenuItems[sortedKeys[index]];
        String adjustedName = menuItem['name'];
        int descriptionLength = 70;
        if (adjustedName.length > 20) {
          adjustedName = adjustedName.substring(0, 20) + '...(more)';
          descriptionLength = 50;
        }
        String adjustedDescription = menuItem['description'];
        if (adjustedDescription.length > descriptionLength) {
          adjustedDescription =
              adjustedDescription.substring(0, descriptionLength) + '...(more)';
        }
        return Container(
          height: 90.0,
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: Theme.of(context).primaryColor,
            ),
          ),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '$adjustedName',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, top: 8.0, bottom: 8.0),
              child: Text(
                '$adjustedDescription',
              ),
            ),
            trailing: Text(
              f.format(menuItem['price']),
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () =>
                _addMenuItemToOrder(context, _menuCode(menuName!), menuItem),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    menuName = menu!['name'];
    options = session.currentRestaurant!.restaurantOptions;
    sortedMenuItems.clear();
    itemCount = menu!.entries.where((element) {
      if (element.key.toString().length > 20 &&
          (element.value['hidden'] == null ||
              element.value['hidden'] == false)) {
        sortedMenuItems.putIfAbsent(
            menu![element.key]['sequence'], () => element.value);
        return true;
      } else {
        return false;
      }
    }).toList().length;
    sortedKeys = sortedMenuItems.keys.toList()..sort();
    if (widget.isLargeScreen!) {
      return Material(child: _buildContents(context));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(
                menuName!
            ),
          ),
          body: _buildContents(context)
      );
    }
  }
}
