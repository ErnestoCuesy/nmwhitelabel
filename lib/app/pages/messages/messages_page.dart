import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmwhitelabel/app/common_widgets/list_items_builder.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/models/user_message.dart';
import 'package:nmwhitelabel/app/pages/messages/access_options.dart';
import 'package:nmwhitelabel/app/pages/sign_in/conversion_process.dart';
import 'package:nmwhitelabel/app/services/auth.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/navigation_service.dart';
import 'package:nmwhitelabel/app/utilities/format.dart';
import 'package:provider/provider.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Auth? auth;
  Session? session;
  Database? database;
  NavigationService? navigationService;
  String role = ROLE_PATRON;

  Future<void> _deleteMessage(BuildContext context, UserMessage message) async {
    try {
      await database!.deleteMessage(message.id);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<bool> _confirmDismiss(BuildContext context, UserMessage message) async {
    if (message.authFlag!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disable access first to delete'))
      );
    }
    return !message.authFlag!;
  }

  Widget _buildContents(BuildContext context) {
    if (FlavourConfig.isManager()) {
      role = ROLE_MANAGER;
    } else if (FlavourConfig.isStaff()) {
      role = ROLE_STAFF;
    }
    return StreamBuilder<List<UserMessage>>(
      stream: database!.managerMessages(
        database!.userId,
        role,
      ),
      builder: (context, snapshot) {
        return ListItemsBuilder<UserMessage>(
            title: 'Messages',
            message: 'You don\'t have any messages',
            snapshot: snapshot,
            itemBuilder: (context, message) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key('msg-${message.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDismiss(context, message),
                onDismissed: (direction) => _deleteMessage(context, message),
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  child: ListTile(
                    isThreeLine: true,
                    leading: message.fromRole == ROLE_STAFF ? Icon(Icons.accessibility) : Icon(Icons.message),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: Text(
                              message.type!,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Text(
                              message.fromRole == ROLE_ADMIN ? 'Sent by Admin' : 'Requested by: ${message.fromName}',
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Text(
                              message.fromRole == ROLE_ADMIN ? '-' : 'Tap for options',
                            ),
                          ),
                          Text(
                            'Swipe message left to delete it',
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            Format.formatDateTime(message.timestamp!.toInt()),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _convertUser(context, message, _accessOptions);
                    },
                  ),
                ),
              );
            });
      },
    );
  }

  void _accessOptions(BuildContext context, UserMessage message) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) =>
            AccessOptions(message: message,),
      ),
    );
  }

  void _convertUser(BuildContext context, UserMessage message, Function(BuildContext, UserMessage) nextAction) async {
    if (message.fromRole == ROLE_ADMIN) {
      return;
    }
    if (!session!.userProcessComplete) {
      final ConversionProcess conversionProcess = ConversionProcess(
        navigationService: navigationService,
        session: session,
        auth: auth,
        database: database,
        captureUserDetails: true,
      );
      if (!await conversionProcess.userCanProceed()) {
        return;
      }
    }
    nextAction(context, message);
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context) as Auth?;
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    navigationService = Provider.of<NavigationService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
      ),
      body: _buildContents(context),
    );
  }
}
