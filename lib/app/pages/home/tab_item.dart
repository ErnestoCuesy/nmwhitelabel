import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';

enum TabItem {
  restaurant,
  menu,
  messages,
  userAccount,
}

abstract class RoleEnumBase {
  List<TabItem>? roleEnumList;

  static RoleEnumBase getRoleTabItems() {
    if (FlavourConfig.isManager()) {
      return RoleEnumManager();
    } else {
      return RoleEnumStaffAndPatron();
    }
  }

  static List<BottomNavigationBarItem> itemsForRole(
      BuildContext context, TabItem currentTab, RoleEnumBase roleTabItems) {
    List<BottomNavigationBarItem> items = [];
    roleTabItems.roleEnumList!.forEach((roleItem) {
      items.add(_buildItem(context, roleItem, currentTab));
    });
    return items;
  }

  static BottomNavigationBarItem _buildItem(
      BuildContext context, TabItem tabItem, TabItem currentTab) {
    final itemData = TabItemData.allTabs[tabItem]!;
    // final color = currentTab == tabItem
    //     ? Theme.of(context).tabBarTheme.labelColor
    //     : Theme.of(context).tabBarTheme.unselectedLabelColor;
    return BottomNavigationBarItem(
      icon: Icon(itemData.icon),
      label: itemData.title,
      // title: Text(
      //   itemData.title,
      //   style: TextStyle(color: color),
      // ),
    );
  }
}

class RoleEnumManager extends RoleEnumBase {
  List<TabItem>? roleEnumList = const [
    TabItem.restaurant,
    TabItem.messages,
    TabItem.userAccount,
  ];
}

class RoleEnumStaffAndPatron extends RoleEnumBase {
  List<TabItem>? roleEnumList = const [
    TabItem.restaurant,
    TabItem.userAccount,
  ];
}

class TabItemData {
  const TabItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.restaurant: TabItemData(title: 'Restaurants', icon: Icons.home),
    TabItem.messages: TabItemData(title: 'Messages', icon: Icons.message),
    TabItem.userAccount:
        TabItemData(title: 'Profile', icon: Icons.account_circle),
  };
}
