import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/form_submit_button.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'package:nearbymenus/app/pages/user/user_details_model.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class UserDetailsForm extends StatefulWidget {
  final UserDetailsModel? model;

  const UserDetailsForm({Key? key, this.model}) : super(key: key);

  static Widget create({
    required BuildContext context,
    UserDetails? userDetails,
  }) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    String role = ROLE_PATRON;
    if (FlavourConfig.isManager()) {
      role = ROLE_MANAGER;
    } else if (FlavourConfig.isStaff()) {
      role = ROLE_STAFF;
    }
    return ChangeNotifierProvider<UserDetailsModel>(
      create: (context) => UserDetailsModel(
        session: session,
        database: database,
        role: role,
        email: userDetails!.email,
        userName: userDetails.name,
        userAddress1: userDetails.address1,
        userAddress2: userDetails.address2,
        userAddress3: userDetails.address3,
        userAddress4: userDetails.address4,
        userTelephone: userDetails.telephone,
        agreementDate: userDetails.agreementDate,
      ),
      child: Consumer<UserDetailsModel>(
        builder: (context, model, _) => UserDetailsForm(
          model: model,
        ),
      ),
    );
  }

  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userAddress1Controller = TextEditingController();
  final TextEditingController _userAddress2Controller = TextEditingController();
  final TextEditingController _userAddress3Controller = TextEditingController();
  final TextEditingController _userAddress4Controller = TextEditingController();
  final TextEditingController _userTelephoneController =
      TextEditingController();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _userAddress1FocusNode = FocusNode();
  final FocusNode _userAddress2FocusNode = FocusNode();
  final FocusNode _userAddress3FocusNode = FocusNode();
  final FocusNode _userAddress4FocusNode = FocusNode();
  final FocusNode _userTelephoneFocusNode = FocusNode();
  Session? session;

  UserDetailsModel? get model => widget.model;

  @override
  void dispose() {
    _userNameController.dispose();
    _userAddress1Controller.dispose();
    _userAddress2Controller.dispose();
    _userAddress3Controller.dispose();
    _userAddress4Controller.dispose();
    _userTelephoneController.dispose();
    _userNameFocusNode.dispose();
    _userAddress1FocusNode.dispose();
    _userAddress2FocusNode.dispose();
    _userAddress3FocusNode.dispose();
    _userAddress4FocusNode.dispose();
    _userTelephoneFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userNameController.text = model!.userName!;
    _userAddress1Controller.text = model!.userAddress1!;
    _userAddress2Controller.text = model!.userAddress2!;
    _userAddress3Controller.text = model!.userAddress3!;
    _userAddress4Controller.text = model!.userAddress4!;
    _userTelephoneController.text = model!.userTelephone!;
  }

  Future<void> _save() async {
    try {
      // await Future.delayed(Duration(seconds: 3)); // Simulate slow network
      await model!.save();
      Navigator.of(context).pop(true);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Save User Details',
        exception: e,
      ).show(context);
    }
  }

  void _userNameEditingComplete() {
    final newFocus = model!.userNameValidator.isValid(model!.userName)
        ? _userAddress1FocusNode
        : _userNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _userAddress1EditingComplete() {
    final newFocus = model!.userAddressValidator.isValid(model!.userAddress1)
        ? _userAddress2FocusNode
        : _userAddress1FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _userAddress2EditingComplete() {
    final newFocus = model!.userAddressValidator.isValid(model!.userAddress2)
        ? _userAddress3FocusNode
        : _userAddress2FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _userAddress3EditingComplete() {
    final newFocus = model!.userAddressValidator.isValid(model!.userAddress3)
        ? _userAddress4FocusNode
        : _userAddress3FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _userAddress4EditingComplete() {
    final newFocus = model!.userAddressValidator.isValid(model!.userAddress4)
        ? _userTelephoneFocusNode
        : _userAddress4FocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _userTelephoneEditingComplete() {
    final newFocus = model!.userTelephoneValidator.isValid(model!.userTelephone)
        ? _save()
        : _userTelephoneFocusNode;
    FocusScope.of(context).requestFocus(newFocus as FocusNode?);
  }

  List<Widget> _buildChildren() {
    return [
      _buildUserNameTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildUserAddress1TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildUserAddress2TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildUserAddress3TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildUserAddress4TextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildUserTelephoneTextField(),
      SizedBox(
        height: 32.0,
      ),
      FormSubmitButton(
        context: context,
        text: model!.primaryButtonText,
        color: model!.canSave
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
        onPressed: model!.canSave ? _save : null,
      ),
      SizedBox(
        height: 8.0,
      ),
    ];
  }

  TextField _buildUserNameTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _userNameController,
      focusNode: _userNameFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Name',
        hintText: 'Your name',
        errorText: model!.userNameErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateUserName,
      onEditingComplete: () => _userNameEditingComplete(),
    );
  }

  TextField _buildUserAddress1TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _userAddress1Controller,
      focusNode: _userAddress1FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'House or unit number',
        hintText: '123',
        errorText: model!.userAddress1ErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateUserAddress1,
      onEditingComplete: () => _userAddress1EditingComplete(),
    );
  }

  TextField _buildUserAddress2TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _userAddress2Controller,
      focusNode: _userAddress2FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Street or estate name',
        hintText: 'Fifth Avenue',
        errorText: model!.userAddress2ErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateUserAddress2,
      onEditingComplete: () => _userAddress2EditingComplete(),
    );
  }

  TextField _buildUserAddress3TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _userAddress3Controller,
      focusNode: _userAddress3FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Other address information',
        hintText: 'Suburb name',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateUserAddress3,
      onEditingComplete: () => _userAddress3EditingComplete(),
    );
  }

  TextField _buildUserAddress4TextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _userAddress4Controller,
      focusNode: _userAddress4FocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateUserAddress4,
      onEditingComplete: () => _userAddress4EditingComplete(),
    );
  }

  TextField _buildUserTelephoneTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _userTelephoneController,
      focusNode: _userTelephoneFocusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Telephone number',
        hintText: 'Your contact number',
        errorText: model!.userTelephoneErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onChanged: model!.updateUserTelephone,
      onEditingComplete: () => _userTelephoneEditingComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        ),
      ),
    );
  }
}
