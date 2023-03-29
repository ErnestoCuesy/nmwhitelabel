import 'package:flutter/material.dart';
import 'package:nearbymenus/app/pages/sign_in/check_converted_user.dart';
import 'package:nearbymenus/app/pages/home/cupertino_home_scaffold.dart';
import 'package:nearbymenus/app/pages/home/tab_item.dart';
import 'package:nearbymenus/app/pages/messages/messages_page.dart';
import 'package:nearbymenus/app/pages/restaurant/restaurant_page.dart';
import 'package:nearbymenus/app/pages/user/account_page.dart';

class HomePageManager extends StatefulWidget {
  @override
  _HomePageManagerState createState() => _HomePageManagerState();
}

class _HomePageManagerState extends State<HomePageManager> {
  TabItem _currentTab = TabItem.restaurant;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.restaurant: GlobalKey<NavigatorState>(),
    TabItem.messages: GlobalKey<NavigatorState>(),
    TabItem.userAccount: GlobalKey<NavigatorState>()
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.restaurant: (_) => RestaurantPage(),
      TabItem.messages: (_) => CheckConvertedUser(child: MessagesPage()),
      TabItem.userAccount: (_) => CheckConvertedUser(
            child: AccountPage(),
          ),
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
      onWillPop: () async =>
          !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
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
