import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/interest_category_controller.dart';
import 'package:letsmeet/models/category.dart';
import 'package:provider/provider.dart';

class InterestCategorySelector extends StatefulWidget {
  final InterestCategorySelectorController controller;

  const InterestCategorySelector({Key? key, required this.controller})
      : super(key: key);

  @override
  State<InterestCategorySelector> createState() =>
      _InterestCategorySelectorState();
}

class _InterestCategorySelectorState extends State<InterestCategorySelector> {
  // if "category" is selected ?
  bool isSelected(Category category) {
    return widget.controller.value.any((cat) => cat.id == category.id);
  }

  ButtonStyle btnStyle(Category category) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      elevation: isSelected(category)
          ? MaterialStateProperty.all<double>(2)
          : MaterialStateProperty.all<double>(0),
      backgroundColor: isSelected(category)
          ? MaterialStateProperty.all<Color>(Theme.of(context).primaryColor)
          : MaterialStateProperty.all<Color>(Theme.of(context).cardColor),
      foregroundColor: isSelected(category)
          ? MaterialStateProperty.all<Color>(Colors.white)
          : MaterialStateProperty.all<Color>(
              Theme.of(context).textTheme.bodyText1!.color!),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Category> categories = context.watch<List<Category>>();

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.category),
                ),
                Text(
                  "Interest Category",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 32 / 10,
            padding: const EdgeInsets.all(16.0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              for (Category category in categories) ...{
                ElevatedButton(
                  style: btnStyle(category),
                  onPressed: () {
                    setState(() {
                      widget.controller.select(category);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Icon(
                            category.icon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            category.name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              }
            ],
          ),
        ],
      ),
    );
  }
}
