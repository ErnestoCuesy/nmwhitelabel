class UserDetails {
  String? email;
  String? name;
  String? role;
  String? address1;
  String? address2;
  String? address3;
  String? address4;
  String? telephone;
  String? agreementDate;
  bool? hasRestaurants;
  int deletionTimeStamp;
  bool markedForDeletion;
  Map<dynamic, dynamic>? orderOnHold;

  UserDetails({
    this.email = '',
    this.name = '',
    this.role = '',
    this.address1 = '',
    this.address2 = '',
    this.address3 = '',
    this.address4 = '',
    this.telephone = '',
    this.agreementDate,
    this.hasRestaurants = false,
    this.deletionTimeStamp = 0,
    this.markedForDeletion = false,
    this.orderOnHold,
  });

  factory UserDetails.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return UserDetails();
    }
    return UserDetails(
      email: data['email'],
      name: data['name'],
      role: data['role'] ?? '',
      address1: data['address1'],
      address2: data['address2'],
      address3: data['address3'],
      address4: data['address4'],
      telephone: data['telephone'] ?? '',
      agreementDate: data['agreementDate'].toString(),
      hasRestaurants: data['hasRestaurants'] ?? false,
      deletionTimeStamp: data['deletionTimeStamp'] ?? 0,
      markedForDeletion: data['markedForDeletion'] ?? false,
      orderOnHold: data['orderOnHold'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'address4': address4,
      'telephone': telephone,
      'agreementDate': agreementDate,
      'hasRestaurants': hasRestaurants,
      'deletionTimeStamp': deletionTimeStamp,
      'markedForDeletion': markedForDeletion,
      'orderOnHold': orderOnHold,
    };
  }
}
