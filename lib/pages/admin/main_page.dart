import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letsmeet/pages/admin/users_page.dart';
import 'package:letsmeet/pages/admin/events_page.dart';
import 'package:letsmeet/pages/admin/roles_page.dart';
import 'package:letsmeet/pages/admin/categories_page.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/theme_provider.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/components/admin/responsive_layout.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final navigatorKey = GlobalKey<NavigatorState>();
  User? user;
  List<Role> listRole = [];
  String selectedPath = "/users";
  List<String> pathName = ["/users", "/events", "/categories", "/roles"];
  List<Map<String, dynamic>> menus = [
    {"path": "/users", "icon": Icons.person_rounded, "label": "Users"},
    {"path": "/events", "icon": Icons.event_rounded, "label": "Events"},
    {
      "path": "/categories",
      "icon": Icons.category_rounded,
      "label": "Categories"
    },
    {"path": "/roles", "icon": Icons.manage_accounts_rounded, "label": "Roles"},
  ];

  Color? isSelectedPath(String name) {
    if (name == selectedPath) {
      return Theme.of(context).primaryColor;
    }
    return null;
  }

  Widget headerPlaceholder() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 128,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 48,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget profileHeader() {
    return ShimmerLoading(
      isLoading: user == null || listRole.isEmpty,
      placeholder: headerPlaceholder(),
      builder: (BuildContext context) {
        Role role = listRole.firstWhere((role) => role.id == user?.role.id,
            orElse: () => Role.create(
                  name: "",
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  permission: UserPermission(),
                ));

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: user!.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user!.image,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user?.name} ${user?.surname}",
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Badge(
                    title: role.name,
                    backgroundColor: role.backgroundColor,
                    foregroundColor: role.foregroundColor,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> drawerMenu() {
    return menus
        .map(
          (menu) => drawerButton(
            foregroundColor: isSelectedPath(menu["path"]),
            icon: menu["icon"],
            label: menu["label"],
            onPressed: () {
              setState(() {
                selectedPath = menu["path"];
                navigatorKey.currentState!.pushNamed(menu["path"]);
              });
            },
          ),
        )
        .toList();
  }

  Widget drawerButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? foregroundColor,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(24),
        foregroundColor:
            foregroundColor ?? Theme.of(context).textTheme.bodyText1!.color,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 24),
          Text(label),
        ],
      ),
    );
  }

  Color? isSelectedTheme(ThemeMode current, ThemeMode mode) {
    return current == mode ? Theme.of(context).primaryColor : null;
  }

  Widget chooseThemeButton() {
    GlobalKey<PopupMenuButtonState<ThemeMode>> key = GlobalKey();
    ThemeProvider themeProvider = context.read<ThemeProvider>();
    ThemeMode currentThemeMode = themeProvider.mode;

    return PopupMenuButton(
      key: key,
      enabled: false,
      position: PopupMenuPosition.over,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.light_mode_rounded,
              color: isSelectedTheme(currentThemeMode, ThemeMode.light),
            ),
            title: Text(
              "Light",
              style: TextStyle(
                color: isSelectedTheme(currentThemeMode, ThemeMode.light),
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.dark_mode_rounded,
              color: isSelectedTheme(currentThemeMode, ThemeMode.dark),
            ),
            title: Text(
              "Dark",
              style: TextStyle(
                color: isSelectedTheme(currentThemeMode, ThemeMode.dark),
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.settings_suggest_rounded,
              color: isSelectedTheme(currentThemeMode, ThemeMode.system),
            ),
            title: Text(
              "System",
              style: TextStyle(
                color: isSelectedTheme(currentThemeMode, ThemeMode.system),
              ),
            ),
          ),
        ),
      ],
      onSelected: (ThemeMode newMode) {
        setState(() {
          themeProvider.mode = newMode;
        });
      },
      child: ResponsiveLayout(
        extraLarge: drawerButton(
          icon: Icons.palette_rounded,
          label: "Choose theme",
          onPressed: () {
            key.currentState!.showButtonMenu();
          },
        ),
        medium: IconButton(
          icon: const Icon(Icons.palette_rounded),
          color:
              Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.65),
          onPressed: () {
            key.currentState!.showButtonMenu();
          },
        ),
      ),
    );
  }

  Widget appDrawer() {
    return ResponsiveLayout(
      extraLarge: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // user header
              profileHeader(),

              // menu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      runSpacing: 16,
                      children: drawerMenu(),
                    ),
                  ),
                ),
              ),

              // Change theme
              chooseThemeButton(),
              const SizedBox(height: 16),

              // sign out
              drawerButton(
                icon: Icons.logout_rounded,
                label: "Sign out",
                foregroundColor: Theme.of(context).errorColor,
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                },
              ),
            ],
          ),
        ),
      ),
      medium: NavigationRail(
        selectedIndex: pathName.indexOf(selectedPath),
        labelType: NavigationRailLabelType.selected,
        leading: ShimmerLoading(
          isLoading: user == null,
          placeholder: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: user!.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user!.image,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                      )
                    : null,
              ),
            );
          },
        ),
        trailing: Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chooseThemeButton(),
                  const SizedBox(height: 32),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    color: Theme.of(context).errorColor,
                    onPressed: () {
                      context.read<AuthenticationService>().signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        onDestinationSelected: (int index) {
          setState(() {
            selectedPath = pathName[index];
            navigatorKey.currentState!.pushNamed(pathName[index]);
          });
        },
        destinations: menus
            .map((menu) => NavigationRailDestination(
                  icon: Icon(
                    menu["icon"],
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                  selectedIcon: Icon(
                    menu["icon"],
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    menu["label"],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<User?>();
    listRole = context.watch<List<Role>?>() ?? [];

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appDrawer(),
          Expanded(
            child: Navigator(
                key: navigatorKey,
                initialRoute: "/users",
                onGenerateRoute: (settings) {
                  Widget? page;
                  switch (settings.name) {
                    case "/users":
                      page = const UsersPage();
                      break;
                    case "/events":
                      page = const EventsPage();
                      break;
                    case "/categories":
                      page = const CategoriesPage();
                      break;
                    case "/roles":
                      page = const RolesPage();
                      break;
                    default:
                      page = TempPage(
                        title: "${settings.name}",
                      );
                  }

                  return RouteTransition(page);
                }),
          ),
        ],
      ),
    );
  }
}

class RouteTransition extends PageRoute {
  final Widget child;
  RouteTransition(this.child);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

class TempPage extends StatefulWidget {
  final String title;
  const TempPage({Key? key, required this.title}) : super(key: key);

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(widget.title),
          ],
        ),
      ),
    );
  }
}
