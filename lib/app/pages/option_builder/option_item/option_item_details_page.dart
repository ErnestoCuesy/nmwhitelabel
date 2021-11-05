import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/option.dart';
import 'package:nmwhitelabel/app/models/option_item.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/pages/option_builder/option_item/option_item_details_form.dart';
import 'package:nmwhitelabel/app/services/option_item_observable_stream.dart';

class OptionItemDetailsPage extends StatelessWidget {
  final Restaurant? restaurant;
  final Option? option;
  final OptionItem? optionItem;
  final OptionItemObservableStream? optionItemStream;

  const OptionItemDetailsPage({
    Key? key,
    this.restaurant,
    this.option,
    this.optionItem,
    this.optionItemStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter option item details'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: OptionItemDetailsForm.create(
              context: context,
              option: option,
              restaurant: restaurant,
              item: optionItem,
              optionItemStream: optionItemStream,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
