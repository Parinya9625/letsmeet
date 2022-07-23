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
  final User user;
  const EditProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  InterestCategorySelectorController categoryController =
      InterestCategorySelectorController();
  ImagePickerController imageController = ImagePickerController();

  @override
  void initState() {
    imageController.url = widget.user.image;
    nameController.text = widget.user.name;
    surnameController.text = widget.user.surname;
    bioController.text = widget.user.bio;

    widget.user.getFavCategory.then((listCategory) {
      setState(() {
        categoryController.value = listCategory;
      });
    });

    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                String? imageUrl;

                showLoading();

                if (imageController.file != null) {
                  imageUrl = await context.read<StorageService>().uploadImage(
                        userId: widget.user.id!,
                        file: imageController.file!,
                      );
                } else {
                  imageUrl = imageController.path;
                }

                var updateUser = {
                  "image": imageUrl,
                  "name": nameController.text.trim(),
                  "surname": surnameController.text.trim(),
                  "bio": bioController.text.trim(),
                  "favCategory": categoryController.value
                      .map((category) => category.toDocRef())
                      .toList(),
                };

                context.read<CloudFirestoreService>().updateUser(
                      id: widget.user.id!,
                      data: updateUser,
                    );

                Navigator.pop(context); // Pop loading screen
                Navigator.pop(context); // Pop edit profile
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageProfilePicker(
                    controller: imageController,
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    controller: nameController,
                    hintText: "Name",
                    icon: const Icon(Icons.person_rounded),
                    onClear: () {},
                    validator: (value) {
                      if (nameController.text.trim().isEmpty) {
                        return "Please enter your name\n";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    controller: surnameController,
                    hintText: "Surname",
                    icon: const Icon(Icons.person_rounded),
                    onClear: () {},
                    validator: (value) {
                      if (surnameController.text.trim().isEmpty) {
                        return "Please enter your surname\n";
                      }
                      return null;
                    },
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
