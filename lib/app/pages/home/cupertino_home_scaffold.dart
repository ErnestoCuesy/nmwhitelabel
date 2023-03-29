import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/home/tab_item.dart';
import 'package:provider/provider.dart';

class CupertinoHomeScaffold extends StatelessWidget {
  const CupertinoHomeScaffold({
    Key? key,
    required this.currentTab,
    required this.onSelectTab,
    required this.widgetBuilders,
    required this.navigatorKeys,
    required this.roleTabItems,
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  final Map<TabItem, WidgetBuilder> widgetBuilders;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;
  final RoleEnumBase roleTabItems;

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<Session>(context);
    return Stack(children: <Widget>[
      CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: FlavourConfig.isManager()
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.background,
          activeColor: Theme.of(context).colorScheme.secondary,
          items: RoleEnumBase.itemsForRole(context, currentTab, roleTabItems),
          onTap: (index) => onSelectTab(roleTabItems.roleEnumList![index]),
        ),
        resizeToAvoidBottomInset: false,
        tabBuilder: (context, index) {
          final item = roleTabItems.roleEnumList![index];
          return CupertinoTabView(
            builder: (context) => widgetBuilders[item]!(context),
            navigatorKey: navigatorKeys[item],
          );
        },
      ),
      if (FlavourConfig.isManager())
        StreamBuilder<int>(
            stream: session.messageCounterObservable,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data! > 0) {
                return Positioned(
                  right: MediaQuery.of(context).size.width / 2 - 35,
                  bottom: 25,
                  child: Container(
                    height: 20.0,
                    width: 20.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 35.0, right: 5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.red),
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
                  right: MediaQuery.of(context).size.width / 2 - 35,
                  bottom: 25,
                  child: Container(
                    height: 20.0,
                    width: 20.0,
                  ),
                );
              }
            }),
    ]);
  }
}
