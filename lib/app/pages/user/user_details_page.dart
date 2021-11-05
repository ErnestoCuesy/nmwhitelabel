import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:provider/provider.dart';
import 'user_details_form.dart';

class UserDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Provider.of<Session>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome', style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: UserDetailsForm.create(context: context, userDetails: session.userDetails),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
