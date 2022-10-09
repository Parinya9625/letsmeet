// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/all.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/storage.dart';
import 'package:provider/provider.dart';

class CreateEditEventPage extends StatefulWidget {
  final Event? event;

  const CreateEditEventPage({Key? key, this.event}) : super(key: key);

  @override
  State<CreateEditEventPage> createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController typeController = TextEditingController();
  LocationPickerController locationController = LocationPickerController();
  Category? category;
  TextEditingController categoryController = TextEditingController();
  ImagePickerController imageController = ImagePickerController();
  TextEditingController nameController = TextEditingController();
  DateTime? date;
  TextEditingController dateController = TextEditingController();
  TimeOfDay? time;
  TextEditingController timeController = TextEditingController();
  TextEditingController maxPeopleController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  CheckboxTileController limitController = CheckboxTileController();
  TextEditingController urlController = TextEditingController();

  final imageKey = GlobalKey<ImageCoverPickerState>();
  final locationKey = GlobalKey<LocationPickerState>();
  List<Category> listCategory = [];
  Stream<List<Event>>? stream;

  void selectBase({required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              child,
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void selectEventType() {
    List<Map<String, dynamic>> optionList = [
      {"name": "In Person", "icon": Icons.group_rounded, "value": "In Person"},
      {"name": "Online", "icon": Icons.videocam_rounded, "value": "Online"},
    ];

    Widget typeOptionButton({
      VoidCallback? onPressed,
      required IconData icon,
      String? text,
      bool isSelected = false,
    }) {
      return Material(
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                const SizedBox(height: 8),
                Text(
                  text.toString(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                )
              ],
            ),
          ),
        ),
      );
    }

    selectBase(
      title: "Type",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: optionList
            .map(
              (option) => typeOptionButton(
                text: option["name"],
                icon: option["icon"],
                isSelected: typeController.text == option["value"],
                onPressed: () {
                  setState(() {
                    typeController.text = option["value"];
                    Navigator.pop(context);
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void selectCategory() {
    Widget categoryOptionButton({
      VoidCallback? onPressed,
      required IconData icon,
      String? text,
      bool isSelected = false,
    }) {
      return Material(
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                const SizedBox(height: 8),
                Text(
                  text.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                        fontSize: 12,
                      ),
                )
              ],
            ),
          ),
        ),
      );
    }

    selectBase(
      title: "Category",
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        shrinkWrap: true,
        children: listCategory
            .map(
              (cat) => categoryOptionButton(
                text: cat.name,
                icon: cat.icon,
                isSelected: category == cat,
                onPressed: () {
                  setState(() {
                    category = cat;
                    categoryController.text = category!.name;
                    Navigator.pop(context);
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (selectedDate != null) {
      setState(() {
        date = selectedDate;
        dateController.text = DateFormat("EEE, dd MMM y").format(date!);
      });
    }
  }

  void selectTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        time = selectedTime;
        timeController.text =
            "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void showLoading() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _showSuggestion = false;
  String? _sugType;
  String? _sugPlaceId;
  Category? _sugCategory;
  void checkSuggest() {
    if (typeController.text.trim() == "In Person" &&
        locationController.placeId != null &&
        category != null &&
        widget.event == null) {
      if (typeController.text.trim() != _sugType ||
          locationController.placeId != _sugPlaceId ||
          category != _sugCategory) {
        setState(() {
          _showSuggestion = true;
        });
      }
    } else {
      setState(() {
        _showSuggestion = false;
      });
    }
    _sugType = typeController.text.trim();
    _sugPlaceId = locationController.placeId;
    _sugCategory = category;
  }

  @override
  void initState() {
    if (widget.event != null) {
      typeController.text = widget.event!.type;
      if (typeController.text.trim() == "In Person") {
        locationController.placeId = widget.event!.location.placeId;
        locationController.name = widget.event!.location.name;
        locationController.lat = widget.event!.location.geoPoint!.latitude;
        locationController.lng = widget.event!.location.geoPoint!.longitude;
      } else if (typeController.text.trim() == "Online") {
        urlController.text = widget.event!.location.link!;
      }

      List<Category> listCategory = context.read<List<Category>>();
      if (listCategory.isEmpty) {
        // Fix listCategory is empty when first time launch this page
        widget.event!.getCategory.then((cat) {
          category = cat;
          categoryController.text = category!.name;
        });
      } else {
        category = listCategory
            .firstWhere((cat) => cat.id == widget.event!.category.id);
        categoryController.text = category!.name;
      }

      imageController.url = widget.event!.image;
      nameController.text = widget.event!.name;
      date = widget.event!.startTime;
      dateController.text = DateFormat("EEE, dd MMM y").format(date!);
      time = TimeOfDay(
          hour: widget.event!.startTime.hour,
          minute: widget.event!.startTime.minute);
      timeController.text =
          "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
      maxPeopleController.text = widget.event!.maxMember.toString();
      detailController.text = widget.event!.description;
      limitController.value = widget.event!.ageRestrict;
    }

    typeController.addListener(() {
      checkSuggest();
    });
    locationController.addListener(() {
      checkSuggest();
    });
    categoryController.addListener(() {
      checkSuggest();
    });

    super.initState();
  }

  @override
  void dispose() {
    typeController.removeListener(() {});
    locationController.removeListener(() {});
    categoryController.removeListener(() {});

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listCategory = context.watch<List<Category>>();
    User user = context.watch<User?>()!;

    return Scaffold(
      appBar: AppBar(
        title: widget.event == null
            ? const Text("Create Event")
            : const Text("Edit Event"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            onPressed: () async {
              final formV = formKey.currentState!.validate();
              final imageV = imageKey.currentState!.validate();
              final locationV = typeController.text.trim() == "Online" ||
                  locationKey.currentState!.validate();

              if (formV && imageV && locationV) {
                late Event event;
                late String imageUrl;

                showLoading();

                if (imageController.file != null) {
                  imageUrl = await context.read<StorageService>().uploadImage(
                        userId: user.id!,
                        file: imageController.file!,
                      );
                } else {
                  imageUrl = widget.event!.image;
                }

                if (typeController.text.trim() == "In Person") {
                  event = Event.createInPerson(
                    ageRestrict: limitController.value!,
                    category: category!.toDocRef(),
                    description: detailController.text.trim(),
                    image: imageUrl,
                    placeId: locationController.placeId!,
                    locationName: locationController.name!,
                    geoPoint: GeoPoint(
                        locationController.lat!, locationController.lng!),
                    maxMember: int.parse(maxPeopleController.text.trim()),
                    member: [user.toDocRef()],
                    name: nameController.text.trim(),
                    owner: user.toDocRef(),
                    startTime: DateTime(date!.year, date!.month, date!.day,
                        time!.hour, time!.minute),
                  );
                } else if (typeController.text.trim() == "Online") {
                  event = Event.createOnline(
                    ageRestrict: limitController.value!,
                    category: category!.toDocRef(),
                    description: detailController.text.trim(),
                    image: imageUrl,
                    link: urlController.text.trim(),
                    maxMember: int.parse(maxPeopleController.text.trim()),
                    member: [user.toDocRef()],
                    name: nameController.text.trim(),
                    owner: user.toDocRef(),
                    startTime: DateTime(date!.year, date!.month, date!.day,
                        time!.hour, time!.minute),
                  );
                }

                if (widget.event == null) {
                  context.read<CloudFirestoreService>().addEvent(event: event);
                } else {
                  var updateEvent = event.toMap();
                  updateEvent.remove("id");
                  updateEvent.remove("createdTime");
                  updateEvent.remove("member");
                  updateEvent.remove("memberReviewed");

                  context
                      .read<CloudFirestoreService>()
                      .updateEvent(id: widget.event!.id!, data: updateEvent);
                }

                Navigator.pop(context); // Pop loading screen
                Navigator.pop(context); // Pop create page
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    InputField(
                      controller: typeController,
                      icon: const Icon(Icons.event_rounded),
                      hintText: "Type",
                      readOnly: true,
                      onTap: () => selectEventType(),
                      validator: (value) {
                        if (typeController.text.isEmpty) {
                          return "Please select event type\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: typeController.text.isEmpty ||
                          typeController.text.trim() == "In Person",
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LocationPicker(
                            key: locationKey,
                            controller: locationController,
                            errorText: "Please select event loaction",
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ).horizontalPadding(),
                    InputField(
                      controller: categoryController,
                      icon: const Icon(Icons.category_rounded),
                      hintText: "Category",
                      readOnly: true,
                      onTap: () => selectCategory(),
                      validator: (value) {
                        if (categoryController.text.isEmpty) {
                          return "Please select event category\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: _showSuggestion,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("events")
                            .where("location.placeId",
                                isEqualTo:
                                    typeController.text.trim() == "In Person" &&
                                            locationController.placeId != null
                                        ? locationController.placeId
                                        : "-")
                            .where("category",
                                isEqualTo: category != null
                                    ? category!.toDocRef()
                                    : "-")
                            .where(
                              "startTime",
                              isGreaterThanOrEqualTo: DateTime.now(),
                            )
                            .limit(10)
                            .snapshots()
                            .map((events) => events.docs
                                .map((doc) => Event.fromFirestore(doc: doc))
                                .toList()),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          List<Event> listEvent = snapshot.data!;

                          return Visibility(
                            visible: listEvent.isNotEmpty,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Similar events you can join",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close_rounded),
                                      onPressed: () {
                                        setState(() {
                                          _showSuggestion = false;
                                        });
                                      },
                                    ),
                                  ],
                                ).horizontalPadding(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics(),
                                        ),
                                        scrollDirection: Axis.horizontal,
                                        child: Wrap(
                                          direction: Axis.horizontal,
                                          spacing: 8,
                                          children: [
                                            const SizedBox(width: 32),
                                            ...listEvent
                                                .map(
                                                  (event) => EventCard(
                                                    event: event,
                                                    isSmall: true,
                                                    onPressed: () {
                                                      // tap event card
                                                      context
                                                          .read<
                                                              GlobalKey<
                                                                  NavigatorState>>()
                                                          .currentState!
                                                          .pushNamed(
                                                            "/event",
                                                            arguments: event,
                                                          );
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                            const SizedBox(width: 32),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    ImageCoverPicker(
                      key: imageKey,
                      controller: imageController,
                      errorText: "Please select event image cover",
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    InputField(
                      controller: nameController,
                      icon: const Icon(Icons.event_note_rounded),
                      hintText: "Name",
                      maxLength: 100,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      onClear: () {
                        nameController.clear();
                      },
                      validator: (value) {
                        if (nameController.text.trim().isEmpty) {
                          return "Please enter event name\n";
                        } else if (nameController.text.trim().length > 100) {
                          return "Name exceeds the maximum length\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    InputField(
                      controller: dateController,
                      icon: const Icon(Icons.date_range_rounded),
                      hintText: "Date",
                      readOnly: true,
                      onTap: () => selectDate(),
                      validator: (value) {
                        if (dateController.text.isEmpty) {
                          return "Please select event start date\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    InputField(
                      controller: timeController,
                      icon: const Icon(Icons.schedule_rounded),
                      hintText: "Time",
                      readOnly: true,
                      onTap: () => selectTime(),
                      validator: (value) {
                        if (timeController.text.isEmpty) {
                          return "Please select event start time\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    InputField(
                      controller: maxPeopleController,
                      icon: const Icon(Icons.group_rounded),
                      hintText: "Maximum people",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (maxPeopleController.text.trim().isEmpty) {
                          return "Please enter maximum people that can join this event\n";
                        } else if (int.parse(maxPeopleController.text.trim()) <=
                            1) {
                          return "Minimun people for create event is 2\n";
                        } else if (int.parse(maxPeopleController.text.trim()) >=
                            10000) {
                          return "Maximum people for create event is 10,000\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: typeController.text.trim() == "Online",
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InputField(
                            controller: urlController,
                            icon: const Icon(Icons.language_rounded),
                            hintText: "Url",
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (typeController.text.trim() == "Online") {
                                RegExp urlPattern = RegExp(
                                    r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");

                                if (urlController.text.trim().isEmpty) {
                                  return "Please enter event url\n";
                                } else if (!urlPattern
                                    .hasMatch(urlController.text.trim())) {
                                  return "Url must start with http:// or https://\n";
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ).horizontalPadding(),
                    InputField(
                      controller: detailController,
                      icon: const Icon(Icons.notes_rounded),
                      hintText: "Detail",
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 50,
                      maxLength: 500,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      validator: (value) {
                        if (detailController.text.trim().length > 500) {
                          return "Detail exceeds the maximum length\n";
                        }
                        return null;
                      },
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    CheckboxTile(
                      controller: limitController,
                      title: const Text("Limit for people over 20 years"),
                    ).horizontalPadding(),
                  ],
                ),
              ),
            ],
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
