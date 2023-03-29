import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/common_widgets/form_submit_button.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/models/option.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/option_builder/option/option_details_model.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/services/option_observable_stream.dart';
import 'package:provider/provider.dart';

class OptionDetailsForm extends StatefulWidget {
  final OptionDetailsModel? model;

  const OptionDetailsForm({Key? key, this.model}) : super(key: key);

  static Widget create({
    required BuildContext context,
    Option? option,
    Restaurant? restaurant,
    OptionObservableStream? optionStream,
  }) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    return ChangeNotifierProvider<OptionDetailsModel>(
      create: (context) => OptionDetailsModel(
          database: database,
          session: session,
          optionStream: optionStream,
          id: option!.id ?? '',
          name: option.name ?? '',
          numberAllowed: option.numberAllowed ?? 1,
          restaurant: restaurant),
      child: Consumer<OptionDetailsModel>(
        builder: (context, model, _) => OptionDetailsForm(
          model: model,
        ),
      ),
    );
  }

  @override
  _OptionDetailsFormState createState() => _OptionDetailsFormState();
}

class _OptionDetailsFormState extends State<OptionDetailsForm> {
  final TextEditingController _optionNameController = TextEditingController();
  final TextEditingController _numberAllowedController =
      TextEditingController();
  final FocusNode _optionNameFocusNode = FocusNode();
  final FocusNode _numberAllowedFocusNode = FocusNode();

  OptionDetailsModel? get model => widget.model;

  @override
  void initState() {
    super.initState();
    if (model != null) {
      _optionNameController.text = model!.name ?? '';
      _numberAllowedController.text = model!.numberAllowed.toString();
    }
  }

  @override
  void dispose() {
    _optionNameController.dispose();
    _numberAllowedController.dispose();
    _optionNameFocusNode.dispose();
    _numberAllowedFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await model!.save();
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Option',
        exception: e,
      ).show(context);
    }
  }

  void _optionNameEditingComplete() {
    final newFocus = model!.optionNameValidator.isValid(model!.name)
        ? _numberAllowedFocusNode
        : _optionNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _numberAllowedEditingComplete() {
    final newFocus = _numberAllowedFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  List<Widget> _buildChildren() {
    return [
      _buildOptionNameTextField(),
      SizedBox(
        height: 8.0,
      ),
      _numberAllowedTextField(),
      SizedBox(
        height: 16.0,
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

  TextField _buildOptionNameTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _optionNameController,
      focusNode: _optionNameFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Option name',
        hintText: 'i.e.: Pasta or Eggs or Meat',
        errorText: model!.optionNameErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateOptionName,
      onEditingComplete: () => _optionNameEditingComplete(),
    );
  }

  TextField _numberAllowedTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _numberAllowedController,
      focusNode: _numberAllowedFocusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Number of options allowed for choice',
        hintText: 'i.e.: from 1 to max number of options',
        errorText: model!.numberAllowedErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onChanged: (value) => model!.updateNumberAllowed(int.tryParse(value)),
      onEditingComplete: () => _numberAllowedEditingComplete(),
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
          children: _buildChildren(),
        ),
      ),
    );
  }
}
