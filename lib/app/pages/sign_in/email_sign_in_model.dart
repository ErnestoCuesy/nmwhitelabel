import 'package:flutter/services.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/utilities/validators.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:flutter/foundation.dart';

enum EmailSignInFormType { signIn, register, resetPassword, convert }

class EmailSignInModel with UserCredentialsValidators, ChangeNotifier {
  EmailSignInModel({
    required this.auth,
    required this.session,
    this.email,
    this.password,
    this.name,
    this.formType,
    this.convertAnonymous,
    this.acceptTermsAndConditions,
    this.isLoading = false,
    this.submitted = false,
  });

  final AuthBase auth;
  final Session session;
  String? email;
  String? password;
  String? name;
  EmailSignInFormType? formType;
  bool? convertAnonymous;
  bool? acceptTermsAndConditions;
  bool isLoading;
  bool submitted;

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    session.userDetails =
        UserDetails(email: email, agreementDate: documentIdFromCurrentDate());
    session.currentOrder = null;
    try {
      // await Future.delayed(Duration(seconds: 3)); // Simulate slow network
      switch (formType) {
        case EmailSignInFormType.signIn:
          {
            await auth.signInWithEmailAndPassword(email, password);
          }
          break;
        case EmailSignInFormType.register:
          {
            await auth.createUserWithEmailAndPassword(email, password);
          }
          break;
        case EmailSignInFormType.resetPassword:
          {
            await auth.resetPassword(email);
          }
          break;
        case EmailSignInFormType.convert:
          {
            await auth.convertUserWithEmail(email, password, name);
            await auth.sendEmailVerification();
            session.isAnonymousUser = false;
            session.broadcastAnonymousUserStatus(false);
          }
          break;
        default:
      }
    } on PlatformException catch (e) {
      if (e.code == 'PASSWORD_RESET' ||
          e.code == 'EMAIL_NOT_VERIFIED' ||
          e.code == 'INVALID_CREDENTIALS') {
        updateWith(formType: EmailSignInFormType.signIn);
      }
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String? get primaryButtonText {
    String? buttonText;
    switch (formType) {
      case EmailSignInFormType.signIn:
        {
          buttonText = 'Sign In';
        }
        break;
      case EmailSignInFormType.convert:
      case EmailSignInFormType.register:
        {
          buttonText = 'Create an account';
        }
        break;
      case EmailSignInFormType.resetPassword:
        {
          buttonText = 'Reset password';
        }
        break;
      default:
    }
    return buttonText;
  }

  String get secondaryButtonText {
    String buttonText = '';
    switch (formType) {
      case EmailSignInFormType.signIn:
        {
          buttonText = 'Don\'t have an account? Register';
        }
        break;
      case EmailSignInFormType.convert:
      case EmailSignInFormType.register:
        {
          buttonText = 'Have an account? Sign In';
        }
        break;
      case EmailSignInFormType.resetPassword:
        {
          buttonText = 'Sign In';
        }
        break;
      default:
    }
    return buttonText;
  }

  String get tertiaryButtonText =>
      formType == EmailSignInFormType.convert ? '' : 'Forgot your password?';

  bool get canSubmit {
    bool canSubmitFlag = false;
    switch (formType) {
      case EmailSignInFormType.convert:
      case EmailSignInFormType.register:
        {
          if (emailValidator.isValid(email) &&
              passwordValidator.isValid(password) &&
              acceptTermsAndConditions! &&
              !isLoading) {
            canSubmitFlag = true;
          }
        }
        break;
      case EmailSignInFormType.signIn:
        {
          if (emailValidator.isValid(email) &&
              passwordValidator.isValid(password) &&
              !isLoading) {
            canSubmitFlag = true;
          }
        }
        break;
      case EmailSignInFormType.resetPassword:
        {
          if (emailValidator.isValid(email) && !isLoading) {
            canSubmitFlag = true;
          }
        }
        break;
      default:
    }
    return canSubmitFlag;
  }

  String? get passwordErrorText {
    bool showErrorText = !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String? get emailErrorText {
    bool showErrorText = !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  void toggleFormType(EmailSignInFormType toggleForm) {
    updateWith(
      formType: toggleForm,
      isLoading: false,
      submitted: false,
    );
  }

  void updateEmail(String email) => updateWith(email: email);

  void updatePassword(String password) => updateWith(password: password);

  void updateTermsAndConditions(bool? acceptTermsAndConditions) =>
      updateWith(acceptTermsAndConditions: acceptTermsAndConditions);

  void updateWith({
    String? email,
    String? password,
    EmailSignInFormType? formType,
    bool? acceptTermsAndConditions,
    bool? isLoading,
    bool? submitted,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.acceptTermsAndConditions =
        acceptTermsAndConditions ?? this.acceptTermsAndConditions;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = this.submitted;
    notifyListeners();
  }
}
