import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/common_widgets/form_submit_button.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/models/menu.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/menu_builder/menu/menu_details_model.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/services/menu_observable_stream.dart';
import 'package:provider/provider.dart';

class MenuDetailsForm extends StatefulWidget {
  final MenuDetailsModel? model;

  const MenuDetailsForm({Key? key, this.model}) : super(key: key);

  static Widget create({
    required BuildContext context,
    Menu? menu,
    Restaurant? restaurant,
    MenuObservableStream? menuStream,
    int? sequence,
  }) {
    final database = Provider.of<Database>(context);
    final session = Provider.of<Session>(context);
    return ChangeNotifierProvider<MenuDetailsModel>(
      create: (context) => MenuDetailsModel(
          database: database,
          session: session,
          menuStream: menuStream,
          id: menu!.id ?? '',
          name: menu.name ?? '',
          notes: menu.notes ?? '',
          sequence: menu.sequence ?? sequence,
          hidden: menu.hidden ?? false,
          restaurant: restaurant),
      child: Consumer<MenuDetailsModel>(
        builder: (context, model, _) => MenuDetailsForm(
          model: model,
        ),
      ),
    );
  }

  @override
  _MenuDetailsFormState createState() => _MenuDetailsFormState();
}

class _MenuDetailsFormState extends State<MenuDetailsForm> {
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _menuNotesController = TextEditingController();
  final FocusNode _menuNameFocusNode = FocusNode();
  final FocusNode _menuNotesFocusNode = FocusNode();

  MenuDetailsModel? get model => widget.model;

  @override
  void initState() {
    super.initState();
    if (model != null) {
      _menuNameController.text = model!.name ?? '';
      _menuNotesController.text = model!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    _menuNotesController.dispose();
    _menuNameFocusNode.dispose();
    _menuNotesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await model!.save();
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Menu',
        exception: e,
      ).show(context);
    }
  }

  void _menuNameEditingComplete() {
    final newFocus = model!.menuNameValidator.isValid(model!.name)
        ? _menuNotesFocusNode
        : _menuNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _menuNotesEditingComplete() {
    final newFocus = _menuNotesFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  List<Widget> _buildChildren() {
    return [
      _buildMenuNameTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildMenuNotesTextField(),
      SizedBox(
        height: 8.0,
      ),
      _buildHiddenCheckBox(),
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

  TextField _buildMenuNameTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _menuNameController,
      focusNode: _menuNameFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Menu name',
        hintText: 'i.e.: Main menu or Summer menu',
        errorText: model!.menuNameErrorText,
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: model!.updateMenuName,
      onEditingComplete: () => _menuNameEditingComplete(),
    );
  }

  TextField _buildMenuNotesTextField() {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _menuNotesController,
      focusNode: _menuNotesFocusNode,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Notes (optional)',
        hintText: 'i.e.: From 8 am to 12 pm only',
        enabled: model!.isLoading == false,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model!.updateMenuNotes,
      onEditingComplete: () => _menuNotesEditingComplete(),
    );
  }

  Widget _buildHiddenCheckBox() {
    return CheckboxListTile(
      title: const Text('Hide this menu'),
      value: model!.hidden,
      onChanged: model!.updateHidden,
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
