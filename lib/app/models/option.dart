class Option {
  final String? id;
  final String? restaurantId;
  final String? name;
  final int? numberAllowed;
  List<dynamic>? usedByMenuItems;

  Option({
    this.id,
    this.restaurantId,
    this.name,
    this.numberAllowed,
    this.usedByMenuItems,
  });

  static Option? fromMap(Map<String, dynamic>? data, String? documentID) {
    if (data == null) {
      return null;
    }
    List<String> usedByMenuItems;
    if (data['usedByMenuItems'] != null) {
      usedByMenuItems = List.from(data['usedByMenuItems']);
    } else {
      usedByMenuItems = [];
    }
    return Option(
      id: data['id'],
      restaurantId: data['restaurantId'],
      name: data['name'],
      numberAllowed: data['numberAllowed'],
      usedByMenuItems: usedByMenuItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'numberAllowed': numberAllowed,
      'usedByMenuItems': usedByMenuItems ?? [],
    };
  }

  @override
  String toString() {
    return 'id: $id, restaurantId: $restaurantId, name: $name, numberAllowed: $numberAllowed, usedByMenuItems: $usedByMenuItems';
  }
}
