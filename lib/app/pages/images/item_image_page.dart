import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/models/item_image.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/images/item_image_details_page.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:provider/provider.dart';

class ItemImagePage extends StatefulWidget {
  final bool? viewOnly;

  const ItemImagePage({Key? key, this.viewOnly}) : super(key: key);

  @override
  _ItemImagePageState createState() => _ItemImagePageState();
}

class _ItemImagePageState extends State<ItemImagePage> {
  late Session session;
  late Database database;

  void _loadItemImages() {
    if (!session.currentRestaurant!.itemImagesInitialized!) {
      for (int i = 0; i < 5; i++) {
        database.setItemImage(ItemImage(
            id: DateTime.now().millisecondsSinceEpoch + i,
            restaurantId: session.currentRestaurant!.id,
            description: 'Tap image to change',
            url: ''
        ));
      }
      session.currentRestaurant!.itemImagesInitialized = true;
      database.setRestaurant(session.currentRestaurant);
    }
  }

  void _createItemImageDetailsPage(BuildContext context, ItemImage itemImage, Widget image) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => ItemImageDetailsPage(
          itemImage: itemImage,
          image: image,
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<List<ItemImage>>(
      stream: database.itemImages(session.currentRestaurant!.id),
      builder: (context, snapshot) {
        return ListItemsBuilder<ItemImage>(
          axis: widget.viewOnly! ? Axis.horizontal : Axis.vertical,
          title: 'No images found',
          message: '',
          snapshot: snapshot,
          itemBuilder: (context, itemImage) {
            final image = itemImage.url != ''
                ? Image.network(itemImage.url!)
                : Icon(Icons.image, size: 36.0,);
            if (widget.viewOnly!) {
              return Container(
                width: width,
                height: height,
                child: Column(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: image,
                    )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        itemImage.url != '' ? itemImage.description! : '',
                        textAlign: TextAlign.center,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline5,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: IconButton(
                            icon: image,
                            onPressed: () =>
                                _createItemImageDetailsPage(
                                    context, itemImage, image),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          itemImage.description!,
                          overflow: TextOverflow.fade,
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    if (!widget.viewOnly!) _loadItemImages();
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.viewOnly! ? 'Our specialities' : 'Upload images'
          ),
        ),
        body: _buildContents(context),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.viewOnly! ? 'Our specialities' : 'Upload images'
          ),
        ),
        body: _buildContents(context),
      );
    }
  }

}
