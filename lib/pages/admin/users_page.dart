import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsmeet/style.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/ban.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/admin/detail_dialog.dart';
import 'package:letsmeet/components/admin/responsive_layout.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Role> listRole = [];
  List<Category> listCategory = [];
  List<Report> listReport = [];
  List<Ban> listBan = [];
  TextEditingController searchController = TextEditingController();
  List<String> filterOptions = [
    "All Users",
    "Reported Users",
    "Baned Users",
  ];
  String selectedFilterOption = "All Users";
  FocusNode filterFocusNode = FocusNode();

  void confirmIgnoreReport(BuildContext detailContext, User user) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm ignore report"),
            content: const Text(
                'Are you sure you want to ignore this user reported?\nAll reported detail will be remove after confirm this dialog.'),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  }),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    elevation: 0,
                  ),
                  child: const Text("Confirm"),
                  onPressed: () {
                    context.read<CloudFirestoreService>().removeReport(
                          id: user.id!,
                        );

                    Navigator.pop(dialogContext);
                    Navigator.pop(detailContext);
                  }),
            ],
          );
        });
  }

  void confirmBanUser(BuildContext detailContext, User user) async {
    final formKey = GlobalKey<FormState>();
    TextEditingController reasonController = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm ban user"),
            content: SizedBox(
              width: 512,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Give a reason why you want to ban "${user.name} ${user.surname}"?'),
                    const SizedBox(height: 16),
                    InputField(
                      controller: reasonController,
                      hintText: "Reason...",
                      maxLines: 2,
                      elevation: 0,
                      backgroundColor: Theme.of(context).disabledColor,
                      onClear: () {},
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please give a reason before ban\n";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  }),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    elevation: 0,
                  ),
                  child: const Text("Ban"),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<CloudFirestoreService>().addBan(
                            ban: Ban.now(
                              id: user.id!,
                              reason: reasonController.text.trim(),
                            ),
                          );

                      context.read<CloudFirestoreService>().removeReport(
                            id: user.id!,
                          );

                      Navigator.pop(dialogContext);
                      Navigator.pop(detailContext);
                    }
                  }),
            ],
          );
        });
  }

  void confirmUnbanUser(BuildContext detailContext, User user) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm unban user"),
            content: Text(
                'Are you sure you want to unban "${user.name} ${user.surname}"?'),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  }),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    elevation: 0,
                  ),
                  child: const Text("Unban"),
                  onPressed: () {
                    context.read<CloudFirestoreService>().removeBan(
                          id: user.id!,
                        );

                    Navigator.pop(dialogContext);
                    Navigator.pop(detailContext);
                  }),
            ],
          );
        });
  }

  void changeUserRole(BuildContext detailContext, User user) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          User currentUser = context.read<User?>()!;
          int cupLevel = getPermissionLevel(getRole(currentUser.role.id));

          return DetailDialog(
            width: 512 + 128,
            menus: [
              DetailDialogMenuButton(
                icon: Icons.close_rounded,
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ],
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 3 / 1,
              children: [
                for (Role role in listRole) ...{
                  if (cupLevel <= getPermissionLevel(role)) ...{
                    GestureDetector(
                      onTap: () {
                        context
                            .read<CloudFirestoreService>()
                            .updateUser(id: user.id!, data: {
                          "role": role.toDocRef(),
                        });

                        Navigator.pop(dialogContext);
                        Navigator.pop(detailContext);
                      },
                      child: roleCard(role),
                    ),
                  },
                },
              ],
            ),
          );
        });
  }

  Role getRole(String id) {
    return listRole.firstWhere(
      (role) => role.id == id,
      orElse: () => Role.create(
        name: "Unknown",
        foregroundColor: Colors.yellow,
        backgroundColor: Colors.red,
        permission: UserPermission(),
      ),
    );
  }

  Category getCategory(String id) {
    return listCategory.firstWhere(
      (category) => category.id == id,
      orElse: () => Category.create(
        name: "Unknown",
        icon: Icons.help_rounded,
      ),
    );
  }

  Report? getReport(String id) {
    return listReport.firstWhereOrNull(
      (report) => report.id == id && report.type == "user",
    );
  }

  Ban? getBan(String id) {
    return listBan.firstWhereOrNull(
      (ban) => ban.id == id,
    );
  }

  int getPermissionLevel(Role role) {
    int permissionLevel = role.permission.isAdmin ? 1 : 999;

    return permissionLevel;
  }

  Widget roleCard(Role role) {
    return Card(
      margin: const EdgeInsets.all(2),
      color: role.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
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

  Widget ratingBar({String title = "", int value = 0, int max = 100}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline2,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value: value == 0 ? 0 : value / max,
                  minHeight: 12,
                  color: Theme.of(context).extension<LetsMeetColor>()!.rating,
                  backgroundColor: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow textDetail({String? title, String? text, List<Widget>? children}) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title ?? "",
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Wrap(
              children: [
                if (text != null) ...{
                  Text(text),
                },
                ...?children,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget leftPanelDialog(User user) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Info",
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),

          const SizedBox(height: 16),

          // image profile
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: user.image,
                      fit: BoxFit.cover,
                      width: 128,
                      height: 128,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              textDetail(
                title: "Name",
                text: user.name,
              ),
              textDetail(
                title: "Surname",
                text: user.surname,
              ),
              textDetail(
                title: "Role",
                text: getRole(user.role.id).name,
              ),
              textDetail(
                title: "Bio",
                text: user.bio,
              ),
              textDetail(
                title: "Birthday",
                text: DateFormat("EEE, dd MMM y").format(user.birthday),
              ),
              textDetail(
                title: "Joined Date",
                text: DateFormat("EEE, dd MMM y").format(user.createdTime),
              ),
              textDetail(
                title: "Interest Category",
                children: [
                  for (DocumentReference category in user.favCategory) ...{
                    Tooltip(
                      message: getCategory(category.id).name,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                        ),
                        child: Icon(
                          getCategory(category.id).icon,
                          color: Theme.of(context).textTheme.headline1!.color,
                        ),
                      ),
                    ),
                  },
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget ratingSection(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ratings",
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double avgRating = user.rating.average();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 2,
                      children: [
                        for (int i = 1; i < 6; i++) ...{
                          Icon(
                            i <= avgRating
                                ? Icons.star_rounded
                                : avgRating.round() == i
                                    ? Icons.star_half_rounded
                                    : Icons.star_border_rounded,
                            color: Theme.of(context)
                                .extension<LetsMeetColor>()!
                                .rating,
                            size: 16,
                          ),
                        },
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "(${user.rating.amount()})",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (MapEntry<String, int> rate
                      in user.rating.reverseMap().entries) ...{
                    ratingBar(
                      title: rate.key,
                      value: rate.value,
                      max: user.rating.max(),
                    ),
                  },
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget reportSection(User user) {
    Report? report = getReport(user.id!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Reported Detail",
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            if (report != null) ...{
              const SizedBox(width: 8),
              Text(
                "(${report.reason.length})",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            },
          ],
        ),
        const SizedBox(height: 16),
        if (report == null) ...{
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: FaIcon(FontAwesomeIcons.solidFaceLaugh,
                        size: 96,
                        color: Theme.of(context)
                            .extension<LetsMeetColor>()!
                            .eventOpen),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No report found for this user",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        } else ...{
          for (MapEntry<String, int> reason
              in report.reasonToMap().entries) ...{
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        reason.key,
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      const Spacer(),
                      Text(
                        "${reason.value}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: reason.value / report.reasonToMap().values.max,
                      minHeight: 12,
                      color: Theme.of(context).errorColor,
                      backgroundColor: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          },
        },
      ],
    );
  }

  Widget banSection(Ban ban) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Ban Info",
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: [
            textDetail(
              title: "Ban Date",
              text: DateFormat("EEE, dd MMM y").format(ban.banTime),
            ),
            textDetail(
              title: "Reason",
              text: ban.reason,
            ),
          ],
        ),
      ],
    );
  }

  Widget rightPanelDialog(User user) {
    Ban? ban = getBan(user.id!);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ratingSection(user),
          const SizedBox(height: 16),
          if (ban != null) ...{
            banSection(ban),
          } else ...{
            reportSection(user),
          },
        ],
      ),
    );
  }

  void userDialog({required User user}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Report? isReported = getReport(user.id!);
        Ban? isBaned = getBan(user.id!);

        // Current login user
        User currentUser = context.read<User?>()!;
        Role cuRole = getRole(currentUser.role.id);
        int cupLevel = getPermissionLevel(cuRole);

        // User in dialog
        Role uRole = getRole(user.role.id);
        int upLevel = getPermissionLevel(uRole);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DetailDialog(
              width: 512 + 256 + 128,
              menus: [
                if (isBaned == null && cupLevel <= upLevel) ...{
                  DetailDialogMenuButton(
                    child: Row(
                      children: const [
                        Icon(Icons.manage_accounts_rounded),
                        SizedBox(width: 16),
                        Text("Change Role"),
                      ],
                    ),
                    onPressed: () {
                      changeUserRole(context, user);
                    },
                  ),
                },
                if (isReported != null && isBaned == null) ...{
                  DetailDialogMenuButton(
                    child: Row(
                      children: const [
                        Icon(Icons.report_off_rounded),
                        SizedBox(width: 16),
                        Text("Ignore Report"),
                      ],
                    ),
                    onPressed: () {
                      confirmIgnoreReport(context, user);
                    },
                  ),
                },
                if (isBaned != null) ...{
                  DetailDialogMenuButton(
                    child: Row(
                      children: const [
                        Icon(Icons.how_to_reg_rounded),
                        SizedBox(width: 16),
                        Text("Unban"),
                      ],
                    ),
                    onPressed: () {
                      confirmUnbanUser(context, user);
                    },
                  ),
                } else ...{
                  if (cupLevel <= upLevel) ...{
                    DetailDialogMenuButton(
                      color: Theme.of(context).errorColor,
                      child: Row(
                        children: const [
                          Icon(Icons.block_rounded),
                          SizedBox(width: 16),
                          Text("Ban"),
                        ],
                      ),
                      onPressed: () {
                        confirmBanUser(context, user);
                      },
                    ),
                  },
                },
                DetailDialogMenuButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leftPanelDialog(user),
                  rightPanelDialog(user),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget userCard(User user) {
    Role role = getRole(user.role.id);

    return GestureDetector(
      onTap: () {
        userDialog(
          user: user,
        );
      },
      child: Card(
        margin: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: user.image,
                    fit: BoxFit.cover,
                    width: 64 + 16,
                    height: 64 + 16,
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 8,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${user.name} ${user.surname}",
                          style: Theme.of(context).textTheme.headline1!,
                        ),
                        const SizedBox(width: 16),
                        Badge(
                          title: role.name,
                          foregroundColor: role.foregroundColor,
                          backgroundColor: role.backgroundColor,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded),
                        const SizedBox(width: 8),
                        Text(
                          "Joined Date : ${DateFormat("EEE, dd MMM y").format(user.createdTime)}",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topSection({int count = 0}) {
    return Row(
      children: [
        Expanded(
          flex: ResponsiveValue(
            context: context,
            extraLarge: 3,
            large: 3,
            medium: 2,
          ),
          child: Text(
            "Users (${count})",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: ResponsiveValue(
            context: context,
            extraLarge: 1,
            large: 2,
            medium: 2,
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: DropdownButton(
              borderRadius: BorderRadius.circular(16),
              underline: const SizedBox(),
              icon: const Padding(
                padding: EdgeInsets.only(
                  right: 4,
                ),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 32,
                ),
              ),
              isExpanded: true,
              focusNode: filterFocusNode,
              value: selectedFilterOption,
              items: filterOptions
                  .map(
                    (filter) => DropdownMenuItem(
                      value: filter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Text(filter),
                      ),
                    ),
                  )
                  .toList(),
              onTap: () {
                filterFocusNode.unfocus();
              },
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedFilterOption = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 2,
          child: InputField(
            controller: searchController,
            icon: const Icon(Icons.search_rounded),
            hintText: "Search by name",
            onClear: () {
              setState(() {});
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    listRole = context.watch<List<Role>?>() ?? [];
    listReport = context.watch<List<Report>?>() ?? [];
    listCategory = context.watch<List<Category>?>() ?? [];
    listBan = context.watch<List<Ban>?>() ?? [];

    List<User> listUser = context.watch<List<User>?>() ?? [];
    // sort user by created time
    if (listUser != [] && listUser.length >= 2) {
      listUser.sort(
          (userA, userB) => userB.createdTime.compareTo(userA.createdTime));
    }
    // remove all baned user
    if (selectedFilterOption != "Baned Users") {
      listUser = listUser
          .where((user) => !listBan.any((ban) => ban.id == user.id))
          .toList();
    }
    // filter by options
    if (selectedFilterOption == "Reported Users") {
      listUser = listUser
          .where((user) => listReport
              .any((report) => report.id == user.id && report.type == "user"))
          .toList();
    } else if (selectedFilterOption == "Baned Users") {
      listUser = listUser
          .where((user) => listBan.any((ban) => ban.id == user.id))
          .toList();
    }

    // filter by search text
    if (searchController.text.trim().isNotEmpty) {
      listUser = listUser.where((user) {
        List<String> words =
            searchController.text.toLowerCase().trim().split(" ");
        return words.every((word) =>
            user.name.toLowerCase().contains(word) ||
            user.surname.toLowerCase().contains(word));
      }).toList();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              topSection(
                count: listUser.length,
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: ResponsiveValue(
                  context: context,
                  small: 1,
                  medium: 1,
                  large: 2,
                  extraLarge: 3,
                ),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: ResponsiveValue(
                  context: context,
                  small: 4 / 1,
                  medium: 4 / 1,
                  large: 5 / 1,
                  extraLarge: 5 / 1,
                ),
                children: [
                  for (User user in listUser) ...{
                    userCard(user),
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
