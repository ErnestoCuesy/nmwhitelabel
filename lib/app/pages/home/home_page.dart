import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/pages/messages/messages_listener.dart';
import 'package:nmwhitelabel/app/pages/sign_in/check_converted_user.dart';
import 'package:nmwhitelabel/app/pages/home/cupertino_home_scaffold.dart';
import 'package:nmwhitelabel/app/pages/home/tab_item.dart';
import 'package:nmwhitelabel/app/pages/restaurant/restaurant_query.dart';
import 'package:nmwhitelabel/app/pages/user/account_page.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TabItem _currentTab = TabItem.restaurant;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.restaurant: GlobalKey<NavigatorState>(),
    TabItem.userAccount: GlobalKey<NavigatorState>()
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.restaurant: (_) => FlavourConfig.isAdmin() ? MessagesListener(child: RestaurantQuery(),) : RestaurantQuery(),
      TabItem.userAccount: (_) => CheckConvertedUser(child: AccountPage(),),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>  !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
        roleTabItems: RoleEnumBase.getRoleTabItems(),
      ),
    );
  }
}
