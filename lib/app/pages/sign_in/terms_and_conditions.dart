import 'package:flutter/material.dart';
import 'package:nearbymenus/app/pages/sign_in/terms_and_conditions_text.dart';

class TermsAndConditions extends StatelessWidget {
  final bool? askAgreement;

  const TermsAndConditions({Key? key, this.askAgreement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Terms And Conditions'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  child: Text(
                    TERMS_AND_CONDITIONS_TEXT,
                  ),
                ),
                if (askAgreement!)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      child: Text(
                        'I AGREE TO TERMS AND CONDITIONS',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                if (askAgreement!)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      child: Text(
                        'I DO NOT AGREE',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
