import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letsmeet/components/controllers/location_picker_controller.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/services/google_place_api.dart';
import 'package:location/location.dart';

class LocationPicker extends StatefulWidget {
  final LocationPickerController controller;
  final String? errorText;

  const LocationPicker({Key? key, required this.controller, this.errorText})
      : super(key: key);

  @override
  State<LocationPicker> createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker>
    with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> mapController = Completer();
  Marker? currentMarker;

  Future<void> moveCamera(double lat, double lng) async {
    GoogleMapController controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 16,
        ),
      ),
    );
  }

  void updateMarker(double lat, double lng) {
    setState(() {
      currentMarker = Marker(
        markerId: MarkerId(DateTime.now().toString()),
        position: LatLng(lat, lng),
      );
    });
  }

  void changeLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GoogleMapPage(
          controller: widget.controller,
        ),
      ),
    );
    setState(() {
      moveCamera(widget.controller.lat!, widget.controller.lng!);
      updateMarker(widget.controller.lat!, widget.controller.lng!);
    });
  }

  bool _isValid = true;

  bool validate() {
    setState(() {
      _isValid = widget.controller.placeId != null;
      if (_isValid) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
    return _isValid;
  }

  late AnimationController _animationController;

  @override
  void initState() {
    if (widget.controller.placeId != null) {
      updateMarker(widget.controller.lat!, widget.controller.lng!);
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.place_rounded),
                  ),
                  Expanded(
                    child: Text(
                      widget.controller.name ?? "Select location",
                      style: widget.controller.placeId != null
                          ? Theme.of(context).textTheme.headline1
                          : Theme.of(context).textTheme.headline1!.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            Ink(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => changeLocation(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // With selected place
                      Visibility(
                        visible: widget.controller.placeId != null,
                        child: Expanded(
                          child: AbsorbPointer(
                            absorbing: false,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(widget.controller.lat ?? 0,
                                    widget.controller.lng ?? 0),
                                zoom: 16,
                              ),
                              liteModeEnabled: true,
                              markers:
                                  currentMarker != null ? {currentMarker!} : {},
                              onMapCreated: (GoogleMapController controller) {
                                mapController.complete(controller);
                              },
                              onTap: (LatLng position) => changeLocation(),
                            ),
                          ),
                        ),
                      ),

                      // Empty map
                      if (widget.controller.placeId == null) ...{
                        const Icon(
                          Icons.map_rounded,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select location",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      }
                    ],
                  ),
                ),
              ),
            ),
            if (!_isValid && widget.errorText != null) ...{
              const SizedBox(height: 16),
              Row(
                children: [
                  FadeTransition(
                    opacity: _animationController,
                    child: Text(
                      widget.errorText!,
                      style: Theme.of(context).inputDecorationTheme.errorStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _GoogleMapPage extends StatefulWidget {
  final LocationPickerController controller;
  const _GoogleMapPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<_GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<_GoogleMapPage> {
  // gps
  final Location location = Location();
  // google map controller
  Completer<GoogleMapController> controller = Completer();
  // search bar controller
  TextEditingController searchBarController = TextEditingController();
  // controller search bar focus / unfocus
  FocusNode searchBarNode = FocusNode();
  // check when user stop typing
  Timer? searchOnStoppedTyping = Timer(const Duration(seconds: 0), () {});
  // search result
  List<PlaceAutocompletePrediction> predictions = [];
  // selected search result
  PlacesDetailsResponse? selectedPlace;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(14.0395159, 100.6131706),
    zoom: 14,
  );
  Marker? currentMarker;

  Future<void> moveToCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (serviceEnabled &&
        (permissionGranted == PermissionStatus.granted ||
            permissionGranted == PermissionStatus.grantedLimited)) {
      LocationData data = await location.getLocation();

      moveCamera(LatLng(data.latitude!, data.longitude!));
    }
  }

  Future<void> moveCamera(LatLng latLng) async {
    GoogleMapController mapController = await controller.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 16,
        ),
      ),
    );
  }

  void updateMarker(LatLng position) {
    setState(() {
      currentMarker = Marker(
        markerId: MarkerId(DateTime.now().toString()),
        position: position,
      );
    });
  }

  void onStopTyping(String value) {
    const duration = Duration(milliseconds: 800);

    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel());
    }
    setState(() => searchOnStoppedTyping =
        Timer(duration, () => search(searchBarController.text.trim())));
  }

  Future<List<PlaceAutocompletePrediction>> search(String value) async {
    GooglePlaceAPI placeApi =
        GooglePlaceAPI(apiKey: "AIzaSyCdC0uYq_dqJ1UsNXgWn9NYQjQL4kGNKnM");

    if (value.isNotEmpty) {
      PlacesAutocompleteResponse autocomplete =
          await placeApi.autocomplete(input: value);

      setState(() {
        predictions = autocomplete.predictions;
      });
      return autocomplete.predictions;
    }
    return [];
  }

  void onSelectedPlace(String placeId) async {
    GooglePlaceAPI placeApi =
        GooglePlaceAPI(apiKey: "AIzaSyCdC0uYq_dqJ1UsNXgWn9NYQjQL4kGNKnM");

    PlacesDetailsResponse detail = await placeApi.placeDetail(placeId: placeId);

    moveCamera(LatLng(detail.result.geometry.location.lat,
        detail.result.geometry.location.lng));

    updateMarker(LatLng(detail.result.geometry.location.lat,
        detail.result.geometry.location.lng));

    setState(() {
      selectedPlace = detail;
    });
  }

  void onLongPressed(LatLng position) async {
    GooglePlaceAPI placeApi =
        GooglePlaceAPI(apiKey: "AIzaSyCdC0uYq_dqJ1UsNXgWn9NYQjQL4kGNKnM");

    ReverseGeocodingResponse reverse = await placeApi.reverseGeo(
        lat: position.latitude, lng: position.longitude);

    if (reverse.result.isNotEmpty) {
      ReverseGeocoding place = reverse.result.first;
      onSelectedPlace(place.placeId);
    }
  }

  void onSearchSubmit(String value) async {
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel());
    }

    List<PlaceAutocompletePrediction>? searchResult = await search(value);
    if (searchResult.isNotEmpty) {
      onSelectedPlace(predictions.first.placeId);
    }
  }

  @override
  void initState() {
    if (widget.controller.placeId == null) {
      moveToCurrentLocation();
    } else {
      initPosition = CameraPosition(
        target: LatLng(widget.controller.lat!, widget.controller.lng!),
        zoom: 16,
      );
      updateMarker(LatLng(widget.controller.lat!, widget.controller.lng!));
    }

    searchBarNode.addListener(() {
      if (searchBarNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    searchBarController.dispose();
    searchBarNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (selectedPlace != null) ...{
            IconButton(
              icon: const Icon(Icons.done_rounded),
              tooltip: 'Confirm location',
              onPressed: () {
                widget.controller.placeId = selectedPlace!.result.placeId;
                widget.controller.name = selectedPlace!.result.name;
                widget.controller.lat =
                    selectedPlace!.result.geometry.location.lat;
                widget.controller.lng =
                    selectedPlace!.result.geometry.location.lng;
                Navigator.pop(context);
              },
            ),
          },
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: initPosition,
              myLocationEnabled: true,
              markers: currentMarker != null ? {currentMarker!} : {},
              onMapCreated: (GoogleMapController mapController) {
                controller.complete(mapController);
              },
              onLongPress: onLongPressed,
            ),

            // textfield dismiss area
            Visibility(
              visible: searchBarNode.hasFocus,
              child: Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    searchBarNode.unfocus();
                  },
                ),
              ),
            ),

            // search result
            Visibility(
              visible: searchBarNode.hasFocus,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 64 + 16, 16, 16),
                child: Material(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (PlaceAutocompletePrediction place
                              in predictions) ...{
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.place_rounded),
                                title: Text(place.description),
                                onTap: () {
                                  searchBarController.text = place.description;
                                  searchBarNode.unfocus();

                                  // test
                                  onSelectedPlace(place.placeId);
                                },
                              ),
                            )
                          },
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: InputField(
                controller: searchBarController,
                focusNode: searchBarNode,
                icon: const Icon(Icons.search_rounded),
                hintText: "Search location",
                onClear: () {
                  setState(() {
                    predictions.clear();
                  });
                },
                onChanged: onStopTyping,
                onSubmitted: onSearchSubmit,
              ),
            ),

            // place detail
            Visibility(
              visible: !searchBarNode.hasFocus && selectedPlace != null,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (selectedPlace != null) ...{
                          Text(
                            selectedPlace!.result.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedPlace!.result.formattedAddress,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        },
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
