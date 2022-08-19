import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/admin/detail_dialog.dart';
import 'package:letsmeet/components/admin/responsive_layout.dart';
import 'package:letsmeet/components/admin/icons_picker.dart';
import 'package:letsmeet/components/controllers/icons_picker_controller.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {

  void confirmRemoveCategory(BuildContext detailContext, Category category) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm remove category"),
          content: Text('Are you sure you want to remove "${category.name}"'),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(dialogContext);
              }
            ),

            TextButton(
              child: const Text("Remove"),
              onPressed: () {
                context.read<CloudFirestoreService>().removeCategory(
                  id: category.id!,
                );

                Navigator.pop(dialogContext);
                Navigator.pop(detailContext);
              }
            ),
          ],
        );
      }
    );
  }

  void categoryDialog({required Category category, bool addNewCategory = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isEditing = addNewCategory;
        Category oldCategory = category;
        Category currentCategory = category;

        IconsPickerController iconController = IconsPickerController(value: currentCategory.icon);
        TextEditingController nameController = TextEditingController(text: currentCategory.name);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DetailDialog(
              width: 512,
              menus: [
                DetailDialogMenuButton(
                  icon: Icons.arrow_back_rounded,
                  visible: isEditing && !addNewCategory,
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      currentCategory = oldCategory;
                      iconController.value = currentCategory.icon;
                      nameController.text = currentCategory.name;
                    });
                  }
                ),

                Visibility(
                  visible: isEditing,
                  child: const Expanded(
                    child: SizedBox(),
                  ),
                ),

                DetailDialogMenuButton(
                  icon: Icons.done_rounded,
                  visible: isEditing && !addNewCategory,
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      currentCategory = Category(
                        id: category.id,
                        name: nameController.text.trim(),
                        icon: iconController.value!,
                      );
                      oldCategory = currentCategory;
                    });
                  }
                ),

                DetailDialogMenuButton(
                  icon: Icons.save_rounded,
                  visible: !isEditing || addNewCategory,
                  onPressed: () {
                    if (addNewCategory) {
                      currentCategory = Category(
                        id: category.id,
                        name: nameController.text.trim(),
                        icon: iconController.value!,
                      );
                      context.read<CloudFirestoreService>().addCategory(
                        category: currentCategory,
                      );
                    }
                    else {
                      context.read<CloudFirestoreService>().updateCategory(
                        id: currentCategory.id!,
                        data: currentCategory.toMap(),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),

                DetailDialogMenuButton(
                  icon: Icons.edit_rounded,
                  visible: !isEditing && !addNewCategory,
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  }
                ),

                DetailDialogMenuButton(
                  icon: Icons.delete_rounded,
                  visible: !isEditing && !addNewCategory,
                  onPressed: () {
                    confirmRemoveCategory(context, category);
                  },
                ),

                DetailDialogMenuButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],

              child: Row(
                children: [
                  // icon
                  AbsorbPointer(
                    absorbing: !isEditing,
                    child: IconsPicker(
                      controller: iconController,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // name
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name",
                          style: Theme.of(context).textTheme.headline2,
                        ),

                        const SizedBox(height: 16),

                        InputField(
                          controller: nameController,
                          elevation: 0,
                          backgroundColor: Theme.of(context).disabledColor,
                          readOnly: !isEditing,
                          onChanged: (value) {
                            setState(() {
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget categoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        categoryDialog(
          category: category,
        );
      },
      child: Card(
        margin: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline1!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Category> listCategory = context.watch<List<Category>>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Category"),
        onPressed: () {
          categoryDialog(
            category: Category.create(
              name: "New Category",
              icon: Icons.fiber_new_rounded,
            ),
            addNewCategory: true,
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Categories",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: ResponsiveValue(
                  context: context,
                  small: 2,
                  medium: 3,
                  large: 5,
                ),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 2 / 1,
                children: [
                  for (Category category in listCategory) ...{
                    categoryCard(category),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
