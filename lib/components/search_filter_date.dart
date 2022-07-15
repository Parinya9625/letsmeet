import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/search_filter_base.dart';

class DateSearchFilter extends StatefulWidget {
  final SearchFilterController controller;

  const DateSearchFilter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<DateSearchFilter> createState() => _DateSearchFilterState();
}

class _DateSearchFilterState extends State<DateSearchFilter> {
  DateTimeRange? selectedValue;
  TextEditingController selectedValueText = TextEditingController();

  Future<DateTimeRange?> showDatePicker(DateTimeRange? value) async {
    DateTimeRange? date = await showDateRangePicker(
        context: context,
        initialDateRange: value,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Theme.of(context).textTheme.headline1!.color,
                  ),
            ),
            child: child!,
          );
        });

    return date;
  }

  String dateFormat(DateTimeRange date) {
    DateTime start = date.start;
    DateTime end = date.end;

    return "${DateFormat("dd MMM y").format(start)} - ${DateFormat("dd MMM y").format(end)}";
  }

  @override
  Widget build(BuildContext context) {
    return BaseSearchFilter(
      title: "Date",
      value: widget.controller.dateRange != null
          ? dateFormat(widget.controller.dateRange!)
          : "All Date",
      onOpen: () {
        selectedValue = widget.controller.dateRange;
        if (widget.controller.dateRange != null) {
          selectedValueText.text = dateFormat(widget.controller.dateRange!);
        } else {
          selectedValueText.clear();
        }
      },
      onApply: () {
        setState(() {
          widget.controller.dateRange = selectedValue;
        });
      },
      onClear: () {
        setState(() {
          selectedValue = null;
          selectedValueText.clear();
        });
      },
      child: Column(
        children: [
          InputField(
            controller: selectedValueText,
            icon: const Icon(Icons.calendar_month_rounded),
            hintText: "Pick date range",
            readOnly: true,
            onTap: () async {
              DateTimeRange? dateRange = await showDatePicker(selectedValue);

              setState(() {
                selectedValue = dateRange ?? selectedValue;
                if (selectedValue != null) {
                  selectedValueText.text = dateFormat(selectedValue!);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
