import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/user.dart';
import 'package:collection/collection.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/style.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatefulWidget {
  final User user;
  final bool isOtherUser;
  final VoidCallback? onEditPressed;
  final VoidCallback? onMenuPressed;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.isOtherUser,
    this.onEditPressed,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

enum _PopupMenuValue {
  signout,
}

class _ProfileHeaderState extends State<ProfileHeader> {
  Widget placeholder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 300,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 300,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 300,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget userData() {
    return FutureBuilder(
      future: Future.wait([widget.user.getRole, widget.user.getFavCategory]),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ShimmerLoading(
          isLoading: !snapshot.hasData,
          placeholder: placeholder(),
          builder: (BuildContext context) {
            Role role = snapshot.data[0];
            List<Category> favCategory = snapshot.data[1];
            double rating = widget.user.rating.average();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            "${widget.user.name} ${widget.user.surname}",
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          Badge(
                            title: role.name,
                            backgroundColor: role.backgroundColor,
                            foregroundColor: role.foregroundColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.user.bio,
                        style: Theme.of(context).textTheme.bodyText1,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (favCategory.isNotEmpty) ...{
                            Text(
                              "Interests :",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          },
                          for (Category category in favCategory) ...{
                            Icon(category.icon),
                          }
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            "Rating :",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          for (int i = 1; i < 6; i++) ...{
                            Icon(
                              i <= rating
                                  ? Icons.star_rounded
                                  : rating.round() == i
                                      ? Icons.star_half_rounded
                                      : Icons.star_border_rounded,
                              color: Theme.of(context)
                                  .extension<LetsMeetColor>()!
                                  .rating,
                            ),
                          }
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget userMenu() {
    return Row(
      children: [
        if (widget.isOtherUser) ...{
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                showReportDialog();
              },
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).errorColor,
                    ),
                  ),
              child: const Text("REPORT"),
            ),
          ),
        } else ...{
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onEditPressed,
              child: const Text("EDIT PROFILE"),
            ),
          ),
          const SizedBox(width: 8),
          popupMenu(),
        }
      ],
    );
  }

  Widget popupMenu() {
    GlobalKey<PopupMenuButtonState<_PopupMenuValue>> key = GlobalKey();

    return PopupMenuButton(
      key: key,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _PopupMenuValue.signout,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).errorColor,
            ),
            title: Text(
              "Sign out",
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: Theme.of(context).errorColor,
                  ),
            ),
          ),
        ),
      ],
      onSelected: (selected) {
        switch (selected) {
          case _PopupMenuValue.signout:
            {
              context.read<AuthenticationService>().signOut();
            }
            break;
        }
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(100),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).primaryColor,
        child: InkWell(
          onTap: () {
            key.currentState!.showButtonMenu();
          },
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.menu_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  List<String> reportOption = [
    "Suspicious or spam",
    "They're pretending to be me or someone else",
    "Often create fake event",
  ]..sort();

  Future<void> showReportDialog() {
    int? selectedReport;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Report user"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: selectedReport != null
                      ? () {
                          context.read<CloudFirestoreService>().addReport(
                                report: Report.user(
                                  id: widget.user.id!,
                                  reason: reportOption[selectedReport!],
                                ),
                              );
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text("Submit"),
                ),
              ],
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < reportOption.length; i++) ...{
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Radio<int>(
                        value: i,
                        groupValue: selectedReport,
                        onChanged: (int? value) {
                          setState(() {
                            selectedReport = value;
                          });
                        },
                      ),
                      title: Text(
                        reportOption[i],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headline1!.color,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedReport = i;
                        });
                      },
                    ),
                  }
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          userData(),
          const SizedBox(height: 16),
          userMenu(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
