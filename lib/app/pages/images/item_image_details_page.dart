import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/item_image.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/images/item_image_details_form.dart';
import 'package:provider/provider.dart';

class ItemImageDetailsPage extends StatelessWidget {
  final ItemImage? itemImage;
  final Widget? image;

  const ItemImageDetailsPage({
    Key? key,
    this.itemImage,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Session session = Provider.of<Session>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter image description'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: ItemImageDetailsForm.create(
              context: context,
              restaurant: session.currentRestaurant,
              itemImage: itemImage,
              image: image,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
