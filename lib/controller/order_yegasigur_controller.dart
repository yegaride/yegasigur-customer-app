import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class OrderYegasigurController extends GetxController {
  var distance = 0.0.obs;
  var duration = ''.obs;

  Future<int?> orderYegaSigur() async {
    try {
      ShowToastDialog.showLoader("Please wait");

      LocationData location = await Location().getLocation();

      // 12.444182, -69.909228 test location
      // 37.409392, -122.089005

      final startLat = location.latitude;
      final startLng = location.longitude;
      // final startLat = '37.409392';
      // final startLng = '-122.089005';

      final userId = Preferences.getInt(Preferences.userId);

      // String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';

      final userSafeLocationResponse = await http.get(
        Uri.parse('${API.userSafeLocation}?user_id=$userId'),
        headers: API.header,
      );

      if (userSafeLocationResponse.statusCode != 200) {
        throw const HttpException('Something went wrong');
      }

      final userSafeLocation = json.decode(userSafeLocationResponse.body);

      final safeLocationLat = userSafeLocation['safe_location_lat'];
      final safeLocationLng = userSafeLocation['safe_location_lng'];

      final tripDetailsResponse = await http.get(
        Uri.parse(
          '${API.googleMapDistanceMatrix}?units=metric&origins=$startLat,'
          '$startLng&destinations=$safeLocationLat,$safeLocationLng&key=${Constant.kGoogleApiKey}',
        ),
      );

      if (tripDetailsResponse.statusCode != 200) {
        throw const HttpException('Something went wrong');
      }

      final tripDetails = json.decode(tripDetailsResponse.body);

      duration.value = tripDetails['rows'].first['elements'].first['duration']['text'];

      if (Constant.distanceUnit == "KM") {
        distance.value = tripDetails['rows'].first['elements'].first['distance']['value'] / 1000.00;
      } else {
        distance.value = tripDetails['rows'].first['elements'].first['distance']['value'] / 1609.34;
      }

      final originAddress = tripDetails['origin_addresses'].first;
      final safelocationAddress = tripDetails['destination_addresses'].first;

      final res = await http.get(
        Uri.parse(API.getVehicleCategory),
        headers: API.header,
      );

      if (res.statusCode != 200) {
        throw const HttpException('Failed to load data');
      }

      final vehicleData = jsonDecode(res.body);

      final double minimunTripPrice = double.parse(vehicleData["data"][0]["minimum_delivery_charges"]);
      final double minimunDeliveryChargesWithinKm = double.parse(vehicleData["data"][0]["minimum_delivery_charges_within"]);
      final double pricePerKm = double.parse(vehicleData["data"][0]["delivery_charges"]);

      final double tripPriceNumber =
          distance.value < minimunDeliveryChargesWithinKm ? minimunTripPrice : distance.value * pricePerKm;

      final String tripPrice = tripPriceNumber.toDouble().toStringAsFixed(int.parse(Constant.decimal ?? "2"));

      final requestResponse = await http.post(
        Uri.parse(API.bookRides),
        headers: API.header,
        body: jsonEncode(
          {
            "user_id": userId,
            "lat1": "$startLat",
            "lng1": "$startLng",
            "lat2": "$safeLocationLat",
            "lng2": "$safeLocationLng",
            "cout": tripPrice,
            "distance": "${distance.value}",
            "distance_unit": "KM",
            "duree": duration.value,
            "id_conducteur": "0",
            "id_payment": "5",
            "depart_name": originAddress,
            "destination_name": safelocationAddress,
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

      ShowToastDialog.closeLoader();

      return requestResponse.statusCode;
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
    }

    return null;
  }
}
