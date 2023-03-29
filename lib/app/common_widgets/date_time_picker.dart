import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/input_dropdown.dart';
import 'package:nmwhitelabel/app/utilities/format.dart';

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    Key? key,
    this.labelText,
    this.selectedDate,
    this.selectedTime,
    this.onSelecedtDate,
    this.onSelectedTime,
  }) : super(key: key);

  final String? labelText;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime>? onSelecedtDate;
  final ValueChanged<TimeOfDay>? onSelectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      onSelecedtDate!(pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime =
        await showTimePicker(context: context, initialTime: selectedTime!);
    if (pickedTime != null && pickedTime != selectedTime) {
      onSelectedTime!(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.titleLarge;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (selectedDate != null)
          Expanded(
            flex: 5,
            child: InputDropdown(
              labelText: labelText,
              valueText: Format.date(selectedDate!),
              valueStyle: valueStyle,
              onPressed: () => _selectDate(context),
            ),
          ),
        if (selectedTime != null) SizedBox(width: 12.0),
        if (selectedTime != null)
          Expanded(
            flex: 4,
            child: InputDropdown(
              labelText: selectedDate == null ? labelText : '',
              valueText: selectedTime!.format(context),
              valueStyle: valueStyle,
              onPressed: () => _selectTime(context),
            ),
          ),
      ],
    );
  }
}
