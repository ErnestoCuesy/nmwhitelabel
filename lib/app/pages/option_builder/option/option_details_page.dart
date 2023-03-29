import 'package:flutter/material.dart';
import 'package:nearbymenus/app/models/option.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/pages/option_builder/option/option_details_form.dart';
import 'package:nearbymenus/app/services/option_observable_stream.dart';

class OptionDetailsPage extends StatelessWidget {
  final Restaurant? restaurant;
  final Option? option;
  final OptionObservableStream? optionStream;

  const OptionDetailsPage(
      {Key? key, this.option, this.restaurant, this.optionStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter option details'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: OptionDetailsForm.create(
              context: context,
              restaurant: restaurant,
              option: option,
              optionStream: optionStream,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
