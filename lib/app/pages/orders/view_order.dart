import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/form_submit_button.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/order.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/map/map_route.dart';
import 'package:nmwhitelabel/app/pages/orders/order_settlement.dart';
import 'package:nmwhitelabel/app/pages/orders/view_order_model.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/utilities/format.dart';
import 'package:provider/provider.dart';

class ViewOrder extends StatefulWidget {
  final ViewOrderModel? model;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const ViewOrder({Key? key, this.model, this.scaffoldKey}) : super(key: key);

  static Widget create({
    required BuildContext context,
    GlobalKey<ScaffoldState>? scaffoldKey,
    Order? order,
  }) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    return ChangeNotifierProvider<ViewOrderModel>(
      create: (context) => ViewOrderModel(
          database: database,
          session: session,
          order: order,
          automaticallyCloseOrder: false
      ),
      child: Consumer<ViewOrderModel>(
        builder: (context, model, _) => ViewOrder(
          scaffoldKey: scaffoldKey,
          model: model,
        ),
      ),
    );
  }

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  late Session session;
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  ScrollController orderScrollController = ScrollController();
  ScrollController itemsScrollController = ScrollController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  int deliveryOptionsAvailable = 0;
  int orderDistance = 0;

  ViewOrderModel? get model => widget.model;
  GlobalKey<ScaffoldState>? get scaffoldKey => widget.scaffoldKey;

  @override
  void initState() {
    super.initState();
    _getOrderDistance();
    _notesController.text = model!.order!.notes!;
  }

  void _getOrderDistance() async {
    orderDistance = await model!.orderDistance;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDismiss(BuildContext context) async {
    if (model!.order!.status != ORDER_ON_HOLD) {
      return false;
    }
    bool? result = await PlatformAlertDialog(
      title: 'Confirm order item deletion',
      content: 'Do you really want to delete this order item?',
      cancelActionText: 'No',
      defaultActionText: 'Yes',
    ).show(context);
    return result;
  }

  void _deleteItem(int index) {
    model!.deleteOrderItem(index);
    //scaffoldKey.currentState.removeCurrentSnackBar();
    //widget.callBack();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  Future<bool?> _confirmCancelOrder(BuildContext context) async {
    bool? result = await PlatformAlertDialog(
      title: 'Confirm order cancellation',
      content: 'Do you really want to cancel this order?',
      cancelActionText: 'No',
      defaultActionText: 'Yes',
    ).show(context);
    return result;
  }

  void _cancelOrder(BuildContext context) async {
    final bool? cancelOrder = await (_confirmCancelOrder(context));
    if (cancelOrder!) {
      model!.cancelOnHoldOrder();
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order cancelled'
            ),
          ),
      );  
      Navigator.of(context).pop();
    }
  }

  void _orderSettlement(BuildContext context) async {
    ExtraFields? extraFields = ExtraFields();
    await Navigator.of(context).push(
        MaterialPageRoute<ExtraFields>(
            fullscreenDialog: true,
            builder: (context) =>
                OrderSettlement(
                  orderStatus: model!.order!.status,
                  orderAmount: model!.order!.orderTotal,
                  extraFields: ExtraFields(
                    tip: model!.order!.tip,
                    discount: model!.order!.discount,
                    cashReceived: model!.order!.cashReceived,
                    splitAmounts: model!.order!.paymentMethods,
                  ),
                )
        )
    ).then((value) {
      extraFields = value;
    });
    if (extraFields != null) {
      model!.updateTip(extraFields!.tip ?? 0);
      model!.updateDiscount(extraFields!.discount ?? 0);
      model!.updateCashReceived(extraFields!.cashReceived ?? 0);
      extraFields!.splitAmounts!.forEach((key, newValue) {
        model!.updatePaymentMethodAmount(key, newValue);
      });
    }
  }

  void _save(BuildContext context) {
    model!.save();
    // scaffoldKey.currentState
    //   ..removeCurrentSnackBar()
    //   ..showSnackBar(
    //   SnackBar(
    //     content: Text(
    //         'Order successfully placed at ${session.currentRestaurant.name}!'
    //     ),
    //   ),
    // );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Order successfully placed at ${session.currentRestaurant!.name}!'
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  Widget? _buildContents(BuildContext context) {
    if (model!.order == null) {
      return null;
    }
    session.currentRestaurant!.foodDeliveryFlags!.forEach((key, value) {
      if (value) deliveryOptionsAvailable++;
    });
    final discount = model!.order!.orderTotal * model!.order!.discount!;
    final orderTotal = model!.order!.orderTotal - discount + model!.order!.tip!;
    return SingleChildScrollView(
      controller: orderScrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width - 16.0,
          color: Theme.of(context).dialogBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Column(
                children: [
                  SizedBox(
                    height: 16.0,
                  ),
                  if (model!.order!.status != ORDER_ON_HOLD)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24.0),
                    child: Text(
                      'Order # ${model!.order!.orderNumber}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24.0),
                    child: Text(
                      'Deliver to:',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(model!.order!.name!),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(model!.order!.deliveryAddress!),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Tel: ${model!.order!.telephone}'),
                  ),
                  if (!FlavourConfig.isPatron())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Order placed $orderDistance metres from you'),
                  ),
                  SizedBox(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Scrollbar(
                        isAlwaysShown: true,
                        controller: itemsScrollController,
                        child: ListView.builder(
                          controller: itemsScrollController,
                          shrinkWrap: true,
                          itemCount: model!.order!.orderItems!.length,
                          itemBuilder: (BuildContext context, int index) {
                          final orderItem = model!.order!.orderItems![index];
                          final List<dynamic> orderItemOptions = orderItem['options'];
                          return Dismissible(
                            background: Container(
                              color: Colors.red,
                              child: model!.order!.status == ORDER_ON_HOLD
                                  ? Icon(Icons.delete, size: 32.0,)
                                  : Icon(Icons.block, size: 32.0),
                            ),
                            key: Key('${orderItem['id']}'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDismiss(context),
                            onDismissed: (direction) => _deleteItem(index),
                            child: Card(
                              child: ListTile(
                                isThreeLine: false,
                                leading: Text(
                                  orderItem['quantity'].toString(),
                                ),
                                title: Row(
                                  children: [
                                    SizedBox(
                                      width: 80.0,
                                      child: Text(orderItem['menuCode']),
                                    ),
                                    Expanded(
                                      child: Text(
                                        orderItem['name'],
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: orderItemOptions.isEmpty ? Text('') : Text(
                                  orderItem['options'].toString().replaceAll(RegExp(r'\[|\]'), ''),
                                ),
                                trailing: Text(
                                    f.format(orderItem['lineTotal'])
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  if (model!.order!.status == ORDER_ON_HOLD)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Swipe items to the left to remove.'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Subtotal: ' + f.format(model!.order!.orderTotal),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  if (model!.order!.discount! > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Discount: ' + f.format(discount),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  if (model!.order!.tip! > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tip: ' + f.format(model!.order!.tip),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total: ' + f.format(orderTotal),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  if (model!.order!.status == ORDER_ON_HOLD)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Select payment method',
                    ),
                  ),
                  Column(
                     children: _buildPaymentMethods(),
                  ),
                  if (model!.order!.status == ORDER_ON_HOLD && deliveryOptionsAvailable > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Select delivery option',
                      ),
                    ),
                  Column(
                    children: _buildFoodDeliveryOptions(),
                  ),
                  Text(
                      Format.formatDateTime(model!.order!.timestamp!.toInt()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Order status: ${model!.order!.statusString}'
                    ),
                  ),
                  _notesField(context, model!.order!.notes),
                  if (model!.order!.status == ORDER_ON_HOLD ||
                      (!FlavourConfig.isPatron() && model!.order!.status != ORDER_CLOSED))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: FormSubmitButton(
                        context: context,
                        text: 'Order Settlement',
                        color: model!.canSettleOrder
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        onPressed: model!.canSettleOrder ? () => _orderSettlement(context) : null,
                      ),
                    ),
                  if (model!.order!.status == ORDER_ON_HOLD)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FormSubmitButton(
                              context: context,
                              text: 'Cancel',
                              color: Theme.of(context).primaryColor,
                              onPressed: () => _cancelOrder(context),
                            ),
                            Builder(
                              builder: (context) => FormSubmitButton(
                                context: context,
                                text: 'Submit',
                                color: model!.canSave
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor,
                                onPressed: model!.canSave ? () => _save(context) : null,
                              ),
                            ),
                          ],
                        ),
                        if (!FlavourConfig.isPatron())
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CheckboxListTile(
                            title: Text(
                            'Automatically close order',
                            ),
                            value: model!.automaticallyCloseOrder,
                            onChanged: (flag) => model!.updateAutomaticallyCloseOrder(flag),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ORDER PROCESSING
                  if (_canCancelOrder())
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 200.0,
                            child: FormSubmitButton(
                              context: context,
                              text: 'CANCEL',
                              color: Theme.of(context).primaryColor,
                              onPressed: () => _processOrder(context, ORDER_CANCELLED),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (model!.order!.status != ORDER_ON_HOLD &&
                      !FlavourConfig.isPatron())
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 200.0,
                            child: FormSubmitButton(
                              context: context,
                              text: 'ACCEPT',
                              color: model!.canDoThis(ORDER_ACCEPTED)!
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              onPressed: model!.canDoThis(ORDER_ACCEPTED)!
                                  ? () => _processOrder(context, ORDER_ACCEPTED)
                                  : null,
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          SizedBox(
                            width: 200.0,
                            child: FormSubmitButton(
                              context: context,
                              text: 'REJECT',
                              color: model!.canDoThis(ORDER_REJECTED_BUSY)!
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              onPressed: model!.canDoThis(ORDER_REJECTED_BUSY)!
                                  ? () => _processOrder(context, ORDER_REJECTED_BUSY)
                                  : null,
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          SizedBox(
                            width: 200.0,
                            child: FormSubmitButton(
                              context: context,
                              text: 'READY',
                              color: model!.canDoThis(ORDER_READY)!
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              onPressed: model!.canDoThis(ORDER_READY)!
                                  ? () => _processOrder(context, ORDER_READY)
                                  : null,
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          SizedBox(
                            width: 200.0,
                            child: FormSubmitButton(
                              context: context,
                              text: 'DELIVER',
                              color: model!.canDoThis(ORDER_DELIVERING)!
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              onPressed: model!.canDoThis(ORDER_DELIVERING)!
                                  ? () => _deliverOrder(context)
                                  : null,
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          SizedBox(
                            width: 200.0,
                            child: FormSubmitButton(
                              context: context,
                              text: 'CLOSE',
                              color: model!.canDoThis(ORDER_CLOSED)!
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              onPressed: model!.canDoThis(ORDER_CLOSED)!
                                  ? () => _processOrder(context, ORDER_CLOSED)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deliverOrder(BuildContext context) {
    _processOrder(context, ORDER_DELIVERING);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => MapRoute(
          currentLocation: session.position,
          destination: model!.order!.deliveryPosition,
        ),
      ),
    );
  }

  bool _canCancelOrder() {
    return FlavourConfig.isPatron() &&
            session.currentRestaurant!.allowCancellations! &&
            model!.order!.status == ORDER_PLACED;
  }

  void _processOrder(BuildContext context, int newOrderStatus) async {
    int orderStatus = newOrderStatus;
    if (newOrderStatus == ORDER_REJECTED_BUSY) {
      bool rejectBusy = await (PlatformAlertDialog(
        title: 'Reject order',
        content: 'Tap on the suitable reason of rejection.',
        cancelActionText: 'We\'re out of stock',
        defaultActionText: 'We can\'t attend your order',
      ).show(context) as FutureOr<bool>);
      if (rejectBusy) {
        orderStatus = ORDER_REJECTED_BUSY;
      } else {
        orderStatus = ORDER_REJECTED_STOCK;
      }
    }
    model!.processOrder(orderStatus);
    Navigator.of(context).pop();
  }

  Widget _notesField(BuildContext context, String? notes) {
    var notesField;
    if (session.currentOrder != null && session.currentOrder!.status == ORDER_ON_HOLD) {
      notesField = TextField(
        style: Theme.of(context).inputDecorationTheme.labelStyle,
        controller: _notesController,
        focusNode: _notesFocusNode,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: 'Notes',
          enabled: model!.isLoading == false,
        ),
        autocorrect: false,
        enableSuggestions: false,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onChanged: model!.updateNotes,
        onEditingComplete: _notesEditingComplete,
      );
    } else {
      notesField = Text(notes!);
    }
    return Column(
      children: [
        Text(
          'Notes',
          style: Theme.of(context).textTheme.headline5,
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: notesField,
        )
      ],
    );
  }

  void _notesEditingComplete() {
    FocusScope.of(context).requestFocus(_notesFocusNode);
  }

  List<Widget> _buildPaymentMethods() {
    List<Widget> paymentOptionsList = [];
    Map<dynamic, dynamic> restaurantPaymentOptions = session.currentRestaurant!.paymentFlags!;
    restaurantPaymentOptions.forEach((key, value) {
      if (value) {
        paymentOptionsList.add(
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text(
                      key,
                    ),
                    value: model!.order!.paymentMethod == ''
                        ? model!.paymentOptionsCheck(key)
                        : model!.paymentOptionCheck(key),
                    onChanged: (flag) => model!.updatePaymentMethods(key, flag),
                  ),
                ),
                Expanded(
                  child: Text(
                      model!.order!.paymentMethods![key] != null && model!.order!.paymentMethods![key]! > 0
                          ? f.format(model!.order!.paymentMethods![key])
                          : '',
                  ),
                ),
              ],
            ),
        );
      }
    });
    return paymentOptionsList;
  }

  List<Widget> _buildFoodDeliveryOptions() {
    List<Widget> foodDeliveryOptionsList = [];
    Map<dynamic, dynamic> foodDeliveryOptions = session.currentRestaurant!.foodDeliveryFlags!;
    foodDeliveryOptions.forEach((key, value) {
      if (value) {
        foodDeliveryOptionsList.add(CheckboxListTile(
          title: Text(
            key,
          ),
          value: model!.foodDeliveryOptionCheck(key),
          onChanged: (flag) => model!.updateFoodDeliveryOption(key, flag),
        ));
      }
    });
    return foodDeliveryOptionsList;
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your order details',
          style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
      ),
      body: _buildContents(context),
    );
  }
}
