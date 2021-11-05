import 'package:flutter/material.dart';
import 'email_sign_in_form.dart';

class EmailSignInPage extends StatelessWidget {
  final bool? convertAnonymous;

  const EmailSignInPage({Key? key, this.convertAnonymous}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In or Register', style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: EmailSignInForm.create(context, convertAnonymous),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
