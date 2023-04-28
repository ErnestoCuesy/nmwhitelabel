class MenuItem {
  final String? id;
  final String? restaurantId;
  final String? menuId;
  final String? name;
  final String? description;
  int? sequence;
  final bool? hidden;
  final bool? outOfStock;
  final double? price;
  final List<String?>? options;

  MenuItem({
    this.id,
    this.restaurantId,
    this.menuId,
    this.name,
    this.description,
    this.sequence,
    this.hidden,
    this.outOfStock,
    this.price,
    this.options,
  });

  static MenuItem? fromMap(Map<String, dynamic>? data, String? documentID) {
    if (data == null) {
      return null;
    }
    return MenuItem(
      id: data['id'],
      restaurantId: data['restaurantId'],
      menuId: data['menuId'],
      name: data['name'],
      description: data['description'],
      sequence: data['sequence'],
      hidden: data['hidden'] ?? false,
      outOfStock: data['outOfStock'] ?? false,
      price: data['price'].toDouble(),
      options: List.from(data['options']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'menuId': menuId,
      'name': name,
      'description': description,
      'sequence': sequence,
      'hidden': hidden ?? false,
      'outOfStock': outOfStock ?? false,
      'price': price,
      'options': options,
    };
  }

  @override
  String toString() {
    return 'id: $id, restaurantId: $restaurantId, menuId: $menuId, name: $name, description: $description, price: $price, options: $options, sequence: $sequence, hidden: $hidden, outOfStock: $outOfStock';
  }
}
