import 'dart:core';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsmeet/components/controllers/icons_picker_controller.dart';
import 'package:letsmeet/components/admin/detail_dialog.dart';
import 'package:letsmeet/icons/material_icons.dart';
import 'package:letsmeet/icons/cupertino_icons.dart';
import 'package:letsmeet/icons/font_awesome_icons.dart';

class IconPack {
  final String name;
  final IconData tabIcon;
  final Map<String, IconData> icons;

  const IconPack({
    required this.name,
    required this.tabIcon,
    required this.icons,
  });
}

class IconsPicker extends StatefulWidget {
  final IconsPickerController controller;

  const IconsPicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<IconsPicker> createState() => _IconsPickerState();
}

class _IconsPickerState extends State<IconsPicker> {
  List<IconPack> iconPacks = [
    IconPack(
      name: "Material Icons",
      tabIcon: FontAwesomeIcons.android,
      icons: materialIcons,
    ),
    IconPack(
      name: "Cupertino Icons",
      tabIcon: FontAwesomeIcons.apple,
      icons: cupertinoIcons,
    ),
    IconPack(
      name: "Font Awesome Icons",
      tabIcon: FontAwesomeIcons.fontAwesome,
      icons: fontAwesomeIcons,
    ),
  ];

  Future<void> showPickerDialog() async {
    IconPack selectedTab = iconPacks.first;
    int page = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DetailDialog(
            width: 512,
            menus: [
              ...iconPacks.map(
                (pack) => DetailDialogMenuButton(
                    icon: pack.tabIcon,
                    onPressed: () {
                      setState(() {
                        selectedTab = pack;
                        page = 0;
                      });
                    }),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              DetailDialogMenuButton(
                icon: Icons.arrow_back,
                onPressed: () {
                  if (page > 0) {
                    setState(() {
                      page -= 1;
                    });
                  }
                },
              ),
              DetailDialogMenuButton(
                icon: Icons.arrow_forward,
                onPressed: () {
                  if ((page * 100) + 100 < selectedTab.icons.values.length) {
                    setState(() {
                      page += 1;
                    });
                  }
                },
              ),
              DetailDialogMenuButton(
                icon: Icons.close_rounded,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            child: GridView.count(
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              crossAxisCount: 10,
              children: selectedTab.icons.values
                  .toList()
                  .getRange(
                      (page * 100) + 0,
                      (page * 100) + 100 <= selectedTab.icons.values.length
                          ? (page * 100) + 100
                          : selectedTab.icons.values.length)
                  .map(
                    (icon) => TextButton(
                      onPressed: () {
                        setState(() {
                          widget.controller.value = icon;
                        });

                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).iconTheme.color,
                      ),
                      child: icon.fontPackage == "font_awesome_flutter"
                          ? FaIcon(icon)
                          : Icon(icon),
                    ),
                  )
                  .toList(),
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: TextButton(
        onPressed: () {
          showPickerDialog().then((_) => setState(() {}));
        },
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).disabledColor,
        ),
        child: Icon(
          widget.controller.value,
          size: 64,
        ),
      ),
    );
  }
}
