import 'package:flutter/material.dart';
import 'package:letsmeet/components/profile_header.dart';
import 'package:letsmeet/models/user.dart';

class UserProfilePage extends StatefulWidget {
  final User user;
  final bool isOtherUser;

  const UserProfilePage({
    Key? key,
    required this.user,
    required this.isOtherUser,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  List<Tab> tabName = const [
    Tab(text: "My Events"),
    Tab(text: "Joined Events"),
  ];
  TabController? controller;

  @override
  void initState() {
    controller =
        TabController(initialIndex: 0, length: tabName.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: ScrollController(),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              pinned: true,
              expandedHeight: 320,
              toolbarHeight: kToolbarHeight,
              forceElevated: true,
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text("${widget.user.name} ${widget.user.surname}"),
              ),
              flexibleSpace: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: FlexibleSpaceBar(
                  background: SafeArea(
                    child: ProfileHeader(
                      user: widget.user,
                      isOtherUser: widget.isOtherUser,
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: controller,
                tabs: tabName,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: controller!,
        children: [
          tabPage(
            id: "id1",
            child: Column(
              children: [
                const Text("Page 1"),
                for (int i = 0; i < 100; i++) ...{
                  Text(i.toString()),
                },
              ],
            ),
          ),
          tabPage(
            id: "id2",
            child: Column(
              children: [
                const Text("Page 2"),
                for (int i = 0; i < 100; i++) ...{
                  Text(i.toString()),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget tabPage({required String id, required Widget child}) {
  return Builder(
    builder: (BuildContext context) {
      return CustomScrollView(
        key: PageStorageKey<String>(id),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(child: child),
        ],
      );
    },
  );
}
