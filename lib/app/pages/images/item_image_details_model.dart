import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbymenus/app/models/item_image.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/utilities/validators.dart';
import 'package:nearbymenus/app/services/database.dart';

class ItemImageDetailsModel with ItemImageValidators, ChangeNotifier {
  final Database database;
  final Restaurant? restaurant;
  int? id;
  String? description;
  String? url;
  Widget? image;
  File? imageFile;
  bool imageChanged = false;
  bool isLoading;
  bool submitted;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: 'gs://nearby-menus-be6e3.appspot.com');

  Map<dynamic, dynamic>? itemImages;
  ImagePicker _imagePicker = ImagePicker();

  late String fileName;
  late Reference storageReference;
  UploadTask? uploadTask;

  ItemImageDetailsModel({
    required this.database,
    required this.restaurant,
    this.id,
    this.description,
    this.url,
    this.image,
    this.isLoading = false,
    this.submitted = false,
  });

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    if (imageChanged) {
      await uploadPic();
    }
    final itemImage = ItemImage(
      id: id,
      restaurantId: restaurant!.id,
      description: description,
      url: url,
    );
    try {
      database.setItemImage(itemImage);
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future getImage() async {
    PickedFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery) as PickedFile?;
    if (pickedImage != null) {
      var tempPath = pickedImage.path.split('image_picker');
      var dirPath = tempPath[0];
      var tempName = tempPath[1].split('.');
      var newPath = dirPath + tempName[0] + 'comp.' + tempName[1];
      var result = await (FlutterImageCompress.compressAndGetFile(
          pickedImage.path, newPath,
          quality: 50) as FutureOr<File>);
      imageFile = File(result.path);
      image = Image.file(result);
      updateWith(image: image, imageChanged: true);
    }
  }

  Future uploadPic() async {
    fileName = 'images/${restaurant!.id}/Image_$id';
    storageReference = _storage.ref().child(fileName);
    uploadTask = storageReference.putFile(imageFile!);
    updateWith(isLoading: true);
    try {
      await uploadTask!.then((TaskSnapshot snapshot) async {
        url = await snapshot.ref.getDownloadURL();
        print('Update complete!');
      }).catchError((Object e) {
        print(e);
      });
      print('Image file uploaded, url is $url');
    } catch (e) {
      print(e);
    }
    updateWith(isLoading: false);
    uploadTask = null;
  }

  String get primaryButtonText => 'Save';

  bool get canSave =>
      itemImageDescriptionValidator.isValid(description) && !isLoading;

  String? get itemImageDescriptionErrorText {
    bool showErrorText = !itemImageDescriptionValidator.isValid(description);
    return showErrorText ? invalidItemImageDescriptionText : null;
  }

  void updateItemImageDescription(String description) =>
      updateWith(description: description);

  void updateWith({
    String? description,
    Widget? image,
    bool? imageChanged,
    bool? isLoading,
    bool? submitted,
  }) {
    this.description = description ?? this.description;
    this.image = image ?? this.image;
    this.imageChanged = imageChanged ?? this.imageChanged;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
