class Menu {
  final String? id;
  final String? restaurantId;
  final String? name;
  final String? notes;
  int? sequence;
  final bool? hidden;

  Menu({
    this.id,
    this.restaurantId,
    this.name,
    this.notes,
    this.sequence,
    this.hidden,
  });

  static Menu? fromMap(Map<String, dynamic>? data, String? documentID) {
    if (data == null) {
      return null;
    }
    return Menu(
      id: data['id'],
      restaurantId: data['restaurantId'],
      name: data['name'],
      notes: data['notes'],
      sequence: data['sequence'],
      hidden: data['hidden'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'notes': notes,
      'sequence': sequence,
      'hidden': hidden ?? false,
    };
  }

  @override
  String toString() {
    return 'id: $id, restaurantId: $restaurantId, name: $name, notes: $notes, sequence: $sequence, hidden: $hidden';
  }
}
