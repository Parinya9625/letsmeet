// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/image_picker_controller.dart';
import 'package:letsmeet/components/controllers/interest_category_controller.dart';
import 'package:letsmeet/components/image_profile_picker.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/interest_category_selector.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/storage.dart';
import 'package:provider/provider.dart';

class SetupProfileArguments {
  final String name;
  final String surname;
  final DateTime birthday;

  SetupProfileArguments({
    required this.name,
    required this.surname,
    required this.birthday,
  });
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isSkipSetupProfile = true;

  TextEditingController bioController = TextEditingController();
  InterestCategorySelectorController categoryController =
      InterestCategorySelectorController();
  ImagePickerController imageController = ImagePickerController();

  @override
  void initState() {
    bioController.addListener(() {
      skipSetupProfile();
    });
    categoryController.addListener(() {
      skipSetupProfile();
    });
    imageController.addListener(() {
      skipSetupProfile();
    });

    super.initState();
  }

  void skipSetupProfile() {
    setState(() {
      isSkipSetupProfile = bioController.text.isEmpty &&
          categoryController.value.isEmpty &&
          imageController.path == null;
    });
  }

  showLoading() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? lmUser = context.watch<User?>();

    imageController.url = lmUser?.image != null
        ? lmUser!.image
        : "https://avatars.dicebear.com/api/identicon/${lmUser?.id ?? 0}.png?size=64&backgroundColor=white";

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.done))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                ImageProfilePicker(
                  controller: imageController,
                ),
                const SizedBox(height: 16),
                InputField(
                  hintText: "Name",
                  icon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                InputField(
                  hintText: "Surname",
                  icon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: bioController,
                  hintText: 'Bio',
                  icon: const Icon(Icons.badge_rounded),
                  onClear: () {},
                ),
                const SizedBox(height: 16),
                InterestCategorySelector(
                  controller: categoryController,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
