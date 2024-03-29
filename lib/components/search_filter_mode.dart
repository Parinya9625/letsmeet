import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/components/search_filter_base.dart';

class ModeSearchFilter extends StatefulWidget {
  final SearchFilterController controller;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final VoidCallback? onApply;

  const ModeSearchFilter({
    Key? key,
    required this.controller,
    this.onOpen,
    this.onClose,
    this.onApply,
  }) : super(key: key);

  @override
  State<ModeSearchFilter> createState() => _ModeSearchFilterState();
}

class _ModeSearchFilterState extends State<ModeSearchFilter> {
  late String selectedValue;
  List<Map<String, dynamic>> optionList = [
    {"name": "Event", "icon": Icons.calendar_month_rounded, "value": "Event"},
    {"name": "User", "icon": Icons.person_rounded, "value": "User"},
  ];

  Widget filterOptionButton({
    VoidCallback? onPressed,
    required IconData icon,
    String? text,
    bool isSelected = false,
  }) {
    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(height: 8),
              Text(
                text.toString(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    selectedValue = widget.controller.mode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseSearchFilter(
      title: "Mode",
      value: widget.controller.mode,
      onOpen: () {
        widget.onOpen?.call();
        selectedValue = widget.controller.mode;
      },
      onClose: widget.onClose,
      onApply: () {
        setState(() {
          widget.controller.mode = selectedValue;
          widget.onApply?.call();
        });
      },
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: optionList
              .map(
                (option) => filterOptionButton(
                  text: option["name"],
                  icon: option["icon"],
                  isSelected: selectedValue == option["value"],
                  onPressed: () {
                    setState(() {
                      selectedValue = option["value"];
                    });
                  },
                ),
              )
              .toList(),
        );
      }),
    );
  }
}
