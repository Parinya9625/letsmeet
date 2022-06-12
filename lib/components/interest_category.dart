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
  @override
  Widget build(BuildContext context) {
    List<Category> categories = context.watch<List<Category>>();

    // if "category" is selected ?
    bool isSelected(Category category) {
      return widget.controller.value.contains(category);
    }

    ButtonStyle btnStyle(Category category) {
      return ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevation: isSelected(category)
            ? MaterialStateProperty.all<double>(2)
            : MaterialStateProperty.all<double>(0),
        backgroundColor: isSelected(category)
            ? MaterialStateProperty.all<Color>(Colors.blue)
            : MaterialStateProperty.all<Color>(Colors.white),
        foregroundColor: isSelected(category)
            ? MaterialStateProperty.all<Color>(Colors.white)
            : MaterialStateProperty.all<Color>(Colors.grey),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 32 / 10,
        padding: const EdgeInsets.all(16.0),
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(category.icon),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        category.name,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          }
        ],
      ),
    );
  }
}
