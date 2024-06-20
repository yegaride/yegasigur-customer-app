// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/my_profile_controller.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/page/auth_screens/add_profile_photo_screen.dart';
import 'package:cabme/page/safe_location/choose_safe_location_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:pinput/pinput.dart';

class ChooseSafeLocationController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isGettingAddress = false.obs;

  @override
  void onInit() {
    super.onInit();

    final data = Constant.getUserData();
    print('$data 👈🏻👈🏻');
    data.data!.safeLocationLat;

    print('${data.data!.safeLocationLat} 👈🏻👈🏻👈🏻');
  }

  // LatLng currentLocation = LatLng(
  //   double.parse(
  //     '12.515828146386',
  //   ),
  //   double.parse(
  //     '-70.035369805992',
  //   ),
  // );

  LatLng currentLocation = LatLng(
    double.parse(
      Constant.getUserData().data!.safeLocationLat! == 'null' ? '12.515828146386' : Constant.getUserData().data!.safeLocationLat!,
    ),
    double.parse(
      Constant.getUserData().data!.safeLocationLng! == 'null'
          ? '-70.035369805992'
          : Constant.getUserData().data!.safeLocationLng!,
    ),
  );

  String addressDecodedFromCoordinates = '';

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

  Future<void> saveSafeLocation({required SavebuttonBehavior savebuttonBehavior}) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> safeLocation = {
        'user_id': Preferences.getInt(Preferences.userId).toString(),
        'lat': currentLocation.latitude,
        'lng': currentLocation.longitude,
        'address': addressDecodedFromCoordinates,
      };

      final response = await http.patch(
        Uri.parse(API.setSafeLocation),
        headers: API.header,
        body: jsonEncode(safeLocation),
      );

      if (response.statusCode == 200) {
        UserModel userModel = Constant.getUserData();

        userModel.data!.address = addressDecodedFromCoordinates;
        userModel.data!.safeLocationLat = currentLocation.latitude.toString();
        userModel.data!.safeLocationLng = currentLocation.longitude.toString();

        Preferences.setString(Preferences.user, jsonEncode(userModel.toJson()));

        if (savebuttonBehavior == SavebuttonBehavior.saveAndBack) {
          ShowToastDialog.showToast('Safe location updated successfully');
          Get.put(MyProfileController()).getUsrData();

          return Get.back();
        }

        Get.to(AddProfilePhotoScreen());
      } else {
        ShowToastDialog.closeLoader();
        // TODO i18n
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Something went wrong try again later');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future getAddressFromLatLng() async {
    isGettingAddress.value = true;

    List<Placemark> placeMarks = await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);

    final address = (placeMarks.first.subLocality!.isEmpty ? '' : "${placeMarks.first.subLocality}") +
        (placeMarks.first.street!.isEmpty ? '' : ", ${placeMarks.first.street}") +
        (placeMarks.first.name!.isEmpty ? '' : ", ${placeMarks.first.name}") +
        (placeMarks.first.subAdministrativeArea!.isEmpty ? '' : ", ${placeMarks.first.subAdministrativeArea}") +
        (placeMarks.first.administrativeArea!.isEmpty ? '' : ", ${placeMarks.first.administrativeArea}") +
        (placeMarks.first.country!.isEmpty ? '' : ", ${placeMarks.first.country}") +
        (placeMarks.first.postalCode!.isEmpty ? '' : ", ${placeMarks.first.postalCode}");

    isGettingAddress.value = false;

    return address;
  }
}
