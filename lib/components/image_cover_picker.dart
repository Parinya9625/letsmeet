import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letsmeet/components/controllers/image_picker_controller.dart';

class ImageCoverPicker extends StatefulWidget {
  final ImagePickerController controller;
  final String? errorText;

  const ImageCoverPicker({Key? key, required this.controller, this.errorText})
      : super(key: key);

  @override
  State<ImageCoverPicker> createState() => ImageCoverPickerState();
}

class ImageCoverPickerState extends State<ImageCoverPicker>
    with SingleTickerProviderStateMixin {
  Widget pickerOptionButton(
      {VoidCallback? onPressed, required IconData icon, String? text}) {
    return Material(
      color: Theme.of(context).cardColor,
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
    XFile? file = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 128, imageQuality: 50);
    if (file != null) {
      widget.controller.xfile = file;
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  void openGallery() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 128, imageQuality: 50);
    if (file != null) {
      widget.controller.xfile = file;
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

  bool _isValid = true;

  bool validate() {
    setState(() {
      _isValid = widget.controller.path != null;
      if (_isValid) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
    return _isValid;
  }

  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.image_rounded),
                  ),
                  Text(
                    "Image Cover",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ],
              ),
            ),
            Ink(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: showPickerOption,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.controller.path != null) ...{
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: widget.controller.xfile == null
                              ? CachedNetworkImage(
                                  imageUrl: widget.controller.path!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  widget.controller.file!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    } else ...{
                      const Icon(
                        Icons.image_rounded,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Select image cover",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    }
                  ],
                ),
              ),
            ),
            if (!_isValid && widget.errorText != null) ...{
              const SizedBox(height: 16),
              Row(
                children: [
                  FadeTransition(
                    opacity: _animationController,
                    child: Text(
                      widget.errorText!,
                      style: Theme.of(context).inputDecorationTheme.errorStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}
