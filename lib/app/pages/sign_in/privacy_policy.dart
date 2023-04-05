import 'package:flutter/material.dart';
import 'privacy_policy_text.dart';

class PrivacyPolicy extends StatelessWidget {
  final bool? askAgreement;

  const PrivacyPolicy({Key? key, this.askAgreement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Privacy Policy'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  child: Text(
                    PRIVACY_POLICY_TEXT,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    child: Text(
                      'OK',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
