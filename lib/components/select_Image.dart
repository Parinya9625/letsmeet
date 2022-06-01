import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/people/v1.dart';

class ImageButon extends StatefulWidget {
  const ImageButon({Key? key}) : super(key: key);

  @override
  State<ImageButon> createState() => _ImageButonState();
}

class _ImageButonState extends State<ImageButon> {
  XFile? imageFile;
  _openGallary(BuildContext context) async {
    ImagePicker picker = ImagePicker();
    var picture = await picker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    ImagePicker picker = ImagePicker();
    var picture = await picker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Make a Choice '),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.image),
                        ),
                        Text('Gallary')
                      ],
                    ),
                    onTap: () {
                      _openGallary(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.photo_camera),
                        ),
                        Text('Camera'),
                      ],
                    ),
                    onTap: () {
                      _openCamera(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.image),
                ),
                Text('Image Cover'),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: TextButton(
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 211, 206, 206),
                  padding: const EdgeInsets.all(0),
                  minimumSize: const Size.fromHeight(120),
                  maximumSize: const Size.fromHeight(120)),
              onPressed: () {
                _showChoiceDialog(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imageFile != null) ...{
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Image.file(
                              File(imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  } else ...{
                    const Icon(Icons.image),
                    const Text("Select image cover")
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
