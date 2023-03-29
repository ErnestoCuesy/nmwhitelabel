import 'package:geolocator/geolocator.dart';
import 'package:nearbymenus/app/models/order.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'package:nearbymenus/app/services/iap_manager.dart';
import 'package:rxdart/rxdart.dart';

const String ROLE_NONE = 'None';
const String ROLE_MANAGER = 'Manager';
const String ROLE_STAFF = 'Staff';
const String ROLE_PATRON = 'Patron';
const String ROLE_VENUE = 'Venue';
const String ROLE_ADMIN = 'Admin';
const String ROLE_CHECK_SUBSCRIPTION = 'Subscription';

class Session {
  final Position? position;
  UserDetails? userDetails = UserDetails();
  Restaurant? currentRestaurant;
  Subscription? subscription = Subscription();
  Order? currentOrder;
  late bool isAnonymousUser;
  bool userProcessComplete = false;

  BehaviorSubject<bool> _subjectAnonymousUserFlag =
      BehaviorSubject<bool>.seeded(false);
  Stream<bool> get anonymousUserFlagObservable =>
      _subjectAnonymousUserFlag.stream;

  BehaviorSubject<int> _subjectOrderCounter = BehaviorSubject<int>.seeded(0);
  Stream<int> get orderCounterObservable => _subjectOrderCounter.stream;

  BehaviorSubject<int> _subjectMessageCounter = BehaviorSubject<int>.seeded(0);
  Stream<int> get messageCounterObservable => _subjectMessageCounter.stream;

  Session({this.position});

  void setUserDetails(UserDetails userDetails) {
    this.userDetails = userDetails;
  }

  void setSubscription(Subscription? subscription) {
    this.subscription = subscription != null ? subscription : this.subscription;
  }

  bool userDetailsCaptured() {
    return userDetails!.name != '' &&
        userDetails!.address1 != '' &&
        userDetails!.address2 != '' &&
        userDetails!.telephone != '';
  }

  void updateDeliveryDetails() {
    currentOrder!.name = userDetails!.name;
    currentOrder!.deliveryAddress =
        '${userDetails!.address1} ${userDetails!.address2} ${userDetails!.address3} ${userDetails!.address4}';
    currentOrder!.telephone = userDetails!.telephone;
  }

  void broadcastAnonymousUserStatus(bool value) {
    _subjectAnonymousUserFlag.add(value);
  }

  void broadcastOrderCounter(int value) {
    _subjectOrderCounter.add(value);
  }

  void broadcastMessageCounter(int value) {
    _subjectMessageCounter.add(value);
  }

  void dispose() {
    _subjectAnonymousUserFlag.close();
    _subjectOrderCounter.close();
    _subjectMessageCounter.close();
  }

  Order emptyOrder(String orderNumber, double timestamp, String? userId) {
    return Order(
      id: orderNumber,
      restaurantId: currentRestaurant!.id,
      restaurantName: currentRestaurant!.name,
      managerId: currentRestaurant!.managerId,
      userId: userId,
      timestamp: timestamp,
      status: ORDER_ON_HOLD,
      name: userDetails!.name,
      deliveryAddress:
          '${userDetails!.address1} ${userDetails!.address2} ${userDetails!.address3} ${userDetails!.address4}',
      telephone: userDetails!.telephone,
      deliveryPosition: position,
      paymentMethod: '',
      paymentMethods: Map<String, double>(),
      deliveryOption: '',
      orderItems: [],
      notes: '',
      tip: 0.0,
      discount: 0.0,
      cashReceived: 0.0,
    );
  }
}
