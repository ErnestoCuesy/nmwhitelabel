import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';

class SubcategoryTotal {
  final String? categoryName;
  final int? quantity;
  final double? amount;

  SubcategoryTotal({this.categoryName, this.quantity, this.amount});
}

class ItemBreakdownReport extends ModalRoute<void> {
  final Map<String?, dynamic>? amounts;
  final Map<String?, dynamic>? quantities;
  List<SubcategoryTotal> subcategoryTotals = [];

  ItemBreakdownReport({this.amounts, this.quantities}) {
    amounts!.forEach((key, value) {
      subcategoryTotals.add(SubcategoryTotal(
        categoryName: key,
        quantity: quantities![key],
        amount: value,
      ));
    });
  }

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        color: Colors.grey[50],
        height: height - 80,
        width: width - 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: height - 200,
              width: width - 100,
              child: _itemsList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                backgroundColor: FlavourConfig.isManager()
                    ? Colors.black
                    : Theme.of(context).colorScheme.background,
                child: Icon(Icons.clear),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemsList() {
    final f = NumberFormat.simpleCurrency(locale: 'en_ZA');
    return ListView.builder(
        itemCount: subcategoryTotals.length,
        itemBuilder: (BuildContext context, int index) {
          final quantity = subcategoryTotals[index].quantity! > 0
              ? subcategoryTotals[index].quantity.toString()
              : '';
          return ListTile(
            isThreeLine: false,
            leading: Text(quantity),
            title: Text(subcategoryTotals[index].categoryName!),
            trailing: Text(f.format(subcategoryTotals[index].amount)),
          );
        });
  }
}
