import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/received_notification.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/landing/landing_page.dart';
import 'package:nearbymenus/app/common_widgets/location_services_error.dart';
import 'package:nearbymenus/app/common_widgets/splash_screen.dart';
import 'package:nearbymenus/app/pages/rating/rate_app.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/services/navigation_service.dart';
import 'package:nearbymenus/app/services/notification_streams.dart';
import 'package:nearbymenus/app/utilities/app_theme.dart';
import 'package:nearbymenus/app/utilities/logo_image_asset.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position _defaultLocation = Position(
      longitude: 0,
      latitude: 0,
      speed: 0,
      accuracy: 0,
      speedAccuracy: 0,
      heading: 0,
      altitude: 0,
      timestamp: DateTime.now());
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _continueFlag = false;
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
  final BehaviorSubject<ReceivedNotification>
      didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();

  final BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  NotificationAppLaunchDetails? notificationAppLaunchDetails;

  RateMyApp? rateMyApp;
  String googlePlayIdentifier = 'com.ernestosoft.nearbymenus';
  String appStoreIdentifier = '1516295374';

  @override
  void initState() {
    super.initState();
    //_determineLocationPermissions();
    if (!kIsWeb) {
      if (!Platform.isMacOS) {
        _initNotifications();
        _requestIOSPermissions();
        _initRating();
      }
    }
  }

  void _initRating() {
    if (FlavourConfig.isManager()) {
      googlePlayIdentifier = googlePlayIdentifier + '.manager';
      appStoreIdentifier = '1524613034';
    } else if (FlavourConfig.isStaff()) {
      googlePlayIdentifier = googlePlayIdentifier + '.staff';
      appStoreIdentifier = '1525121267';
    } else if (FlavourConfig.isAdmin()) {
      googlePlayIdentifier = googlePlayIdentifier + '.admin';
      appStoreIdentifier = '';
    }
    rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: googlePlayIdentifier,
      appStoreIdentifier: appStoreIdentifier,
    );
    rateMyApp!.init().then((_) => RateApp.displayDialog(
          context: context,
          rateMyApp: rateMyApp,
          forceDialog: false,
        ));
  }

  void _initNotifications() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('launchericon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: (String? payload) async {
    //   if (payload != null) {
    //     debugPrint('notification payload: ' + payload);
    //   }
    //   selectNotificationSubject.add(payload);
    // });

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
    );
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  void _askPermission() {
    Geolocator.requestPermission().then((status) {
      setState(() {});
    });
  }

  void _continueWithoutLocation() {
    setState(() {
      _continueFlag = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Below line disabled since the bottom android nav bar behaves funny
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return FutureBuilder<LocationPermission>(
      future: Geolocator.checkPermission(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !Platform.isMacOS) {
          return SplashScreen();
        } else {
          if (snapshot.data == LocationPermission.denied && !_continueFlag) {
            return LocationServicesError(
              askPermission: () => _askPermission(),
              continueWithoutLocation: () => _continueWithoutLocation(),
              message:
                  'Access to location not granted or location services are off. Please rectify and re-run LVE Navigator.',
            );
          }
          return FutureBuilder<Position>(
              future: Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.best),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return MultiProvider(
                      providers: [
                        Provider.value(value: flutterLocalNotificationsPlugin),
                        Provider<NotificationStreams>(
                          create: (context) => NotificationStreams(
                              didReceiveLocalNotificationSubject:
                                  didReceiveLocalNotificationSubject,
                              selectNotificationSubject:
                                  selectNotificationSubject),
                        ),
                        Provider<LogoImageAsset>(
                            create: (context) => LogoImageAsset()),
                        Provider<AuthBase>(create: (context) => Auth()),
                        Provider<Database>(
                            create: (context) => FirestoreDatabase()),
                        Provider<Session>(
                            create: (context) => Session(
                                position: snapshot.data ?? _defaultLocation)),
                        Provider<NavigationService>(
                          create: (context) =>
                              NavigationService(navigatorKey: _navigatorKey),
                        )
                      ],
                      child: MaterialApp(
                        navigatorKey: _navigatorKey,
                        title: 'Nearby Menus',
                        theme: AppTheme.createTheme(context),
                        home: LandingPage(),
                        builder: (context, widget) => ResponsiveWrapper.builder(
                          widget,
                          maxWidth: 1200,
                          minWidth: 450,
                          defaultScale: true,
                          breakpoints: [
                            ResponsiveBreakpoint.resize(450, name: MOBILE),
                            ResponsiveBreakpoint.autoScale(800, name: TABLET),
                            ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                          ],
                        ),
                      ));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return SplashScreen();
                } else {
                  return LocationServicesError(
                    askPermission: () => _askPermission(),
                    message:
                        'Please make sure location services are enabled before proceeding.',
                  );
                }
              });
        }
      },
    );
  }
}
