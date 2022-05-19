import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';

class ExtraFields {
  double? tip;
  double? discount;
  double? cashReceived;
  Map<String, double?>? splitAmounts;

  ExtraFields({this.tip = 0.0, this.discount = 0.0, this.cashReceived, this.splitAmounts});
}

class OrderSettlement extends StatefulWidget {
  final int? orderStatus;
  final double? orderAmount;
  final ExtraFields? extraFields;

  const OrderSettlement({Key? key, this.orderStatus, this.orderAmount, this.extraFields}) : super(key: key);

  @override
  _OrderSettlementState createState() => _OrderSettlementState();
}

class _OrderSettlementState extends State<OrderSettlement> {
  final TextEditingController _tipController =  TextEditingController();
  final FocusNode _tipFocusNode = FocusNode();
  final TextEditingController _discountController =  TextEditingController();
  final FocusNode _discountFocusNode = FocusNode();
  final TextEditingController _cashReceivedController =  TextEditingController();
  final FocusNode _cashReceivedFocusNode = FocusNode();
  final TextEditingController _cashChangeController =  TextEditingController();
  final Map<String, TextEditingController> _editingControllerMap = Map<String, TextEditingController>();
  final Map<String, FocusNode> _focusNodeMap = Map<String, FocusNode>();
  ExtraFields? extraFields;
  double? orderAmount;
  double? totalAmount;
  double? splitAmount;
  final f = NumberFormat.simpleCurrency(locale: "en_ZA", decimalDigits: 2);
  final ff = NumberFormat('0.00', 'en_ZA');
  final fff = NumberFormat('0.00', 'en_ZA');

  @override
  void initState() {
    super.initState();
    orderAmount = widget.orderAmount;
    extraFields = widget.extraFields;
    totalAmount = orderAmount;
    _tipController.text = ff.format(extraFields!.tip);
    _discountController.text = fff.format(extraFields!.discount! * 100);
    extraFields!.splitAmounts!.forEach((key, value) {
      _editingControllerMap.putIfAbsent(key, () => TextEditingController(text: ff.format(value)));
      _focusNodeMap.putIfAbsent(key, () => FocusNode());
    });
    _recalculate();
  }

  @override
  void dispose() {
    _tipController.dispose();
    _discountController.dispose();
    _tipFocusNode.dispose();
    _discountFocusNode.dispose();
    _cashReceivedController.dispose();
    _cashReceivedFocusNode.dispose();
    _cashChangeController.dispose();
    _editingControllerMap.forEach((key, controller) {
      controller.dispose();
    });
    _focusNodeMap.forEach((key, node) {
      node.dispose();
    });
    super.dispose();
  }

  void _recalculate() {
    setState(() {
      totalAmount = double.parse((orderAmount! - (orderAmount! * extraFields!.discount!) + extraFields!.tip!).toStringAsFixed(2));
      final key = _editingControllerMap.keys.elementAt(0);
      extraFields!.splitAmounts![key] = totalAmount;
      _editingControllerMap.values.elementAt(0).text = ff.format(totalAmount);
    });
  }

  TextField _buildTipTextField(BuildContext context) {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _tipController,
      focusNode: _tipFocusNode,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Tip amount in ${f.currencySymbol}',
        hintText: 'i.e.: 5.00, 10.99',
        errorText: '',
        enabled: true,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        var amount = value.replaceAll(RegExp(r','), '.');
        extraFields!.tip = double.tryParse(amount);
        _recalculate();
      },
      onEditingComplete: () => FocusScope.of(context).requestFocus(_discountFocusNode),
    );
  }

  TextField _buildDiscountTextField(BuildContext context) {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _discountController,
      focusNode: _discountFocusNode,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Discount percentage (%)',
        hintText: 'i.e.: 5, 10, 20',
        errorText: '',
        enabled: true,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        var amount = value.replaceAll(RegExp(r','), '.');
        var percent = double.tryParse(amount)! / 100;
        var percentString = percent.toStringAsFixed(2);
        extraFields!.discount = double.parse(percentString);
        _recalculate();
      },
      onEditingComplete: () => FocusScope.of(context).requestFocus(_tipFocusNode),
    );
  }

  TextField _cashReceivedTextField(BuildContext context) {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _cashReceivedController,
      focusNode: _cashReceivedFocusNode,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Cash received',
        hintText: 'i.e.: 5.00, 10.00, 20.00',
        errorText: '',
        enabled: true,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          //String cashPortionText = _editingControllerMap['Cash'].text.replaceAll(',', '.');
          //final cashPortion = double.tryParse(cashPortionText);
          final cashPortion = extraFields!.splitAmounts!['Cash']!;
          var amount = value.replaceAll(RegExp(r','), '.');
          final cashOnHand = double.tryParse(amount)!;
          extraFields!.cashReceived = cashOnHand;
          final change = cashOnHand - cashPortion;
          _cashChangeController.text = ff.format(change);
        });
      },
      onEditingComplete: () => FocusScope.of(context).requestFocus(_cashReceivedFocusNode),
    );
  }

  TextField _cashChangeTextField(BuildContext context) {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _cashChangeController,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Change',
        errorText: '',
        enabled: false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
    );
  }

  Widget _buildExtraCashFields(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _cashReceivedTextField(context),
              _cashChangeTextField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitAmounts(BuildContext context) {
    List<Widget> splitAmountsWidgets = [];
    final sortedKeys = extraFields!.splitAmounts!.keys.toList()..sort();
    sortedKeys.forEach((key) {
      splitAmountsWidgets.add(TextField(
        style: Theme.of(context).inputDecorationTheme.labelStyle,
        controller: _editingControllerMap[key],
        focusNode: _focusNodeMap[key],
        cursorColor: Colors.white,
        decoration: InputDecoration(
          labelText: '$key amount',
          hintText: 'i.e.: 5.00, 10.99',
          errorText: '',
          enabled: true,
        ),
        autocorrect: false,
        enableSuggestions: false,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          var amount = value.replaceAll(RegExp(r','), '.');
          extraFields!.splitAmounts![key] = double.tryParse(amount);
        },
        onEditingComplete: () {},
      ));
      if (key == 'Cash' && !FlavourConfig.isPatron()) {
        splitAmountsWidgets.add(_buildExtraCashFields(context));
      }
    });
    return Column(
      children: splitAmountsWidgets,
    );
  }

  double _amountsDifference() {
    double accumulator = 0;
    extraFields!.splitAmounts!.forEach((key, amount) {
      accumulator = accumulator + amount!;
    });
    return double.parse((accumulator - totalAmount!).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            FlavourConfig.isPatron() ? 'Add tip' : 'Add tip and discount',
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.grey[50],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Subtotal: ${f.format(orderAmount)}',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                            if (!FlavourConfig.isPatron())
                              _buildDiscountTextField(context),
                            //if (widget.orderStatus == ORDER_ON_HOLD)
                            _buildTipTextField(context),
                            _buildSplitAmounts(context),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Total: ${f.format(totalAmount)}',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      //backgroundColor: FlavourConfig.isManager() ? Colors.black : Theme.of(context).backgroundColor,
                      child: Icon(Icons.check_circle, size: 48.0, color: Theme.of(context).floatingActionButtonTheme.foregroundColor),
                      onPressed: () async {
                        final amountsDifference = _amountsDifference();
                        if (amountsDifference == 0) {
                          Navigator.of(context).pop(extraFields);
                        } else {
                          await PlatformExceptionAlertDialog(
                              title: 'Amounts don\'t match',
                              exception: PlatformException(
                              code: 'ORDER_AMOUNTS_NOT_MATCH',
                              message:
                              'Split amounts sum and order total do not match. Difference: ${f.format(amountsDifference)}',
                              details:
                              'Split amounts sum and order total do not match.',
                          ),
                        ).show(context);
                      }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
