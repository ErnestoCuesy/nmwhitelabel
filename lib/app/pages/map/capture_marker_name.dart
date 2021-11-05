import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/models/map_marker.dart';

class CaptureMarkerName extends StatefulWidget {
  final String? name;

  const CaptureMarkerName({Key? key, this.name}) : super(key: key);

  @override
  _CaptureMarkerNameState createState() => _CaptureMarkerNameState();
}

class _CaptureMarkerNameState extends State<CaptureMarkerName> {
  final TextEditingController _nameController =  TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final f = NumberFormat.simpleCurrency(locale: "en_ZA");
  bool? isActive;
  String? name;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    _nameController.text = name!.substring(0,2) == '>>' ? '' : name!;
    isActive = name!.length > 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Widget _buildActivateMarkerCheckBox() {
    return CheckboxListTile(
      title: const Text('Activate this marker'),
      value: isActive,
      onChanged: (value) {
        setState(() {
          isActive = value;
        });
      },
      secondary: const Icon(Icons.lightbulb_outline),
    );
  }

  TextField _buildNameTextField(BuildContext context) {
    return TextField(
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      controller: _nameController,
      focusNode: _nameFocusNode,
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Location name',
        hintText: 'i.e.: Entrance, landmark name, etc',
        errorText: '',
        enabled: true,
      ),
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        name = value;
      },
      onEditingComplete: () => FocusScope.of(context).requestFocus(_nameFocusNode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Location Name',
        ),
      ),
      body: Center(
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
                          _buildActivateMarkerCheckBox(),
                          SizedBox(height: 16.0,),
                          _buildNameTextField(context),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.save),
                    onPressed: () => Navigator.of(context).pop(MapMarker(isActive: isActive, name: name)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
