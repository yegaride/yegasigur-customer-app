import 'dart:convert';
import 'dart:developer';

import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ChooseSafeLocationController extends GetxController {
  LatLng currentLocation = const LatLng(12.566199, -70.019366);
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
