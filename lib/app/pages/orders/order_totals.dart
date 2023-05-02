import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:nearbymenus/app/common_widgets/platform_progress_indicator.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/authorizations.dart';
import 'package:nearbymenus/app/models/order.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/orders/order_totals_page.dart';
import 'package:nearbymenus/app/pages/restaurant/venue_authorization_page.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class OrderTotals extends StatefulWidget {
  @override
  _OrderTotalsState createState() => _OrderTotalsState();
}

class _OrderTotalsState extends State<OrderTotals> {
  late Session session;
  late Database database;
  Stream<List<Order>>? _stream;
  Authorizations _authorizations = Authorizations(
      authorizedRoles: {}, authorizedNames: {}, authorizedDates: {});
  List<dynamic> _intDates = [];
  List<String> _stringDates = [];
  String _selectedStringDateRange = '';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  late dynamic _searchStartDate;
  late dynamic _searchEndDate;
  static const String NOT_AUTH = '9999/12/31';

  void _determineSearchDate() {
    if (session.userDetails!.role == ROLE_VENUE) {
      _intDates = _authorizations.authorizedDates![database.userId] ??
          [DateTime.now().millisecondsSinceEpoch];
      _intDates.sort((a, b) => b.compareTo(a));
      _stringDates.clear();
      _intDates.forEach((intDate) {
        final date = DateTime.fromMillisecondsSinceEpoch(intDate);
        final strDate =
            '${date.year}' + '/' + '${date.month}' + '/' + '${date.day}';
        _stringDates.add(strDate);
      });
      if (_selectedStringDateRange == '') {
        _selectedStringDateRange = NOT_AUTH;
        if (_stringDates.length > 0) {
          _selectedStringDateRange = _stringDates[0];
        }
      }
      final yearMonthArr = _selectedStringDateRange.split('/');
      final year = int.parse(yearMonthArr[0]);
      final month = int.parse(yearMonthArr[1]);
      final day = int.parse(yearMonthArr[2]);
      _searchStartDate = DateTime(year, month, day).millisecondsSinceEpoch;
    } else {
      DateTime? startDate = DateTime.now();
      DateTime? endDate = DateTime.now();
      if (_selectedStartDate != null) {
        startDate = _selectedStartDate;
      }
      if (_selectedEndDate != null) {
        endDate = _selectedEndDate;
      }
      _searchStartDate =
          DateTime(startDate!.year, startDate.month, startDate.day)
              .millisecondsSinceEpoch;
      _searchEndDate = DateTime(endDate!.year, endDate.month, endDate.day)
          .millisecondsSinceEpoch;
      _selectedStringDateRange = '${startDate.year}' +
          '/' +
          '${startDate.month}' +
          '/' +
          '${startDate.day} - ' +
          '${endDate.year}' +
          '/' +
          '${endDate.month}' +
          '/' +
          '${endDate.day}';
    }
  }

  Widget _buildContents(BuildContext context) {
    if (!FlavourConfig.isManager() && !FlavourConfig.isAdmin()) {
      return FutureBuilder<List<Authorizations>>(
        future: database.authorizationsSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              snapshot.hasData) {
            _authorizations = snapshot.data!.firstWhere((authorization) =>
                authorization.id == session.currentRestaurant!.id);
            _determineSearchDate();
            if (_selectedStringDateRange == NOT_AUTH) {
              return VenueAuthorizationPage();
            } else {
              _stream = database.dateRangeRestaurantOrders(
                  session.currentRestaurant!.id,
                  DateTime.fromMillisecondsSinceEpoch(_searchStartDate),
                  DateTime.fromMillisecondsSinceEpoch(_searchEndDate));
              return OrderTotalsPage(
                stream: _stream,
                selectedStringDate: _selectedStringDateRange,
              );
            }
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return VenueAuthorizationPage();
            } else {
              return Center(child: PlatformProgressIndicator());
            }
          }
        },
      );
    } else {
      _determineSearchDate();
      _stream = database.dateRangeRestaurantOrders(
          session.currentRestaurant!.id,
          DateTime.fromMillisecondsSinceEpoch(_searchStartDate),
          DateTime.fromMillisecondsSinceEpoch(_searchEndDate));
      return OrderTotalsPage(
        stream: _stream,
        selectedStringDate: _selectedStringDateRange,
      );
    }
  }

  _pickDate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime.now().subtract(Duration(days: 30)),
        maxTime: DateTime.now(), onChanged: (date) {
      print('end change $date');
    }, onConfirm: (date) {
      print('end confirm $date');
      setState(() {
        _selectedEndDate = date;
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime.now().subtract(Duration(days: 30)),
        maxTime: DateTime.now(), onChanged: (date) {
      print('start change $date');
    }, onConfirm: (date) {
      print('start confirm $date');
      setState(() {
        _selectedStartDate = date;
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${session.currentRestaurant!.name}',
          style:
              TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        actions: [
          if (FlavourConfig.isManager() ||
              FlavourConfig.isAdmin() ||
              session.userDetails!.role == ROLE_STAFF)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _pickDate(),
              ),
            ),
        ],
      ),
      body: _buildContents(context),
    );
  }
}
