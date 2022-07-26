import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/pages/home_page.dart';
import 'package:letsmeet/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final navigatorKey = GlobalKey<NavigatorState>();

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

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamed(context, "/event/create");
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Navigator(
        key: navigatorKey,
        initialRoute: "/",
        onGenerateRoute: (settings) {
          // TODO: Update page
          Widget? page;
          switch (settings.name) {
            case "/":
              page = const HomePage();
              break;
            case "/search":
              page = const TempPage(color: Colors.green);
              break;
            case "/chats":
              page = const TempPage(color: Colors.orange);
              break;
            case "/profile":
              setState(() {
                selectedPath = settings.name.toString();
              });
              page = UserProfilePage(userId: user!.id!, isOtherUser: false);
              break;
            default:
              page = const TempPage(color: Colors.black);
          }

          return RouteTransition(page);
        },
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
