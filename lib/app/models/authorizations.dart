class Authorizations {
  final String? id;
  final Map<dynamic, dynamic>? authorizedRoles;
  final Map<dynamic, dynamic>? authorizedNames;
  final Map<dynamic, dynamic>? authorizedDates;

  Authorizations({this.id, this.authorizedRoles, this.authorizedNames, this.authorizedDates});

  static Authorizations fromMap(Map<dynamic, dynamic>? value, String documentId) {
    // if (value == null) {
    //   return null;
    // }
    return Authorizations(
      id: documentId,
      authorizedRoles: value!['authorizedRoles'],
      authorizedNames: value['authorizedNames'],
      authorizedDates: value['authorizedDates']
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'authorizedRoles': authorizedRoles,
      'authorizedNames': authorizedNames,
      'authorizedDates': authorizedDates,
    };
  }
}