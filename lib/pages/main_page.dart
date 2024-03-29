import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/pages/chats_page.dart';
import 'package:letsmeet/pages/home_page.dart';
import 'package:letsmeet/pages/search_page.dart';
import 'package:letsmeet/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final searchPageKey = GlobalKey<SearchPageState>();

  String selectedPath = "/";
  Color? isSelectedPath(String name) {
    if (name == selectedPath) {
      return Theme.of(context).primaryColor;
    }
    return null;
  }

  Widget navItem({required String path, required Widget icon}) {
    return IconButton(
      icon: icon,
      color: isSelectedPath(path),
      onPressed: (() {
        setState(() {
          selectedPath = path;
          navigatorKey.currentState!.pushReplacementNamed(path);
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.read<User?>();

    return StatefulBuilder(
      builder: (context, globalSetState) {
        bool isShowBottomNav =
            searchPageKey.currentState?.showBottomNavigationBar ?? true;

        return Scaffold(
          extendBody: true,
          bottomNavigationBar: Visibility(
            visible: isShowBottomNav,
            child: BottomAppBar(
              color: Theme.of(context).cardColor,
              shape: const CircularNotchedRectangle(),
              notchMargin: 6,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    navItem(
                      icon: const Icon(Icons.home),
                      path: "/",
                    ),
                    navItem(
                      icon: const Icon(Icons.search_rounded),
                      path: "/search",
                    ),
                    const SizedBox(width: 64),
                    navItem(
                      icon: const FaIcon(FontAwesomeIcons.comment),
                      path: "/chats",
                    ),
                    navItem(
                      icon: const Icon(Icons.person_rounded),
                      path: "/profile",
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Visibility(
            visible: isShowBottomNav,
            child: FloatingActionButton(
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/event/create");
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: WillPopScope(
            onWillPop: () async {
              // page route not home "/"
              if (selectedPath != "/") {
                // go back to home first
                setState(() {
                  navigatorKey.currentState!.pushReplacementNamed("/");
                  selectedPath = "/";
                });
                return false;
              }
              // if route is home then quit app
              return true;
            },
            child: Navigator(
              key: navigatorKey,
              initialRoute: "/",
              onGenerateRoute: (settings) {
                Widget? page;
                switch (settings.name) {
                  case "/":
                    page = HomePage(
                      navigatorKey: navigatorKey,
                    );
                    break;
                  case "/search":
                    page = SearchPage(
                      key: searchPageKey,
                      globalSetState: globalSetState,
                      searchFilter:
                          settings.arguments as SearchFilterController?,
                    );
                    setState(() {
                      selectedPath = settings.name!;
                    });
                    break;
                  case "/chats":
                    page = const ChatsPage();
                    setState(() {
                      selectedPath = settings.name!;
                    });
                    break;
                  case "/profile":
                    page = UserProfilePage(
                      userId: user!.id!,
                      isOtherUser: false,
                      automaticallyImplyLeading: false,
                    );
                    setState(() {
                      selectedPath = settings.name!;
                    });
                    break;
                  default:
                    page = const TempPage(color: Colors.black);
                }

                return RouteTransition(page);
              },
            ),
          ),
        );
      },
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
  final Color color;
  const TempPage({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color,
      body: Center(child: Text(DateTime.now().toString())),
    );
  }
}
