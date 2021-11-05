import 'package:calendarro/calendarro.dart';
import 'package:calendarro/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/custom_weekday_label_row.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/authorizations.dart';
import 'package:nmwhitelabel/app/models/order.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/orders/order_totals_page.dart';
import 'package:nmwhitelabel/app/pages/restaurant/venue_authorization_page.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:provider/provider.dart';

class OrderTotals extends StatefulWidget {
  @override
  _OrderTotalsState createState() => _OrderTotalsState();
}

class _OrderTotalsState extends State<OrderTotals> {
  late Session session;
  late Database database;
  Stream<List<Order>>? _stream;
  Authorizations _authorizations =
  Authorizations(authorizedRoles: {}, authorizedNames: {}, authorizedDates: {});
  List<dynamic> _intDates = [];
  List<String> _stringDates = [];
  String _selectedStringDate = '';
  DateTime? _selectedDate;
  late dynamic _searchDate;
  static const String NOT_AUTH = '9999/12/31';

  void _determineSearchDate() {
    if (session.userDetails!.role == ROLE_VENUE) {
      _intDates = _authorizations.authorizedDates![database.userId]
                  ?? [DateTime.now().millisecondsSinceEpoch];
      _intDates.sort((a, b) => b.compareTo(a));
      _stringDates.clear();
      _intDates.forEach((intDate) {
        final date = DateTime.fromMillisecondsSinceEpoch(intDate);
        final strDate = '${date.year}' + '/' + '${date.month}' + '/' +
            '${date.day}';
        _stringDates.add(strDate);
      });
      if (_selectedStringDate == '') {
        _selectedStringDate = NOT_AUTH;
        if (_stringDates.length > 0) {
          _selectedStringDate = _stringDates[0];
        }
      }
      final yearMonthArr = _selectedStringDate.split('/');
      final year = int.parse(yearMonthArr[0]);
      final month = int.parse(yearMonthArr[1]);
      final day = int.parse(yearMonthArr[2]);
      _searchDate = DateTime(year, month, day).millisecondsSinceEpoch;
    } else {
      DateTime? startDate = DateTime.now();
      if (_selectedDate != null) {
        startDate = _selectedDate;
      }
      _searchDate = DateTime(startDate!.year, startDate.month, startDate.day).millisecondsSinceEpoch;
      _selectedStringDate = '${startDate.year}' + '/' + '${startDate.month}' + '/' +
          '${startDate.day}';
    }
  }

  Widget _datesMenuButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: PopupMenuButton<String>(
          icon: Icon(Icons.calendar_today),
          onSelected: (String date) {
            setState(() {
            _selectedStringDate = date;
            });
          },
          itemBuilder: (BuildContext context) {
            return _stringDates.map((String date) {
                return PopupMenuItem<String>(
                  child: Text(date),
                  value: date,
                );
            }).toList();
          }),
    );
  }

  Future<void> _calendarButton(BuildContext context) async {
    var currentMonthStartDate = DateUtils.getFirstDayOfCurrentMonth();
    var currentMonthEndDate = DateUtils.getLastDayOfCurrentMonth();
    var lastMonthStartDate = DateUtils.getFirstDayOfMonth(
        DateTime(
            currentMonthStartDate.year,
            currentMonthStartDate.month - 1,
            currentMonthStartDate.day,
        ));
    var lastMonthEndDate = DateUtils.getLastDayOfMonth(
        DateTime(
          currentMonthStartDate.year,
          currentMonthStartDate.month - 1,
          currentMonthStartDate.day,
        ));
    final DateFormat monthName = DateFormat(DateFormat.MONTH);
    final currentMonth = monthName.format(currentMonthStartDate);
    final lastMonth = monthName.format(lastMonthStartDate);
    _selectedDate = await Navigator.of(context).push(
      MaterialPageRoute<DateTime>(builder: (_) => Scaffold(
          appBar: new AppBar(
            title: new Text('Select query date'),
          ),
          body: Column(
            children: [
              Container(height: 32.0),
              Text(lastMonth,
                style: Theme.of(context).textTheme.headline4,
              ),
              Container(height: 32.0),
              Calendarro(
                  startDate: lastMonthStartDate,
                  endDate: lastMonthEndDate,
                  displayMode: DisplayMode.MONTHS,
                  selectionMode: SelectionMode.SINGLE,
                  weekdayLabelsRow: CustomWeekdayLabelsRow(),
                  onTap: (date) {
                    Navigator.of(context).pop(date);
                  }
              ),
              Container(height: 16.0),
              Text(currentMonth,
                style: Theme.of(context).textTheme.headline4,
              ),
              Container(height: 32.0),
              Calendarro(
                  startDate: currentMonthStartDate,
                  endDate: currentMonthEndDate,
                  displayMode: DisplayMode.MONTHS,
                  selectionMode: SelectionMode.SINGLE,
                  weekdayLabelsRow: CustomWeekdayLabelsRow(),
                  onTap: (date) {
                    Navigator.of(context).pop(date);
                  }
              ),
            ],
          ),
        )
      ),
    );
    setState(() {

    });
  }

  Widget _buildContents(BuildContext context) {
    if (!FlavourConfig.isManager()) {
      return FutureBuilder<List<Authorizations>>(
        future: database.authorizationsSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              snapshot.hasData) {
            _authorizations = snapshot.data!.firstWhere((authorization) => authorization.id == session.currentRestaurant!.id);
            _determineSearchDate();
            if (_selectedStringDate == NOT_AUTH) {
              return VenueAuthorizationPage();
            } else {
              _stream = database.dayRestaurantOrders(
                  session.currentRestaurant!.id,
                  DateTime.fromMillisecondsSinceEpoch(_searchDate)
              );
              return OrderTotalsPage(
                stream: _stream, selectedStringDate: _selectedStringDate,);
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
      _stream = database.dayRestaurantOrders(
        session.currentRestaurant!.id,
        DateTime.fromMillisecondsSinceEpoch(_searchDate));
      return OrderTotalsPage(
        stream: _stream, selectedStringDate: _selectedStringDate,);
    }
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
              '${session.currentRestaurant!.name}',
          style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
        ),
        actions: [
          if (FlavourConfig.isManager() || session.userDetails!.role == ROLE_STAFF)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _calendarButton(context),
              ),
            ),
          if (session.userDetails!.role == ROLE_VENUE)
            _datesMenuButton()
        ],
      ),
      body: _buildContents(context),
    );
  }
}
