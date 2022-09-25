import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/theme_provider.dart';
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
  chooseTheme,
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

  Widget ratingBar({String title = "", int value = 0, int max = 100}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline2,
          ),
          const SizedBox(width: 8),
          Flexible(
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
        ],
      ),
    );
  }

  void showRatingDetail() async {
    UserRating rating = widget.user.rating;
    double avgRating = rating.average();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Ratings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
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
                  const SizedBox(height: 8),
                  Text(
                    "(${rating.amount()})",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (MapEntry<String, int> rate
                      in rating.reverseMap().entries) ...{
                    ratingBar(
                      title: rate.key,
                      value: rate.value,
                      max: rating.max(),
                    ),
                  },
                ],
              ),
            ],
          ),
        );
      },
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
            double ratingAvg = widget.user.rating.average();
            int ratingAmount = widget.user.rating.amount();

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
                      if (widget.user.bio.isNotEmpty) ...{
                        Text(
                          widget.user.bio,
                          style: Theme.of(context).textTheme.bodyText1,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      },
                      if (favCategory.isNotEmpty) ...{
                        Row(
                          children: [
                            Text(
                              "Interests :",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (Category category in favCategory) ...{
                                      Icon(category.icon),
                                      const SizedBox(width: 8),
                                    }
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      },
                      GestureDetector(
                        onTap: () {
                          showRatingDetail();
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              "Rating :",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            for (int i = 1; i < 6; i++) ...{
                              Icon(
                                i <= ratingAvg
                                    ? Icons.star_rounded
                                    : ratingAvg.round() == i
                                        ? Icons.star_half_rounded
                                        : Icons.star_border_rounded,
                                color: Theme.of(context)
                                    .extension<LetsMeetColor>()!
                                    .rating,
                              ),
                            },
                            Text(
                              "($ratingAmount)",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
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
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onEditPressed,
            child: const Text("EDIT PROFILE"),
          ),
        ),
        const SizedBox(width: 8),
        popupMenu(),
      ],
    );
  }

  void chooseThemeDialog() async {
    List themes = [
      {"title": "Light", "value": ThemeMode.light},
      {"title": "Dark", "value": ThemeMode.dark},
      {"title": "System default", "value": ThemeMode.system},
    ];
    ThemeProvider themeProvider = context.read<ThemeProvider>();
    ThemeMode? selectedThemeMode = themeProvider.mode;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Choose theme"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...themes.map((theme) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Radio<ThemeMode>(
                        value: theme["value"],
                        groupValue: selectedThemeMode,
                        onChanged: (ThemeMode? mode) {
                          setState(() {
                            selectedThemeMode = mode;
                          });
                        },
                      ),
                      title: Text(theme["title"]),
                      onTap: () {
                        setState(() {
                          selectedThemeMode = theme["value"];
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(0),
                    elevation: 0,
                  ),
                  child: const Text("Ok"),
                  onPressed: () async {
                    themeProvider.mode = selectedThemeMode!;

                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget popupMenu() {
    GlobalKey<PopupMenuButtonState<_PopupMenuValue>> key = GlobalKey();

    return PopupMenuButton(
      key: key,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _PopupMenuValue.chooseTheme,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.palette_rounded,
              color: Theme.of(context).textTheme.headline1!.color,
            ),
            title: Text(
              "Choose theme",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
        ),
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
          case _PopupMenuValue.chooseTheme:
            chooseThemeDialog();
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
          if (!widget.isOtherUser) ...{
            userMenu(),
            const SizedBox(height: 16),
          },
        ],
      ),
    );
  }
}
