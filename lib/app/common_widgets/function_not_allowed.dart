import 'package:flutter/material.dart';

class FunctionNotAllowed extends StatelessWidget {
  const FunctionNotAllowed({
    Key? key,
    this.title = 'Access not allowed',
    this.message = 'Please request access to manage orders from the restaurant page',
  }) : super(key: key);

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.do_not_disturb_on),
              iconSize: 128,
              color: Colors.black,
              onPressed: null,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 32.0, color: Colors.black54),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                message,
                style: TextStyle(fontSize: 16.0, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
