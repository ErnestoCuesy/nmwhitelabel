import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'package:nearbymenus/app/utilities/validators.dart';
import 'package:nearbymenus/app/services/database.dart';

class UserDetailsModel with UserDetailsValidators, ChangeNotifier {
  final Session session;
  final Database database;
  final String role;
  String? email;
  String? userName;
  String? userAddress1;
  String? userAddress2;
  String? userAddress3;
  String? userAddress4;
  String? userTelephone;
  String? agreementDate;
  bool isLoading;
  bool submitted;

  UserDetailsModel({
    required this.session,
    required this.database,
    required this.role,
    this.email,
    this.userName,
    this.userAddress1,
    this.userAddress2,
    this.userAddress3,
    this.userAddress4,
    this.userTelephone,
    this.agreementDate,
    this.isLoading = false,
    this.submitted = false,
  });

  Future<void> save() async {
    updateWith(isLoading: true, submitted: true);
    final userDetails = UserDetails(
      email: email,
      name: userName,
      role: role,
      address1: userAddress1,
      address2: userAddress2,
      address3: userAddress3,
      address4: userAddress4,
      telephone: userTelephone,
      agreementDate: agreementDate,
    );
    try {
      await database.setUserDetails(userDetails);
      session.setUserDetails(userDetails);
      if (session.currentOrder != null) {
        session.updateDeliveryDetails();
      }
    } catch (e) {
      print(e);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText => 'Save';

  bool get canSave {
    bool canSubmitFlag = false;
    if (userNameValidator.isValid(userName) &&
        userAddressValidator.isValid(userAddress1) &&
        userAddressValidator.isValid(userAddress2) &&
        userTelephoneValidator.isValid(userTelephone) &&
        !isLoading) {
      canSubmitFlag = true;
    }
    return canSubmitFlag;
  }

  String? get userNameErrorText {
    bool showErrorText = !userNameValidator.isValid(userName);
    return showErrorText ? invalidUsernameErrorText : null;
  }

  String? get userAddress1ErrorText {
    bool showErrorText = !userAddressValidator.isValid(userAddress1);
    return showErrorText ? invalidAddressErrorText : null;
  }

  String? get userAddress2ErrorText {
    bool showErrorText = !userAddressValidator.isValid(userAddress2);
    return showErrorText ? invalidAddressErrorText : null;
  }

  String? get userTelephoneErrorText {
    bool showErrorText = !userTelephoneValidator.isValid(userTelephone);
    return showErrorText ? invalidTelephoneErrorText : null;
  }

  void updateUserName(String userName) => updateWith(userName: userName);

  void updateUserAddress1(String userAddress1) =>
      updateWith(userAddress1: userAddress1);

  void updateUserAddress2(String userAddress2) =>
      updateWith(userAddress2: userAddress2);

  void updateUserAddress3(String userAddress3) =>
      updateWith(userAddress3: userAddress3);

  void updateUserAddress4(String userAddress4) =>
      updateWith(userAddress4: userAddress4);

  void updateUserTelephone(String userTelephone) =>
      updateWith(userTelephone: userTelephone);

  void updateWith({
    String? userName,
    String? userLocation,
    String? userAddress1,
    String? userAddress2,
    String? userAddress3,
    String? userAddress4,
    String? userTelephone,
    bool? isLoading,
    bool? submitted,
  }) {
    this.userName = userName ?? this.userName;
    this.userAddress1 = userAddress1 ?? this.userAddress1;
    this.userAddress2 = userAddress2 ?? this.userAddress2;
    this.userAddress3 = userAddress3 ?? this.userAddress3;
    this.userAddress4 = userAddress4 ?? this.userAddress4;
    this.userTelephone = userTelephone ?? this.userTelephone;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
