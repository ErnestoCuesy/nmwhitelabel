import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/services/iap_test_data.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionType { Unsubscribed, Expired, Standard, Pro }

class Subscription {
  final CustomerInfo? purchaserInfo;
  final Offerings? offerings;

  Subscription({this.purchaserInfo, this.offerings});

  SubscriptionType get subscriptionType {
    if (purchaserInfo != null &&
        purchaserInfo!.entitlements.active.isNotEmpty) {
      if (purchaserInfo!.entitlements.active.containsKey("pro")) {
        return SubscriptionType.Pro;
      } else {
        if (purchaserInfo!.entitlements.active.containsKey("std")) {
          return SubscriptionType.Standard;
        }
      }
    }
    return SubscriptionType.Unsubscribed;
  }

  String get subscriptionTypeString {
    String subCode;
    switch (subscriptionType) {
      case SubscriptionType.Pro:
        {
          subCode = 'Pro';
        }
        break;
      case SubscriptionType.Standard:
        {
          subCode = 'Standard';
        }
        break;
      default:
        {
          subCode = 'Unsubscribed';
        }
    }
    return subCode;
  }

  int get numberOfActiveSubscriptions =>
      purchaserInfo!.activeSubscriptions.length;

  String get firstSeen => purchaserInfo!.firstSeen;

  String? get latestExpirationDate => purchaserInfo!.latestExpirationDate;

  List<Package>? get availableOfferings {
    if (offerings != null) {
      return offerings!.current!.availablePackages;
    }
    return null;
  }
}

abstract class IAPManagerBase {
  Stream<Subscription?> get onSubscriptionChanged;
  SubscriptionType get subscriptionType;
  void purchasePackage(Package package);
  Future<void> purchaseProduct(String productIdentifier);

  static String parseErrorCode(PurchasesErrorCode errorCode) {
    String errCode;
    switch (errorCode) {
      case PurchasesErrorCode.unknownError:
        {
          errCode = 'Unknown error';
        }
        break;
      case PurchasesErrorCode.purchaseCancelledError:
        {
          errCode = 'Purchase cancelled';
        }
        break;
      case PurchasesErrorCode.storeProblemError:
        {
          errCode = 'Store problem';
        }
        break;
      case PurchasesErrorCode.purchaseNotAllowedError:
        {
          errCode = 'Purchase not allowed';
        }
        break;
      case PurchasesErrorCode.purchaseInvalidError:
        {
          errCode = 'Purchase invalid';
        }
        break;
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        {
          errCode = 'Product not available for purchase';
        }
        break;
      case PurchasesErrorCode.productAlreadyPurchasedError:
        {
          errCode = 'Product already purchased';
        }
        break;
      case PurchasesErrorCode.receiptAlreadyInUseError:
        {
          errCode = 'Receipt already in use';
        }
        break;
      case PurchasesErrorCode.invalidReceiptError:
        {
          errCode = 'Invalid receipt';
        }
        break;
      case PurchasesErrorCode.missingReceiptFileError:
        {
          errCode = 'Missing receipt';
        }
        break;
      case PurchasesErrorCode.networkError:
        {
          errCode = 'Network error';
        }
        break;
      case PurchasesErrorCode.invalidCredentialsError:
        {
          errCode = 'Invalid credentials';
        }
        break;
      case PurchasesErrorCode.unexpectedBackendResponseError:
        {
          errCode = 'Unexpected backend response';
        }
        break;
      case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
        {
          errCode = 'Receipt in use by other subscriber';
        }
        break;
      case PurchasesErrorCode.invalidAppUserIdError:
        {
          errCode = 'Invalid app user ID';
        }
        break;
      case PurchasesErrorCode.operationAlreadyInProgressError:
        {
          errCode = 'Operation already in progress';
        }
        break;
      case PurchasesErrorCode.unknownBackendError:
        {
          errCode = 'Unknown backend error';
        }
        break;
      case PurchasesErrorCode.insufficientPermissionsError:
        {
          errCode = 'Insufficient permissions';
        }
        break;
      case PurchasesErrorCode.paymentPendingError:
        {
          errCode = 'Payment pending';
        }
        break;
      default:
        {
          errCode = 'Other unknown error';
        }
    }
    return errCode;
  }
}

class IAPManagerMock implements IAPManagerBase {
  final String userID;
  CustomerInfo? _purchaserInfo;
  Offerings? _offerings;
  Subscription? _subscription;
  StreamController<Subscription?> controller =
      StreamController<Subscription?>.broadcast();

  IAPManagerMock({required this.userID}) {
    init();
  }

  Future<void> init() async {
    _purchaserInfo = CustomerInfo.fromJson(purchaserInfoTestDataU);
    _offerings = Offerings.fromJson(offeringsTestData);
    await Future.delayed(Duration(seconds: 3)); // Simulate slow network
    streamSubscription(pi: _purchaserInfo, of: _offerings);
  }

  @override
  Stream<Subscription?> get onSubscriptionChanged => controller.stream;

  @override
  void purchasePackage(Package package) {
    print('Purchasing package: ${package.identifier}');
    _purchaserInfo = CustomerInfo.fromJson(purchaserInfoTestDataS);
    streamSubscription(pi: _purchaserInfo, of: _offerings);
  }

  @override
  Future<void> purchaseProduct(String productIdentifier) async {}

  @override
  SubscriptionType get subscriptionType => _subscription!.subscriptionType;

  void streamSubscription({CustomerInfo? pi, Offerings? of}) {
    _subscription = Subscription(purchaserInfo: pi, offerings: of);
    controller.add(_subscription);
  }
}

class IAPManager implements IAPManagerBase {
  final String? userID;
  CustomerInfo? _purchaserInfo;
  Offerings? _offerings;
  Subscription? _subscription;
  StreamController<Subscription?> controller =
      StreamController<Subscription?>();
  static const String API_KEY = 'AeegEYeSxBwqtfZXZtbeMWVTOnAhyxiA';

  @override
  Stream<Subscription?> get onSubscriptionChanged => controller.stream;

  IAPManager({required this.userID}) {
    init();
  }

  Future<void> init() async {
    try {
      Purchases.setLogLevel(LogLevel.debug);
      // String? rcUserID =
      //     (userID == null || userID == '') ? 'anonymous' : userID;
      await Purchases.configure(
          PurchasesConfiguration(API_KEY)); //(API_KEY, appUserId: rcUserID);
      //await Purchases.setAllowSharingStoreAccount(false);
      _purchaserInfo = await Purchases.getCustomerInfo();
      _offerings = await Purchases.getOfferings();
      streamSubscription(pi: _purchaserInfo, of: _offerings);
      Purchases.addCustomerInfoUpdateListener((pi) {
        streamSubscription(pi: pi, of: _offerings);
      });
    } catch (e) {
      print(e);
    }
  }

  void streamSubscription({CustomerInfo? pi, Offerings? of}) {
    _subscription = Subscription(purchaserInfo: pi, offerings: of);
    controller.add(_subscription);
  }

  @override
  SubscriptionType get subscriptionType => _subscription!.subscriptionType;

  @override
  void purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      // Don't have to add anything to the stream as the listener above
      // will pick-up the subscription change and add it to the stream
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      controller.addError(IAPManagerBase.parseErrorCode(errorCode));
    }
  }

  @override
  Future<void> purchaseProduct(String productIdentifier) async {
    try {
      await Purchases.purchaseProduct(productIdentifier,
          type: PurchaseType.inapp);
      // Don't have to add anything to the stream as the listener above
      // will pick-up the subscription change and add it to the stream
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      controller.addError(IAPManagerBase.parseErrorCode(errorCode));
      rethrow;
    }
  }
}
