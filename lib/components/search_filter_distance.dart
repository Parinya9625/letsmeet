import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/components/search_filter_base.dart';

class DistanceSearchFilter extends StatefulWidget {
  final SearchFilterController controller;
  const DistanceSearchFilter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<DistanceSearchFilter> createState() => _DistanceSearchFilterState();
}

class _DistanceSearchFilterState extends State<DistanceSearchFilter> {
  double? selectedValue;

  @override
  Widget build(BuildContext context) {
    late StateSetter contentSetState;

    return BaseSearchFilter(
      title: "Distance",
      value: widget.controller.distance != null
          ? "Within ${widget.controller.distance!.toInt()} km"
          : "All Distance",
      onOpen: () {
        selectedValue = widget.controller.distance;
      },
      onApply: () {
        setState(() {
          widget.controller.distance = selectedValue;
        });
      },
      onClear: () {
        setState(() {
          selectedValue = null;
          contentSetState(() {});
        });
      },
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          contentSetState = setState;
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Slider(
                  value: selectedValue ?? 0,
                  max: 100,
                  onChanged: (double value) {
                    setState(() {
                      selectedValue = value >= 1 ? value.roundToDouble() : null;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  selectedValue != null
                      ? "${selectedValue!.toInt()} km"
                      : "All Distance",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
