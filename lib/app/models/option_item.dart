class OptionItem {
  final String? id;
  final String? restaurantId;
  final String? optionId;
  final String? name;

  OptionItem({
    this.id,
    this.restaurantId,
    this.optionId,
    this.name,
  });

  static OptionItem? fromMap(Map<String, dynamic>? data, String? documentID) {
    if (data == null) {
      return null;
    }
    return OptionItem(
      id: data['id'],
      restaurantId: data['restaurantId'],
      optionId: data['optionId'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'optionId': optionId,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'id: $id, restaurantId: $restaurantId, menuId: $optionId, name: $name';
  }

}
