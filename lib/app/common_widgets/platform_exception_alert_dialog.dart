import 'package:flutter/services.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog({
    required String title,
    required PlatformException exception,
  }) : super(
          title: title,
          content: _message(exception)!,
          defaultActionText: 'OK',
        );

  static String? _message(PlatformException exception) {
    if (exception.message == 'FirestoreErrorDomain') {
      if (exception.code == 'Error 7') {
        return 'Missing or insufficient permissions';
      }
    }
    return _errors[exception.code] ?? exception.message;
  }

  static Map<String, String> _errors = {
    ///   • `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
    ///   • `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
    'ERROR_USER_NOT_FOUND' : 'User does not exist'
    ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
    ///   • `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
    ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.

  };
}
