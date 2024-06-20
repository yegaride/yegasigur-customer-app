import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme/model/trip_details_model.dart';
import 'package:cabme/model/user_safe_location_model.dart';
import 'package:cabme/model/vehicle_category_model.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:location/location.dart';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';

class OrderYegasigurController extends GetxController {
  var distance = 0.0.obs;
  var duration = ''.obs;
  RxBool isLoading = false.obs;
  bool insufficientBalance = false;

  Future<double?> getAmount() async {
    try {
      final response = await http.get(
        Uri.parse("${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app"),
        headers: API.header,
      );
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        return responseBody['data']['amount'] != null ? double.parse(responseBody['data']['amount'].toString()) : 0;
      } else if (response.statusCode == 200 && responseBody['success'] == "failed") {
        throw Exception(responseBody['message']);
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      // TODO i18n
      ShowToastDialog.showToast('Something want wrong. Please try again later');
      return null;
    }
  }

  Future<UserSafeLocationModel> getUserSafeLocation(int userId) async {
    final userSafeLocationResponse = await http.get(
      Uri.parse('${API.userSafeLocation}?user_id=$userId'),
      headers: API.header,
    );

    if (userSafeLocationResponse.statusCode != 200) {
      throw const HttpException('Something went wrong');
    }

    return UserSafeLocationModel.fromJson(userSafeLocationResponse.body);
  }

  Future<TripDetailsModel> getTripDetails({required UserSafeLocationModel userSafeLocation}) async {
    LocationData location = await Location().getLocation();

    final startLat = location.latitude;
    final startLng = location.longitude;

    final tripDetailsResponse = await http.get(
      Uri.parse(
        '${API.googleMapDistanceMatrix}?units=metric&origins=$startLat,'
        '$startLng&destinations=${userSafeLocation.safeLocationLat},${userSafeLocation.safeLocationLng}&key=${Constant.kGoogleApiKey}',
      ),
    );

    if (tripDetailsResponse.statusCode != 200) {
      throw const HttpException('Something went wrong');
    }

    final tripDetails = json.decode(tripDetailsResponse.body);

    tripDetails["startLat"] = startLat.toString();
    tripDetails["startLng"] = startLng.toString();
    tripDetails["safeLocationLat"] = userSafeLocation.safeLocationLat.toString();
    tripDetails["safeLocationLng"] = userSafeLocation.safeLocationLng.toString();

    return TripDetailsModel.fromMap(tripDetails);
  }

  Future<VehicleCategoryModel> getVehicleCategory() async {
    final res = await http.get(
      Uri.parse(API.getVehicleCategory),
      headers: API.header,
    );

    if (res.statusCode != 200) {
      throw const HttpException('Failed to load data');
    }

    return VehicleCategoryModel.fromJson(jsonDecode(res.body));
  }

  Future<int?> orderYegaSigur() async {
    try {
      insufficientBalance = false;

      isLoading(true);

      final userId = Preferences.getInt(Preferences.userId);

      ShowToastDialog.showLoader("Please wait");

      final data = await Future.wait([getAmount(), getVehicleCategory(), getUserSafeLocation(userId)]);

      final double? walletBalance = data[0] as double?;
      final VehicleCategoryModel vehicleData = data[1] as VehicleCategoryModel;
      final UserSafeLocationModel userSafeLocation = data[2] as UserSafeLocationModel;

      if (walletBalance == null) {
        throw Exception();
      }

      // final double minimunTripPrice = double.parse(vehicleData["data"][0]["minimum_delivery_charges"]);
      // final double minimunDeliveryChargesWithinKm = double.parse(vehicleData["data"][0]["minimum_delivery_charges_within"]);
      // final double pricePerKm = double.parse(vehicleData["data"][0]["delivery_charges"]);

      final double minimunTripPrice = double.parse(vehicleData.data!.first.minimumDeliveryCharges!);
      final double minimunDeliveryChargesWithinKm = double.parse(vehicleData.data!.first.minimumDeliveryChargesWithin!);
      final double pricePerKm = double.parse(vehicleData.data!.first.deliveryCharges!);

      final double tripPriceNumber =
          distance.value < minimunDeliveryChargesWithinKm ? minimunTripPrice : distance.value * pricePerKm;

      final String tripPrice = tripPriceNumber.toDouble().toStringAsFixed(int.parse(Constant.decimal ?? "2"));

      if (walletBalance < tripPriceNumber) {
        insufficientBalance = true;
        isLoading(false);
        return null;
      }

      final TripDetailsModel tripDetails = await getTripDetails(userSafeLocation: userSafeLocation);

      duration.value = tripDetails.rows.first.elements.first.duration.text;

      if (Constant.distanceUnit == "KM") {
        distance.value = tripDetails.rows.first.elements.first.distance.value / 1000.00;
      } else {
        distance.value = tripDetails.rows.first.elements.first.distance.value / 1609.34;
      }

      final requestResponse = await http.post(
        Uri.parse(API.bookRides),
        headers: API.header,
        body: jsonEncode(
          {
            "user_id": userId,
            "lat1": tripDetails.startLat,
            "lng1": tripDetails.startLng,
            "lat2": tripDetails.safeLocationLat,
            "lng2": tripDetails.safeLocationLng,
            "cout": tripPrice,
            "distance": distance.value.toString(),
            "distance_unit": "KM",
            "duree": duration.value,
            "id_conducteur": "0",
            "id_payment": "5",
            "depart_name": tripDetails.originAddresses.first,
            "destination_name": tripDetails.destinationAddresses.first,
            "stops": [],
            "place": "",
            "number_poeple": "1",
            "image": "",
            "image_name": "",
            "statut_round": "no",
            "trip_objective": "General",
            "age_children1": "",
            "age_children2": "",
            "age_children3": ""
          },
        ),
      );

      if (requestResponse.statusCode != 200) {
        throw const HttpException('Failed to load data');
      }

      return requestResponse.statusCode;
    } catch (_) {
      ShowToastDialog.showToast('Something want wrong. Please try again later');
    } finally {
      ShowToastDialog.closeLoader();
      isLoading(false);
    }

    return null;
  }
}
