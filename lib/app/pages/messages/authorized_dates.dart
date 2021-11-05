import 'package:calendarro/calendarro.dart';
import 'package:calendarro/date_utils.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/common_widgets/custom_weekday_label_row.dart';
import 'package:nmwhitelabel/app/common_widgets/form_submit_button.dart';

class AuthorizedDates extends StatelessWidget {
  final List<dynamic>? authorizedIntDates;

  const AuthorizedDates({Key? key, this.authorizedIntDates,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    final currentMonthName = monthName.format(currentMonthStartDate);
    final lastMonthName = monthName.format(lastMonthStartDate);
    List<DateTime> selectedDates = [];
    authorizedIntDates!.forEach((intDate) {
      selectedDates.add(DateTime.fromMillisecondsSinceEpoch(intDate));
    });
    Calendarro currentMonth = Calendarro(
        startDate: currentMonthStartDate,
        endDate: currentMonthEndDate,
        displayMode: DisplayMode.MONTHS,
        selectionMode: SelectionMode.MULTI,
        selectedDates: selectedDates,
        weekdayLabelsRow: CustomWeekdayLabelsRow(),
    );
    Calendarro lastMonth = Calendarro(
      startDate: lastMonthStartDate,
      endDate: lastMonthEndDate,
      displayMode: DisplayMode.MONTHS,
      selectionMode: SelectionMode.MULTI,
      selectedDates: selectedDates,
      weekdayLabelsRow: CustomWeekdayLabelsRow(),
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Select authorized dates'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(height: 32.0),
            Text(lastMonthName,
              style: Theme.of(context).textTheme.headline4,
            ),
            lastMonth,
            Container(height: 16.0),
            Text(currentMonthName,
              style: Theme.of(context).textTheme.headline4,
            ),
            Container(height: 32.0),
            currentMonth,
            Container(height: 16.0),
            FormSubmitButton(
              context: context,
              text: 'Save',
              color: Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context).pop(selectedDates),
            ),
            Container(height: 16.0),
          ],
        ),
      ),
    );
  }
}
