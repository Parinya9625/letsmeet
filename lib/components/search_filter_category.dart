import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/components/search_filter_base.dart';
import 'package:letsmeet/models/category.dart';
import 'package:provider/provider.dart';

class CategorySearchFilter extends StatefulWidget {
  final SearchFilterController controller;

  const CategorySearchFilter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<CategorySearchFilter> createState() => _CategorySearchFilterState();
}

class _CategorySearchFilterState extends State<CategorySearchFilter> {
  Category? selectedValue;

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
          padding: const EdgeInsets.all(8.0),
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
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: isSelected ? Theme.of(context).primaryColor : null,
                      fontSize: 12,
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
    List<Category> listCategory = context.watch<List<Category>>();

    return BaseSearchFilter(
      title: "Category",
      value: widget.controller.category != null
          ? widget.controller.category!.name
          : "All Category",
      onOpen: () {
        selectedValue = widget.controller.category;
      },
      onApply: () {
        setState(() {
          widget.controller.category = selectedValue;
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
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            shrinkWrap: true,
            children: listCategory
                .map(
                  (category) => filterOptionButton(
                    text: category.name,
                    icon: category.icon,
                    isSelected: selectedValue == category,
                    onPressed: () {
                      setState(() {
                        selectedValue = category;
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
