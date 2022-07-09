import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letsmeet/components/controllers/image_picker_controller.dart';

class ImageProfilePicker extends StatefulWidget {
  const ImageProfilePicker({Key? key, required this.controller})
      : super(key: key);

  final ImagePickerController controller;

  @override
  State<ImageProfilePicker> createState() => _ImageProfilePickerState();
}

class _ImageProfilePickerState extends State<ImageProfilePicker> {
  Widget pickerOptionButton(
      {VoidCallback? onPressed, required IconData icon, String? text}) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                text.toString(),
                style: Theme.of(context).textTheme.bodyText1,
              )
            ],
          ),
        ),
      ),
    );
  }

  void openCamera() async {
    ImagePicker picker = ImagePicker();
    XFile? file =
        await picker.pickImage(source: ImageSource.camera, maxHeight: 320);
    if (file != null) {
      widget.controller.value = file;
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  void openGallery() async {
    ImagePicker picker = ImagePicker();
    XFile? file =
        await picker.pickImage(source: ImageSource.gallery, maxHeight: 320);
    if (file != null) {
      widget.controller.value = file;
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  void showPickerOption() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select image with",
                style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  pickerOptionButton(
                    onPressed: openCamera,
                    icon: Icons.photo_camera_rounded,
                    text: "Camera",
                  ),
                  pickerOptionButton(
                    onPressed: openGallery,
                    icon: Icons.photo_library_rounded,
                    text: "Gallery",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Material(
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            elevation: Theme.of(context).cardTheme.elevation!,
            color: Theme.of(context).disabledColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.controller.value != null) ...{
                  Expanded(
                    child: widget.controller.value.runtimeType == String
                        ? CachedNetworkImage(
                            imageUrl: widget.controller.value,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(widget.controller.value!.path),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                },
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: showPickerOption,
          child: const Text("SELECT IMAGE"),
        ),
      ],
    );
  }
}
