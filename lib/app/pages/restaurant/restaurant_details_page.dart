import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/pages/restaurant/restaurant_details_form.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Restaurant? restaurant;

  const RestaurantDetailsPage({Key? key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter restaurant details'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: RestaurantDetailsForm.create(
                context, restaurant),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
