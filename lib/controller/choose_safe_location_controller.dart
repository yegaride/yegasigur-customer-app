// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:developer';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:pinput/pinput.dart';

class ChooseSafeLocationController extends GetxController {
  LatLng currentLocation = const LatLng(12.515828146386, -70.035369805992);

  final TextEditingController searchLocationController = TextEditingController();
  GoogleMapController? mapController;

  Future<PlacesDetailsResponse?> placesPredictionAPI(BuildContext context) async {
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: Constant.kGoogleApiKey,
      language: Preferences.getString(Preferences.languageCodeKey),
      mode: Mode.overlay,
      onError: (response) {
        log("-->${response.status}");
      },
      resultTextStyle: Theme.of(context).textTheme.titleMedium,
      types: [],
      strictbounds: false,
      components: [],
    );

    return displayPrediction(prediction);
  }

  Future<PlacesDetailsResponse?> displayPrediction(Prediction? prediction) async {
    if (prediction == null) return null;

    if (searchLocationController.length > 0) {
      searchLocationController.text = 'Loading...';
    }

    GoogleMapsPlaces? places = GoogleMapsPlaces(
      apiKey: Constant.kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse? detail = await places.getDetailsByPlaceId(prediction.placeId.toString());

    return detail;
  }

  void animateCameraToSearchedLocation(LatLng searchedLocation) async {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: searchedLocation,
          zoom: 14,
        ),
      ),
    );
    update();
  }

  Future<void> saveSafeLocation() async {
    Map<String, dynamic> safeLocation = {
      'user_id': Preferences.getInt(Preferences.userId).toString(),
      'lat': currentLocation.latitude,
      'lng': currentLocation.longitude,
    };

    await http.patch(
      Uri.parse(API.setSafeLocation),
      headers: API.header,
      body: jsonEncode(safeLocation),
    );
  }
}
