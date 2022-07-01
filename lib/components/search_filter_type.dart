import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/components/search_filter_base.dart';

class TypeSearchFilter extends StatefulWidget {
  final SearchFilterController controller;

  const TypeSearchFilter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<TypeSearchFilter> createState() => _TypeSearchFilterState();
}

class _TypeSearchFilterState extends State<TypeSearchFilter> {
  String? selectedValue;
  List<Map<String, dynamic>> optionList = [
    {"name": "In Person", "icon": Icons.group_rounded, "value": "In Person"},
    {"name": "Online", "icon": Icons.videocam_rounded, "value": "Online"},
  ];

  Widget filterOptionButton({
    VoidCallback? onPressed,
    required IconData icon,
    String? text,
    bool isSelected = false,
  }) {
    return Material(
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
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    late StateSetter contentSetState;

    return BaseSearchFilter(
      title: "Type",
      value: widget.controller.type ?? "All Type",
      onOpen: () {
        selectedValue = widget.controller.type;
      },
      onApply: () {
        setState(() {
          widget.controller.type = selectedValue;
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
        },
      ),
    );
  }
}
