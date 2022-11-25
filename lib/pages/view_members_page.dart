import 'package:flutter/material.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/search_user_card.dart';
import 'package:letsmeet/models/user.dart';
import 'package:provider/provider.dart';

class ViewMembersPage extends StatefulWidget {
  final List<User> listMember;
  const ViewMembersPage({super.key, required this.listMember});

  @override
  State<ViewMembersPage> createState() => _ViewMembersPageState();
}

class _ViewMembersPageState extends State<ViewMembersPage> {
  TextEditingController searchBarController = TextEditingController();
  FocusNode searchBarNode = FocusNode();
  List<User> searchResult = [];

  void viewUserProfile(User member) {
    User? user = context.read<User?>();
    context
        .read<GlobalKey<NavigatorState>>()
        .currentState!
        .pushNamed("/profile", arguments: {
      "userId": member.id,
      "isOtherUser": user!.id != member.id,
    });
  }

  @override
  void initState() {
    super.initState();
    searchResult = widget.listMember;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
      ),
      body: GestureDetector(
        onTap: () {
          searchBarNode.unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: InputField(
                controller: searchBarController,
                focusNode: searchBarNode,
                icon: const Icon(
                  Icons.search_rounded,
                ),
                hintText: "Search by name",
                onChanged: (value) {
                  setState(() {
                    String searchText = searchBarController.text.trim();
                    if (searchText.isEmpty) {
                      searchResult = widget.listMember;
                    } else {
                      List<User> result = widget.listMember
                          .where((member) => member.searchIndex
                              .contains(searchBarController.text.trim()))
                          .toList();

                      searchResult = result;
                    }
                  });
                },
                onClear: () {},
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: searchResult.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    child: SearchUserCard(
                      user: searchResult[index],
                      onPressed: () => viewUserProfile(searchResult[index]),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
