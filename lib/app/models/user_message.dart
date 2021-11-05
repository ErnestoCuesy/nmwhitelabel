
class UserMessage {
  final String? id;
  final double? timestamp;
  final String? fromUid;
  final String? toUid;
  final String? restaurantId;
  final String? fromRole;
  final String? toRole;
  final String? fromName;
  final bool? delivered;
  final String? type;
  bool? authFlag;
  bool? attendedFlag;

  UserMessage({
    required this.id,
    required this.timestamp,
    required this.fromUid,
    required this.toUid,
    required this.restaurantId,
    required this.fromRole,
    required this.toRole,
    required this.fromName,
    required this.delivered,
    required this.type,
    required this.authFlag,
    required this.attendedFlag,
  });

  static UserMessage fromMap(
      Map<String, dynamic>? data, String documentID) {
    // if (data == null) {
    //   return null;
    // }
    return UserMessage(
        id: data!['id'],
        timestamp: data['timestamp'],
        fromUid: data['fromUid'],
        toUid: data['toUid'],
        restaurantId: data['restaurantId'],
        fromRole: data['fromRole'],
        toRole: data['toRole'],
        fromName: data['fromName'],
        delivered: data['delivered'],
        type: data['type'],
        authFlag: data['authFlag'],
        attendedFlag: data['attendedFlag'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'fromUid': fromUid,
      'toUid': toUid,
      'restaurantId': restaurantId,
      'fromRole': fromRole,
      'toRole': toRole,
      'fromName': fromName,
      'delivered': delivered,
      'type': type,
      'authFlag': authFlag,
      'attendedFlag': attendedFlag,
    };
  }

  @override
  String toString() {
    return 'id: $id, fromUid: $fromUid, toUid: $toUid, restaurantId: $restaurantId, fromRole: $fromRole, toRole: $toRole, fromName: $fromName, delivered: $delivered, type: $type, authFlag: $authFlag, attendedFlag: $attendedFlag';
  }
}
