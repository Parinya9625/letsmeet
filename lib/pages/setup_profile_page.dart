import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/image_picker_controller.dart';
import 'package:letsmeet/components/controllers/interest_category_controller.dart';
import 'package:letsmeet/components/image_profile_picker.dart';
import 'package:letsmeet/components/interest_category_selector.dart';
import 'package:letsmeet/components/textfield_extension.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({Key? key}) : super(key: key);

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  TextEditingController bioController = TextEditingController();
  InterestCategorySelectorController categoryController =
      InterestCategorySelectorController();
  ImagePickerController imageController = ImagePickerController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Setup profile",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              ImageProfilePicker(
                controller: imageController,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  hintText: 'Bio',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ).withElevation(),
              const SizedBox(height: 16),
              InterestCategorySelector(
                controller: categoryController,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Update profile
                  print(
                      "bio: ${bioController.text.trim()}\ncategory: ${categoryController.value}\nimage: ${imageController.value}");
                },
                child: const Text("UPDATE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
