// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/image_picker_controller.dart';
import 'package:letsmeet/components/controllers/interest_category_controller.dart';
import 'package:letsmeet/components/image_profile_picker.dart';
import 'package:letsmeet/components/interest_category_selector.dart';
import 'package:letsmeet/components/textfield_extension.dart';
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

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({Key? key}) : super(key: key);

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
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
      body: SafeArea(
        child: Center(
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
                    onPressed: () async {
                      showLoading();

                      String imageUrl;
                      if (imageController.file != null) {
                        imageUrl = await context
                            .read<StorageService>()
                            .uploadImage(
                                userId: lmUser!.id!,
                                file: imageController.file!);
                      } else {
                        imageUrl = imageController.path!;
                      }

                      context
                          .read<CloudFirestoreService>()
                          .updateUserPartial(id: lmUser!.id!, data: {
                        "image": imageUrl,
                        "bio": bioController.text.trim(),
                        "favCategory": categoryController.value
                            .map((category) => category.toDocRef())
                            .toList(),
                        "isFinishSetup": true,
                      });
                    },
                    child: isSkipSetupProfile
                        ? const Text("SKIP")
                        : const Text("UPDATE"),
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
