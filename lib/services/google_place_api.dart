import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class GooglePlaceAPI {
  final String apiKey;

  GooglePlaceAPI({required this.apiKey});

  Future<PlacesAutocompleteResponse> autocomplete({
    required String input,
  }) async {
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?";
    String parameters = "input=$input&key=$apiKey";

    Uri url = Uri.parse(baseUrl + parameters);
    var response = await http.get(url);

    return PlacesAutocompleteResponse.fromResponse(response: response);
  }

  Future<PlacesDetailsResponse> placeDetail({required String placeId}) async {
    String baseUrl = "https://maps.googleapis.com/maps/api/place/details/json?";
    String parameters =
        "place_id=$placeId&fields=geometry,name,formatted_address,place_id&key=$apiKey";

    Uri url = Uri.parse(baseUrl + parameters);
    var response = await http.get(url);

    return PlacesDetailsResponse.fromResponse(response: response);
  }

  Future<ReverseGeocodingResponse> reverseGeo({
    required double lat,
    required double lng,
  }) async {
    String baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?";
    String parameters = "latlng=$lat,$lng&key=$apiKey";

    Uri url = Uri.parse(baseUrl + parameters);
    var response = await http.get(url);

    return ReverseGeocodingResponse.fromResponse(response: response);
  }
}

class ReverseGeocodingResponse {
  final List<ReverseGeocoding> result;
  final String status;

  ReverseGeocodingResponse({
    required this.result,
    required this.status,
  });

  factory ReverseGeocodingResponse.fromResponse({required Response response}) {
    var json = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List<dynamic> result = json["results"];

    return ReverseGeocodingResponse(
      status: json["status"],
      result: result
          .map(
            (place) => ReverseGeocoding(
              placeId: place["place_id"],
              formattedAddress: place["formatted_address"],
              geometry: Geometry(
                location: LatLngLiteral(
                  lat: place["geometry"]["location"]["lat"],
                  lng: place["geometry"]["location"]["lng"],
                ),
                viewport: Bounds(
                  northease: LatLngLiteral(
                    lat: place["geometry"]["viewport"]["northeast"]["lat"],
                    lng: place["geometry"]["viewport"]["northeast"]["lng"],
                  ),
                  southwest: LatLngLiteral(
                    lat: place["geometry"]["viewport"]["southwest"]["lat"],
                    lng: place["geometry"]["viewport"]["southwest"]["lng"],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ReverseGeocoding {
  final String placeId;
  final String formattedAddress;
  final Geometry geometry;

  ReverseGeocoding({
    required this.placeId,
    required this.formattedAddress,
    required this.geometry,
  });
}

// -----------------------

class PlacesAutocompleteResponse {
  final List<PlaceAutocompletePrediction> predictions;
  final String status;

  PlacesAutocompleteResponse({
    required this.predictions,
    required this.status,
  });

  factory PlacesAutocompleteResponse.fromResponse(
      {required Response response}) {
    var json = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List<dynamic> predictions = json["predictions"];

    return PlacesAutocompleteResponse(
      predictions: predictions
          .map((place) => PlaceAutocompletePrediction(
                description: place["description"],
                matchedSubstrings: (place["matched_substrings"] as List)
                    .map((substring) => PlaceAutocompleteMatchedSubstring(
                          length: substring["length"],
                          offset: substring["offset"],
                        ))
                    .toList(),
                structuredFormatting: "structured_formatting",
                terms: (place["terms"] as List)
                    .map((term) => PlaceAutocompleteTerm(
                          offset: term["offset"],
                          value: term["value"],
                        ))
                    .toList(),
                placeId: place["place_id"],
                types: List<String>.from(place["types"] ?? []),
              ))
          .toList(),
      status: json["status"],
    );
  }
}

class PlaceAutocompletePrediction {
  final String description;
  final List<PlaceAutocompleteMatchedSubstring> matchedSubstrings;
  final String structuredFormatting;
  final List<PlaceAutocompleteTerm> terms;
  final String placeId;
  final List<String> types;

  PlaceAutocompletePrediction({
    required this.description,
    required this.matchedSubstrings,
    required this.structuredFormatting,
    required this.terms,
    required this.placeId,
    required this.types,
  });
}

class PlaceAutocompleteMatchedSubstring {
  final int length;
  final int offset;

  PlaceAutocompleteMatchedSubstring({
    required this.length,
    required this.offset,
  });
}

class PlaceAutocompleteTerm {
  final int offset;
  final String value;

  PlaceAutocompleteTerm({
    required this.offset,
    required this.value,
  });
}

class PlacesDetailsResponse {
  final List<String> htmlAttributions;
  final Place result;
  final String status;

  PlacesDetailsResponse({
    required this.htmlAttributions,
    required this.result,
    required this.status,
  });

  factory PlacesDetailsResponse.fromResponse({required Response response}) {
    var json = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var result = json["result"] as Map;

    return PlacesDetailsResponse(
      htmlAttributions: List<String>.from(json["html_attributions"]),
      result: Place(
        placeId: result["place_id"],
        name: result["name"],
        formattedAddress: result["formatted_address"],
        geometry: Geometry(
          location: LatLngLiteral(
            lat: result["geometry"]["location"]["lat"],
            lng: result["geometry"]["location"]["lng"],
          ),
          viewport: Bounds(
            northease: LatLngLiteral(
              lat: result["geometry"]["viewport"]["northeast"]["lat"],
              lng: result["geometry"]["viewport"]["northeast"]["lng"],
            ),
            southwest: LatLngLiteral(
              lat: result["geometry"]["viewport"]["southwest"]["lat"],
              lng: result["geometry"]["viewport"]["southwest"]["lng"],
            ),
          ),
        ),
      ),
      status: json["status"],
    );
  }
}

class Place {
  final String placeId;
  final String name;
  final String formattedAddress;
  final Geometry geometry;

  Place({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.geometry,
  });
}

class Geometry {
  final LatLngLiteral location;
  final Bounds viewport;

  Geometry({
    required this.location,
    required this.viewport,
  });
}

class LatLngLiteral {
  final double lat;
  final double lng;

  LatLngLiteral({
    required this.lat,
    required this.lng,
  });
}

class Bounds {
  final LatLngLiteral northease;
  final LatLngLiteral southwest;

  Bounds({
    required this.northease,
    required this.southwest,
  });
}
