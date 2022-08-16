import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/checkbox_tile.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/components/admin/detail_dialog.dart';
import 'package:letsmeet/components/admin/responsive_layout.dart';
import 'package:letsmeet/components/controllers/checkbox_tile_controller.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({Key? key}) : super(key: key);

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    List<Role> listRole = context.watch<List<Role>>();

    void confirmRemoveRole(BuildContext detailContext, Role role) async {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm remove role"),
            content: Text('Are you sure you want to remove "${role.name}"'),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
              TextButton(
                child: const Text("Remove"),
                onPressed: () {
                  context.read<CloudFirestoreService>().removeRole(
                        id: role.id!,
                      );

                  Navigator.pop(dialogContext);
                  Navigator.pop(detailContext);
                },
              ),
            ],
          );
        },
      );
    }

    Future<Color> colorPicker({required Color initColor}) async {
      TextEditingController hexController = TextEditingController();
      Color pickerColor = initColor;
      Color returnColor = initColor;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DetailDialog(
            width: 128,
            menus: [
              DetailDialogMenuButton(
                  icon: Icons.done_rounded,
                  onPressed: () {
                    setState(() {
                      returnColor = pickerColor;
                    });
                    Navigator.pop(context);
                  }),
              DetailDialogMenuButton(
                icon: Icons.close_rounded,
                onPressed: () {
                  setState(() {
                    returnColor = initColor;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    setState(() {
                      pickerColor = color;
                    });
                  },
                  portraitOnly: true,
                  labelTypes: const [],
                  pickerAreaBorderRadius: BorderRadius.circular(16),
                  hexInputController: hexController,
                ),
                InputField(
                  controller: hexController,
                  icon: const Icon(Icons.palette),
                  elevation: 0,
                  backgroundColor: Theme.of(context).disabledColor,
                ),
              ],
            ),
          );
        },
      );

      return returnColor;
    }

    void roleDialog({required Role role, bool addNewRole = false}) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          bool isEditing = addNewRole;
          Role oldRole = role;
          Role currentRole = role;

          TextEditingController nameController =
              TextEditingController(text: currentRole.name);
          Color foregroundColor = currentRole.foregroundColor;
          Color backgroundColor = currentRole.backgroundColor;
          CheckboxTileController isAdminController =
              CheckboxTileController(value: currentRole.permission.isAdmin);

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DetailDialog(
              width: 512,
              menus: [
                DetailDialogMenuButton(
                    icon: Icons.arrow_back_rounded,
                    visible: isEditing && !addNewRole,
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        currentRole = oldRole;
                        // reverse all edited role
                        nameController.text = currentRole.name;
                        foregroundColor = currentRole.foregroundColor;
                        backgroundColor = currentRole.backgroundColor;
                        isAdminController.value =
                            currentRole.permission.isAdmin;
                      });
                    }),
                Visibility(
                  visible: isEditing,
                  child: const Expanded(
                    child: SizedBox(),
                  ),
                ),
                DetailDialogMenuButton(
                    icon: Icons.done_rounded,
                    visible: isEditing && !addNewRole,
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        currentRole = Role(
                          id: role.id,
                          name: nameController.text.trim(),
                          foregroundColor: foregroundColor,
                          backgroundColor: backgroundColor,
                          permission: UserPermission(
                            isAdmin: isAdminController.value ?? false,
                          ),
                        );
                        oldRole = currentRole;
                      });
                    }),
                DetailDialogMenuButton(
                  icon: Icons.save_rounded,
                  visible: !isEditing || addNewRole,
                  onPressed: () {
                    if (addNewRole) {
                      currentRole = Role(
                        id: role.id,
                        name: nameController.text.trim(),
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor,
                        permission: UserPermission(
                          isAdmin: isAdminController.value ?? false,
                        ),
                      );
                      context.read<CloudFirestoreService>().addRole(
                            role: currentRole,
                          );
                    } else {
                      context.read<CloudFirestoreService>().updateRole(
                            id: currentRole.id!,
                            data: currentRole.toMap(),
                          );
                    }
                    Navigator.pop(context);
                  },
                ),
                DetailDialogMenuButton(
                    icon: Icons.edit_rounded,
                    visible: !isEditing && !addNewRole,
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    }),
                DetailDialogMenuButton(
                  icon: Icons.delete_rounded,
                  visible: !isEditing &&
                      !addNewRole &&
                      !["user", "admin"].contains(role.id),
                  onPressed: () {
                    confirmRemoveRole(context, role);
                  },
                ),
                DetailDialogMenuButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // preview
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Badge(
                        title: nameController.text.trim(),
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // name
                  Row(
                    children: [
                      Text(
                        "Name",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: InputField(
                          controller: nameController,
                          elevation: 0,
                          backgroundColor: Theme.of(context).disabledColor,
                          readOnly: !isEditing,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // color
                  Row(
                    children: [
                      Text(
                        "Foreground Color",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: isEditing
                              ? () async {
                                  Color newColor = await colorPicker(
                                    initColor: foregroundColor,
                                  );

                                  setState(() {
                                    foregroundColor = newColor;
                                  });
                                }
                              : null,
                          child: SizedBox(
                            height: 48,
                            child: Material(
                              borderRadius: BorderRadius.circular(16),
                              elevation: 2,
                              color: foregroundColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Background Color",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: isEditing
                              ? () async {
                                  Color newColor = await colorPicker(
                                    initColor: backgroundColor,
                                  );

                                  setState(() {
                                    backgroundColor = newColor;
                                  });
                                }
                              : null,
                          child: SizedBox(
                            height: 48,
                            child: Material(
                              borderRadius: BorderRadius.circular(16),
                              elevation: 2,
                              color: backgroundColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // permission
                  AbsorbPointer(
                    absorbing: !isEditing,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Permission",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(height: 16),
                        CheckboxTile(
                          controller: isAdminController,
                          elevation: 0,
                          title: const Text("isAdmin"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        },
      );
    }

    Widget roleCard(Role role) {
      return GestureDetector(
        onTap: () {
          roleDialog(
            role: role,
          );
        },
        child: Card(
          margin: const EdgeInsets.all(2),
          color: role.backgroundColor,
          child: Center(
            child: Text(
              role.name,
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: role.foregroundColor,
                  ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Role"),
        onPressed: () {
          roleDialog(
            role: Role.create(
              name: "New Role",
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              permission: UserPermission(),
            ),
            addNewRole: true,
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
                      "Roles",
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
                childAspectRatio: ResponsiveValue(
                  context: context,
                  small: 3 / 1,
                  medium: 4 / 1,
                  large: 4 / 1,
                ),
                children: [
                  for (Role role in listRole) ...{
                    roleCard(role),
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
