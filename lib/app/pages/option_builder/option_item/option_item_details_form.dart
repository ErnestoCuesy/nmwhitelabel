import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmwhitelabel/app/common_widgets/form_submit_button.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/option_item.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/option_item_observable_stream.dart';
import 'package:provider/provider.dart';

import 'option_item_details_model.dart';

class OptionItemDetailsForm extends StatefulWidget {
  final OptionItemDetailsModel? model;

  const OptionItemDetailsForm({Key? key, this.model}) : super(key: key);

  static Widget create({
    required BuildContext context,
    Restaurant? restaurant,
    Option? option,
    OptionItem? item,
    OptionItemObservableStream? optionItemStream,
  }) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    return ChangeNotifierProvider<OptionItemDetailsModel>(
      create: (context) => OptionItemDetailsModel(
        database: database,
        session: session,
        restaurant: restaurant,
        option: option,
        optionItemStream: optionItemStream,
        id: item!.id ?? '',
        name: item.name ?? '',
      ),
      child: Consumer<OptionItemDetailsModel>(
        builder: (context, model, _) => OptionItemDetailsForm(
          model: model,
        ),
      ),
    );
  }

  @override
  _OptionItemDetailsFormState createState() => _OptionItemDetailsFormState();
}

class _OptionItemDetailsFormState extends State<OptionItemDetailsForm> {
  final TextEditingController _optionItemNameController = TextEditingController();
  final FocusNode _optionItemNameFocusNode = FocusNode();

  OptionItemDetailsModel? get model => widget.model;

  @override
  void initState() {
    super.initState();
    if (model != null) {
      _optionItemNameController.text = model!.name ?? '';
    }
  }

  @override
  void dispose() {
    _optionItemNameController.dispose();
    _optionItemNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await model!.save();
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Option Item Section',
        exception: e,
      ).show(context);
    }
  }

  void _optionItemNameEditingComplete() {
    final newFocus = _optionItemNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  List<Widget> _buildChildren() {
    return [
      _buildOptionItemNameTextField(),
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

  TextField _buildOptionItemNameTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _optionItemNameController,
      focusNode: _optionItemNameFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Option item name',
        hintText: 'i.e.: Spaghetti, Penne or Medium, Rare, etc.',
        errorText: model!.optionItemNameErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: model!.updateOptionItemName,
      onEditingComplete: () => _optionItemNameEditingComplete(),
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
