import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearbymenus/app/common_widgets/form_submit_button.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/orders/add_to_order_model.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class AddToOrder extends StatefulWidget {
  final AddToOrderModel? model;
  final String? menuCode;
  final Map<dynamic, dynamic>? item;
  final Map<dynamic, dynamic>? options;

  const AddToOrder(
      {Key? key, this.model, this.menuCode, this.item, this.options})
      : super(key: key);

  static Widget create({
    required BuildContext context,
    String? menuCode,
    Map<dynamic, dynamic>? item,
    Map<dynamic, dynamic>? options,
  }) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    return ChangeNotifierProvider<AddToOrderModel>(
      create: (context) => AddToOrderModel(
          database: database,
          session: session,
          menuCode: menuCode,
          item: item,
          options: options),
      child: Consumer<AddToOrderModel>(
        builder: (context, model, _) => AddToOrder(
          model: model,
          menuCode: menuCode,
          item: item,
          options: options,
        ),
      ),
    );
  }

  @override
  _AddToOrderState createState() => _AddToOrderState();
}

class _AddToOrderState extends State<AddToOrder> {
  Map<dynamic, dynamic>? get item => widget.item;
  String? get menuCode => widget.menuCode;

  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  List<String> menuItemOptions = [];
  Map<String, int> optionsSelectionCounters = Map<String, int>();
  int quantity = 1;
  double? lineTotal = 0.0;
  String menuCodeAndItemName = '';

  AddToOrderModel? get model => widget.model;

  void _save(BuildContext context) {
    model!.save();
    Navigator.of(context).pop('Yes');
  }

  Widget _buildContents(BuildContext context) {
    lineTotal = widget.item!['price'] * model!.quantity * 1.0;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: MediaQuery.of(context).size.width - 24.0,
          color: Theme.of(context).dialogBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Column(
                children: [
                  SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                    child: Text(
                      item!['name'],
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      item!['description'],
                      //style: Theme.of(context).accentTextTheme.headline5,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  if (item!['options'].isNotEmpty)
                    Column(
                      children: _buildOptions(),
                    ),
                  Column(
                    children: _buildQuantityField(),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    f.format(lineTotal),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  FormSubmitButton(
                    context: context,
                    text: 'Add to order',
                    color: model!.canSave
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    onPressed: model!.canSave ? () => _save(context) : null,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuantityField() {
    return [
      new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new IconButton(
              icon: new Icon(Icons.remove),
              onPressed:
                  model!.quantity == 1 ? null : () => model!.updateQuantity(-1),
            ),
            new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: Colors.grey[700]!,
                  width: 0.5,
                ),
              ),
              child: new SizedBox(
                width: 70.0,
                height: 45.0,
                child: new Center(
                    child: new Text('${model!.quantity}',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center)),
              ),
            ),
            new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () => model!.updateQuantity(1),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildOptions() {
    List<Widget> optionList = [];
    widget.item!['options'].forEach((key) {
      Map<dynamic, dynamic> optionValue = widget.options![key];
      optionList.add(
        Text(
          '${optionValue['name']}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
      var selectionNote;
      var singular = '';
      if (optionValue['numberAllowed'] > 1) {
        selectionNote = 'up to';
        singular = 's';
      } else {
        selectionNote = 'only';
      }
      optionList.add(SizedBox(
        height: 8.0,
      ));
      optionList.add(
        Text(
          'Please select $selectionNote ${optionValue['numberAllowed']} option$singular',
        ),
      );
      optionValue.forEach((key, value) {
        if (key.toString().length > 20) {
          optionList.add(
            CheckboxListTile(
              title: Text(
                '${value['name']}',
              ),
              value: model!
                  .optionCheck('${optionValue['name']}: ${value['name']}'),
              onChanged: (addFlag) => model!.updateOptionsList(
                  optionValue['name'],
                  '${optionValue['name']}: ${value['name']}',
                  addFlag!),
            ),
          );
        }
      });
    });
    return optionList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select your options',
          style:
              TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
      ),
      body: _buildContents(context),
    );
  }
}
