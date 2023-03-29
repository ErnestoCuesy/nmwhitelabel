import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/date_time_picker.dart';
import 'package:nearbymenus/app/common_widgets/form_submit_button.dart';
import 'package:nearbymenus/app/common_widgets/platform_alert_dialog.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/pages/restaurant/restaurant_details_model.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsForm extends StatefulWidget {
  final RestaurantDetailsModel? model;

  const RestaurantDetailsForm({Key? key, this.model}) : super(key: key);

  static Widget create(BuildContext context, Restaurant? restaurant) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    return ChangeNotifierProvider<RestaurantDetailsModel>(
      create: (context) => RestaurantDetailsModel(
        database: database,
        session: session,
        id: restaurant!.id ?? '',
        managerId: restaurant.managerId ?? '',
        name: restaurant.name ?? '',
        address1: restaurant.address1 ?? '',
        address2: restaurant.address2 ?? '',
        address3: restaurant.address3 ?? '',
        address4: restaurant.address4 ?? '',
        typeOfFood: restaurant.typeOfFood ?? '',
        coordinates: restaurant.coordinates ?? session.position,
        deliveryRadius: restaurant.deliveryRadius ?? 0,
        workingHoursFrom: restaurant.workingHoursFrom ?? TimeOfDay.now(),
        workingHoursTo: restaurant.workingHoursTo ?? TimeOfDay.now(),
        telephoneNumber: restaurant.telephoneNumber ?? '',
        notes: restaurant.notes ?? '',
        active: restaurant.active ?? false,
        open: restaurant.open ?? false,
        acceptingStaffRequests: restaurant.acceptingStaffRequests ?? false,
        acceptCash: restaurant.acceptCash ?? false,
        acceptCard: restaurant.acceptCard ?? false,
        acceptOther: restaurant.acceptOther ?? false,
        foodDeliveries: restaurant.foodDeliveries ?? false,
        foodCollection: restaurant.foodCollection ?? false,
        allowCancellations: restaurant.allowCancellations ?? false,
        vatNumber: restaurant.vatNumber ?? '',
        registrationNumber: restaurant.registrationNumber ?? '',
        adminVerified: restaurant.adminVerified ?? false,
        restaurantMenus: restaurant.restaurantMenus ?? {},
        restaurantOptions: restaurant.restaurantOptions ?? {},
        markerCoordinates: restaurant.markerCoordinates ?? [],
        markerDescription: restaurant.markerNames ?? [],
      ),
      child: Consumer<RestaurantDetailsModel>(
        builder: (context, model, _) => RestaurantDetailsForm(
          model: model,
        ),
      ),
    );
  }

  @override
  _RestaurantDetailsFormState createState() => _RestaurantDetailsFormState();
}

class _RestaurantDetailsFormState extends State<RestaurantDetailsForm> {
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _typeOfFoodController = TextEditingController();
  final TextEditingController _restaurantAddress1Controller =
      TextEditingController();
  final TextEditingController _restaurantAddress2Controller =
      TextEditingController();
  final TextEditingController _restaurantAddress3Controller =
      TextEditingController();
  final TextEditingController _restaurantAddress4Controller =
      TextEditingController();
  final TextEditingController _deliveryRadiusController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _vatNumberController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _telephoneNumberController =
      TextEditingController();
  final FocusNode _restaurantNameFocusNode = FocusNode();
  final FocusNode _typeOfFoodFocusNode = FocusNode();
  final FocusNode _restaurantAddress1FocusNode = FocusNode();
  final FocusNode _restaurantAddress2FocusNode = FocusNode();
  final FocusNode _restaurantAddress3FocusNode = FocusNode();
  final FocusNode _restaurantAddress4FocusNode = FocusNode();
  final FocusNode _deliveryRadiusFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();
  final FocusNode _vatNumberFocusNode = FocusNode();
  final FocusNode _registrationNumberFocusNode = FocusNode();
  final FocusNode _telephoneNumberFocusNode = FocusNode();
  final FocusNode _hoursFromFocusNode = FocusNode();
  final FocusNode _hoursToFocusNode = FocusNode();
  final FocusNode _statusFocusNode = FocusNode();

  TimeOfDay? _openFrom = TimeOfDay.now();
  TimeOfDay? _openTo = TimeOfDay.now();

  RestaurantDetailsModel? get model => widget.model;

  @override
  void initState() {
    super.initState();
    if (model != null) {
      _restaurantNameController.text = model!.name ?? '';
      _typeOfFoodController.text = model!.typeOfFood ?? '';
      _restaurantAddress1Controller.text = model!.address1 ?? '';
      _restaurantAddress2Controller.text = model!.address2 ?? '';
      _restaurantAddress3Controller.text = model!.address3 ?? '';
      _restaurantAddress4Controller.text = model!.address4 ?? '';
      _deliveryRadiusController.text = model!.deliveryRadius.toString();
      _notesController.text = model!.notes ?? '';
      _vatNumberController.text = model!.vatNumber ?? '';
      _registrationNumberController.text = model!.registrationNumber ?? '';
      _telephoneNumberController.text = model!.telephoneNumber ?? '';
      _openFrom = model!.workingHoursFrom ?? null;
      _openTo = model!.workingHoursTo ?? null;
    }
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _typeOfFoodController.dispose();
    _restaurantAddress1Controller.dispose();
    _restaurantAddress2Controller.dispose();
    _restaurantAddress3Controller.dispose();
    _restaurantAddress4Controller.dispose();
    _deliveryRadiusController.dispose();
    _notesController.dispose();
    _vatNumberController.dispose();
    _registrationNumberController.dispose();
    _telephoneNumberController.dispose();
    _restaurantNameFocusNode.dispose();
    _restaurantAddress1FocusNode.dispose();
    _restaurantAddress2FocusNode.dispose();
    _restaurantAddress3FocusNode.dispose();
    _restaurantAddress4FocusNode.dispose();
    _typeOfFoodFocusNode.dispose();
    _deliveryRadiusFocusNode.dispose();
    _notesFocusNode.dispose();
    _vatNumberFocusNode.dispose();
    _registrationNumberFocusNode.dispose();
    _telephoneNumberFocusNode.dispose();
    _hoursFromFocusNode.dispose();
    _hoursToFocusNode.dispose();
    _statusFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    try {
      // await Future.delayed(Duration(seconds: 3)); // Simulate slow network
      final useCurrentLocation = await (PlatformAlertDialog(
        title: 'Confirm restaurant location',
        content:
            'Are you currently at the restaurant? If not, previously saved location, if any, will be preserved.',
        cancelActionText: 'No',
        defaultActionText: 'Yes',
      ).show(context));
      await model!.save(useCurrentLocation!);
      if (!model!.adminVerified) {
        await PlatformAlertDialog(
          title: 'Restaurant content verification',
          content:
              'Your restaurant content needs to be verified first by Nearby Menus before the listing can be activated. We\'ll send you a notification soon.\nHowever, you can continue with your menus set-up.',
          defaultActionText: 'Ok',
        ).show(context);
      }
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Restaurant Details',
        exception: e,
      ).show(context);
    }
  }

  void _restaurantNameEditingComplete() {
    final newFocus = model!.restaurantNameValidator.isValid(model!.name)
        ? _typeOfFoodFocusNode
        : _restaurantNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _typeOfFoodEditingComplete() {
    final newFocus = model!.typeOfFoodValidator.isValid(model!.typeOfFood)
        ? _restaurantAddress1FocusNode
        : _typeOfFoodFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _restaurantAddress1EditingComplete() {
    final newFocus = model!.restaurantAddress1Validator.isValid(model!.address1)
        ? _restaurantAddress2FocusNode
        : _restaurantAddress1FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _restaurantAddress2EditingComplete() {
    final newFocus = model!.restaurantAddress1Validator.isValid(model!.address1)
        ? _restaurantAddress3FocusNode
        : _restaurantAddress2FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _restaurantAddress3EditingComplete() {
    final newFocus = model!.restaurantAddress1Validator.isValid(model!.address1)
        ? _restaurantAddress4FocusNode
        : _restaurantAddress3FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _restaurantAddress4EditingComplete() {
    final newFocus = model!.restaurantAddress1Validator.isValid(model!.address1)
        ? _deliveryRadiusFocusNode
        : _restaurantAddress4FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _deliveryRadiusEditingComplete() {
    final newFocus =
        model!.deliveryRadiusValidator.isValid(model!.deliveryRadius)
            ? _telephoneNumberFocusNode
            : _deliveryRadiusFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _telephoneNumberEditingComplete() {
    final newFocus =
        model!.telephoneNumberValidator.isValid(model!.telephoneNumber)
            ? _notesFocusNode
            : _telephoneNumberFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _notesEditingComplete() {
    FocusScope.of(context).requestFocus(_registrationNumberFocusNode);
  }

  void _registrationNumberEditingComplete() {
    FocusScope.of(context).requestFocus(_vatNumberFocusNode);
  }

  void _vatNumberEditingComplete() {
    FocusScope.of(context).requestFocus(_hoursFromFocusNode);
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      _buildRestaurantNameTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildTypeOfFoodTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildRestaurantAddress1TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildRestaurantAddress2TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildRestaurantAddress3TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildRestaurantAddress4TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildDeliveryRadiusTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildTelephoneNumberTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildNotesTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildRegistrationNumberTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildVatNumberTextField(),
      SizedBox(
        height: 16.0,
      ),
      _buildHoursFromPicker(),
      SizedBox(
        height: 8.0,
      ),
      _buildHoursToTextPicker(),
      SizedBox(
        height: 16.0,
      ),
      // CHECKBOXES
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildAcceptCashCheckBox(),
          _buildAcceptCardCheckBox(),
          _buildAcceptOtherCheckBox(),
          _buildFoodDeliveriesCheckBox(),
          _buildFoodCollectionCheckBox(),
          _buildAllowCancellationsCheckBox(),
        ],
      ),
      SizedBox(
        height: 16.0,
      ),
      // SWITCHES
      Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Activate restaurant listing',
                style: Theme.of(context).inputDecorationTheme.labelStyle,
              ),
              SizedBox(
                height: 8.0,
              ),
              _buildActiveSwitch(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Open restaurant',
                style: Theme.of(context).inputDecorationTheme.labelStyle,
              ),
              SizedBox(
                height: 8.0,
              ),
              _buildOpenSwitch(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Allow staff requests to join',
                style: Theme.of(context).inputDecorationTheme.labelStyle,
              ),
              SizedBox(
                height: 8.0,
              ),
              _buildAcceptingStaffRequestsSwitch()
            ],
          ),
        ],
      ),
      SizedBox(
        height: 16.0,
      ),
      FormSubmitButton(
        context: context,
        text: model!.primaryButtonText,
        color: model!.canSave
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
        onPressed: model!.canSave ? () => _save(context) : null,
      ),
      SizedBox(
        height: 8.0,
      ),
    ];
  }

  TextField _buildRestaurantNameTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _restaurantNameController,
      focusNode: _restaurantNameFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Restaurant name',
        errorText: model!.restaurantNameErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateRestaurantName,
      onEditingComplete: () => _restaurantNameEditingComplete(),
    );
  }

  TextField _buildTypeOfFoodTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _typeOfFoodController,
      focusNode: _typeOfFoodFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Type of cuisine',
        hintText: 'Mexican, Indian, etc.',
        errorText: model!.typeOfFoodErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateTypeOfFood,
      onEditingComplete: () => _typeOfFoodEditingComplete(),
    );
  }

  TextField _buildRestaurantAddress1TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _restaurantAddress1Controller,
      focusNode: _restaurantAddress1FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Restaurant\'s location',
        hintText: 'Shopping mall, estate name or street address',
        errorText: model!.restaurantAddress1ErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateAddress1,
      onEditingComplete: () => _restaurantAddress1EditingComplete(),
    );
  }

  TextField _buildRestaurantAddress2TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _restaurantAddress2Controller,
      focusNode: _restaurantAddress2FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Number and street',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateAddress2,
      onEditingComplete: () => _restaurantAddress2EditingComplete(),
    );
  }

  TextField _buildRestaurantAddress3TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _restaurantAddress3Controller,
      focusNode: _restaurantAddress3FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Suburb',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateAddress3,
      onEditingComplete: () => _restaurantAddress3EditingComplete(),
    );
  }

  TextField _buildRestaurantAddress4TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _restaurantAddress4Controller,
      focusNode: _restaurantAddress4FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Province',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateAddress4,
      onEditingComplete: () => _restaurantAddress4EditingComplete(),
    );
  }

  TextField _buildDeliveryRadiusTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _deliveryRadiusController,
      focusNode: _deliveryRadiusFocusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Discovery radius (in metres)',
        hintText: 'i.e.: 1000',
        errorText: model!.deliveryRadiusErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: (value) => model!.updateDeliveryRadius(int.tryParse(value)),
      onEditingComplete: () => _deliveryRadiusEditingComplete(),
    );
  }

  TextField _buildTelephoneNumberTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _telephoneNumberController,
      focusNode: _telephoneNumberFocusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Telephone number',
        errorText: model!.telephoneNumberErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: (value) => model!.updateTelephoneNumber(value),
      onEditingComplete: () => _telephoneNumberEditingComplete(),
    );
  }

  TextField _buildNotesTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _notesController,
      focusNode: _notesFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Notice to patrons',
        hintText: 'Residents only, delivery only, closed on holidays, etc.',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (value) => model!.updateNotes(value),
      onEditingComplete: () => _notesEditingComplete(),
    );
  }

  TextField _buildRegistrationNumberTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _registrationNumberController,
      focusNode: _registrationNumberFocusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Registration Number',
        hintText: '',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (value) => model!.updateRegistrationNumber(value),
      onEditingComplete: () => _registrationNumberEditingComplete(),
    );
  }

  TextField _buildVatNumberTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _vatNumberController,
      focusNode: _vatNumberFocusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'VAT Number',
        hintText: '',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: (value) => model!.updateVatNumber(value),
      onEditingComplete: () => _vatNumberEditingComplete(),
    );
  }

  Widget _buildHoursFromPicker() {
    return DateTimePicker(
      labelText: 'Open from',
      selectedDate: null,
      selectedTime: _openFrom,
      onSelecedtDate: null,
      onSelectedTime: (time) {
        print('Hours from: ${time.toString()}');
        model!.updateWorkingHoursFrom(time);
        setState(() {
          _openFrom = time;
        });
      },
    );
  }

  Widget _buildHoursToTextPicker() {
    return DateTimePicker(
      labelText: 'Open until',
      selectedDate: null,
      selectedTime: _openTo,
      onSelecedtDate: null,
      onSelectedTime: (time) {
        print('Hours to: ${time.toString()}');
        model!.updateWorkingHoursTo(time);
        setState(() {
          _openTo = time;
        });
      },
    );
  }

  Widget _buildAcceptCashCheckBox() {
    final currencySymbol = NumberFormat.simpleCurrency(locale: "en_ZA");
    return CheckboxListTile(
      title: const Text('Cash accepted'),
      value: model!.acceptCash,
      onChanged: model!.updateAcceptCash,
      //secondary: const Icon(Icons.euro_symbol),
      secondary: Text(currencySymbol.currencySymbol),
    );
  }

  Widget _buildAcceptCardCheckBox() {
    return CheckboxListTile(
      title: const Text('Card accepted'),
      value: model!.acceptCard,
      onChanged: model!.updateAcceptCard,
      secondary: const Icon(Icons.credit_card),
    );
  }

  Widget _buildAcceptOtherCheckBox() {
    return CheckboxListTile(
      title: const Text('Other'),
      value: model!.acceptOther,
      onChanged: model!.updateAcceptOther,
      secondary: const Icon(Icons.flash_on),
    );
  }

  Widget _buildFoodDeliveriesCheckBox() {
    return CheckboxListTile(
      title: const Text('Food deliveries'),
      value: model!.foodDeliveries,
      onChanged: model!.updateFoodDeliveries,
      secondary: const Icon(Icons.motorcycle),
    );
  }

  Widget _buildFoodCollectionCheckBox() {
    return CheckboxListTile(
      title: const Text('Food collection'),
      value: model!.foodCollection,
      onChanged: model!.updateFoodCollection,
      secondary: const Icon(Icons.home),
    );
  }

  Widget _buildAllowCancellationsCheckBox() {
    return CheckboxListTile(
      title: const Text('Allow order cancellation'),
      value: model!.allowCancellations,
      onChanged: model!.updateAllowCancellations,
      secondary: const Icon(Icons.delete_forever),
    );
  }

  Widget _buildActiveSwitch() {
    return CupertinoSwitch(
      value: model!.active,
      onChanged: model!.updateActive,
    );
  }

  Widget _buildOpenSwitch() {
    return CupertinoSwitch(
      value: model!.open,
      onChanged: model!.updateOpen,
    );
  }

  Widget _buildAcceptingStaffRequestsSwitch() {
    return CupertinoSwitch(
      value: model!.acceptingStaffRequests,
      onChanged: model!.updateAcceptingStaffRequests,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(context),
        ),
      ),
    );
  }
}
