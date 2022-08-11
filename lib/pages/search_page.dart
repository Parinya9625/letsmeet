import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/search_event_card.dart';
import 'package:letsmeet/components/search_user_card.dart';
import 'package:letsmeet/components/search_filter_category.dart';
import 'package:letsmeet/components/search_filter_date.dart';
import 'package:letsmeet/components/search_filter_type.dart';
import 'package:letsmeet/components/search_filter_mode.dart';
import 'package:letsmeet/components/controllers/search_filter_controller.dart';
import 'package:letsmeet/components/no_event_banner.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';

class SearchPage extends StatefulWidget {
  final StateSetter globalSetState;
  final SearchFilterController? searchFilter;

  const SearchPage({
    Key? key,
    required this.globalSetState,
    this.searchFilter,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  TextEditingController searchBarController = TextEditingController();
  String currentSearchText = "";
  FocusNode searchBarNode = FocusNode();
  late SearchFilterController searchFilterController;
  bool showBottomNavigationBar = true;

  ScrollController resultScrollController = ScrollController();
  List<QueryDocumentSnapshot>? searchResult;
  Query? searchQuery;
  bool isLoading = false;

  Query genSearchQuery({QueryDocumentSnapshot? lastDocument}) {
    Query? query;

    if (searchFilterController.mode == "Event") {
      query = FirebaseFirestore.instance.collection("events");

      // date filter
      if (searchFilterController.dateRange != null) {
        query = query.where(
          "startTime",
          isGreaterThanOrEqualTo: searchFilterController.dateRange!.start,
          isLessThanOrEqualTo: searchFilterController.dateRange!.end,
        );
      }

      // category filter
      if (searchFilterController.category != null) {
        query = query.where("category",
            isEqualTo: searchFilterController.category!.toDocRef());
      }

      // type filter
      if (searchFilterController.type != null) {
        query = query.where("type", isEqualTo: searchFilterController.type!);
      }

      // search word
      if (currentSearchText.trim().isNotEmpty) {
        query = query.where("searchIndex",
            arrayContainsAny:
                currentSearchText.trim().toLowerCase().split(" "));
      }

      query = query.orderBy("startTime", descending: true);
    } else if (searchFilterController.mode == "User") {
      query = FirebaseFirestore.instance.collection("users");

      // search word
      if (currentSearchText.trim().isNotEmpty) {
        query = query.where("searchIndex",
            arrayContainsAny:
                currentSearchText.trim().toLowerCase().split(" "));
      }

      query = query.orderBy("createdTime", descending: true);
    }

    if (lastDocument != null) {
      query = query!.startAfterDocument(lastDocument);
    }

    query = query!.limit(10);

    return query;
  }

  void search() {
    if (!isLoading) {
      isLoading = true;

      searchQuery?.get().then((docSnap) {
        if (docSnap.docs.isNotEmpty) {
          searchQuery = genSearchQuery(
            lastDocument: docSnap.docs.last,
          );
        } else {
          searchQuery = null;
        }

        setState(() {
          if (searchResult == null) {
            searchResult = docSnap.docs;
          } else {
            searchResult!.addAll(docSnap.docs);
          }

          isLoading = false;
        });
      });
    }
  }

  void newSearch() {
    setState(() {
      isLoading = false;
      currentSearchText = searchBarController.text.trim();
      searchResult = null;
      searchQuery = genSearchQuery();
      search();
    });
  }

  Widget topSection() {
    return Wrap(
      runSpacing: 16,
      children: [
        // search bar
        InputField(
          controller: searchBarController,
          focusNode: searchBarNode,
          icon: const Icon(
            Icons.search_rounded,
          ),
          hintText: "Search by name, location",
          onSubmitted: (value) {
            setState(() {
              newSearch();
            });
          },
          onClear: () {},
        ).horizontalPadding(),

        // filter
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 8,
                    children: [
                      ModeSearchFilter(
                        controller: searchFilterController,
                        onOpen: () {
                          widget.globalSetState(() {
                            showBottomNavigationBar = false;
                          });
                        },
                        onClose: () {
                          widget.globalSetState(() {
                            showBottomNavigationBar = true;
                          });
                        },
                        onApply: () {
                          newSearch();
                        },
                      ),
                      Visibility(
                        visible: searchFilterController.mode == "Event",
                        child: DateSearchFilter(
                          controller: searchFilterController,
                          onOpen: () {
                            widget.globalSetState(() {
                              showBottomNavigationBar = false;
                            });
                          },
                          onClose: () {
                            widget.globalSetState(() {
                              showBottomNavigationBar = true;
                            });
                          },
                          onApply: () {
                            newSearch();
                          },
                        ),
                      ),
                      Visibility(
                        visible: searchFilterController.mode == "Event",
                        child: CategorySearchFilter(
                          controller: searchFilterController,
                          onOpen: () {
                            widget.globalSetState(() {
                              showBottomNavigationBar = false;
                            });
                          },
                          onClose: () {
                            widget.globalSetState(() {
                              showBottomNavigationBar = true;
                            });
                          },
                          onApply: () {
                            newSearch();
                          },
                        ),
                      ),
                      Visibility(
                        visible: searchFilterController.mode == "Event",
                        child: TypeSearchFilter(
                          controller: searchFilterController,
                          onOpen: () {
                            widget.globalSetState(() {
                              showBottomNavigationBar = false;
                            });
                          },
                          onClose: () {
                            widget.globalSetState(() {
                              showBottomNavigationBar = true;
                            });
                          },
                          onApply: () {
                            newSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                ).horizontalPadding(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget resultSection() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () {
          newSearch();

          return Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: resultScrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 48 + kBottomNavigationBarHeight,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    children: [
                      if (searchResult != null) ...{
                        if (searchResult!.isEmpty) ...{
                          NoEventBanner(
                            onPressed: () {
                              newSearch();
                            },
                          ),
                        } else ...{
                          if (searchFilterController.mode == "Event") ...{
                            ...searchResult!.map(
                              (doc) {
                                Event event = Event.fromFirestore(doc: doc);
                                return SearchEventCard(
                                  event: event,
                                  onPressed: () {
                                    context
                                        .read<GlobalKey<NavigatorState>>()
                                        .currentState!
                                        .pushNamed(
                                          "/event",
                                          arguments: event,
                                        );
                                  },
                                );
                              },
                            ).toList(),
                          } else if (searchFilterController.mode == "User") ...{
                            ...searchResult!.map(
                              (doc) {
                                User? me = context.read<User?>();
                                User user = User.fromFirestore(doc: doc);
                                return SearchUserCard(
                                  user: user,
                                  onPressed: () {
                                    context
                                        .read<GlobalKey<NavigatorState>>()
                                        .currentState!
                                        .pushNamed("/profile", arguments: {
                                      "userId": user.id,
                                      "isOtherUser": user.id != me!.id,
                                    });
                                  },
                                );
                              },
                            ).toList(),
                          }
                        }
                      },
                      if (isLoading && searchQuery != null) ...{
                        const CircularProgressIndicator(),
                      },
                    ],
                  ).horizontalPadding(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    searchFilterController = widget.searchFilter ?? SearchFilterController();

    if (widget.searchFilter != null) {
      newSearch();
    }

    resultScrollController.addListener(() {
      int scrollEnd = resultScrollController.position.maxScrollExtent.toInt();
      if (resultScrollController.position.pixels.toInt() >= scrollEnd) {
        if (!isLoading) {
          search();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        searchBarNode.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topSection(),
                resultSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension PaddingEx on Widget {
  Widget horizontalPadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: this,
    );
  }
}
