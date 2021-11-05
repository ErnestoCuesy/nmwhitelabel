class ItemImage {
  final int? id;
  final String? restaurantId;
  String? description;
  String? url;

  ItemImage({this.id, this.restaurantId, this.description, this.url});

  static ItemImage fromMap(Map<String, dynamic>? data, String documentID) {
    // if (data == null) {
    //   return null;
    // }
    return ItemImage(
      id: data!['id'],
      restaurantId: data['restaurantId'],
      description: data['description'],
      url: data['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'description': description,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'id: $id, restaurantId: $restaurantId, description: $description, url: $url';
  }
}