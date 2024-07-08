import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/settings_model.dart';
import 'package:cabme/page/dash_board.dart';
import 'package:cabme/page/error_screen/error_screen.dart';
import 'package:cabme/page/localization_screens/localization_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/page/on_boarding_screen.dart';

class SplashScreenController extends GetxController {
  bool errorLoadingSettings = false;

  @override
  void onInit() {
    API.header['accesstoken'] = Preferences.getString(Preferences.accesstoken);
    getSettingsAndPaymentSettingsData();
    super.onInit();
  }

  Future<void> getSettingsAndPaymentSettingsData() async {
    final String accessToken = Preferences.getString(Preferences.accesstoken);

    if (accessToken.isNotEmpty) {
      await Future.wait([
        getSettingsData(),
        getPaymentSettingsData(),
      ]);
    } else {
      await getSettingsData();
    }

    navigateToNextScreen();
  }

  Future<SettingsModel?> getSettingsData() async {
    try {
      final response = await http.get(
        Uri.parse(API.settings),
        headers: API.authheader,
      );

      Map<String, dynamic> responseBody = json.decode(response.body);
      log(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        SettingsModel model = SettingsModel.fromJson(responseBody);
        // LocationData location = await Location().getLocation();
        // List<get_cord_address.Placemark> placeMarks =
        //     await get_cord_address.placemarkFromCoordinates(location.latitude ?? 0.0, location.longitude ?? 0.0);
        // ConstantColors.primary = Color(int.parse(model.data!.websiteColor!.replaceFirst("#", "0xff")));
        Constant.distanceUnit = model.data!.deliveryDistance!;
        Constant.driverRadius = model.data!.driverRadios!;
        Constant.appVersion = model.data!.appVersion.toString();
        Constant.decimal = model.data!.decimalDigit!;
        Constant.driverLocationUpdate = model.data!.driverLocationUpdate!;
        Constant.mapType = model.data!.mapType!;
        for (var i = 0; i < model.data!.taxModel!.length; i++) {
          // if (placeMarks.first.country.toString().toUpperCase() == model.data!.taxModel![i].country!.toUpperCase()) {
          if ('aruba'.toUpperCase() == model.data!.taxModel![i].country!.toUpperCase()) {
            Constant.taxList.add(model.data!.taxModel![i]);
          }
        }
        // Constant.taxType = model.data!.taxType!;
        // Constant.taxName = model.data!.taxName!;
        // Constant.taxValue = model.data!.taxValue!;
        Constant.currency = model.data!.currency!;
        Constant.symbolAtRight = model.data!.symbolAtRight! == 'true' ? true : false;
        // Constant.kGoogleApiKey = model.data!.googleMapApiKey!;
        Constant.contactUsEmail = model.data!.contactUsEmail!;
        Constant.contactUsAddress = model.data!.contactUsAddress!;
        Constant.contactUsPhone = model.data!.contactUsPhone!;
        Constant.rideOtp = model.data!.showRideOtp!;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } catch (e) {
      errorLoadingSettings = true;
    }
    return null;
  }

  Future<void> getPaymentSettingsData() async {
    try {
      final response = await http.get(Uri.parse(API.paymentSetting), headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 401) {
        _clearPreferencesData();
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } catch (e) {
      errorLoadingSettings = true;
    }
  }

  void _clearPreferencesData() {
    Preferences.clearKeyData(Preferences.isLogin);
    Preferences.clearKeyData(Preferences.user);
    Preferences.clearKeyData(Preferences.userId);
    Preferences.clearKeyData(Preferences.accesstoken);
  }

  void navigateToNextScreen() {
    if (Preferences.getString(Preferences.languageCodeKey).isEmpty) {
      Get.off(
        () => const LocalizationScreens(intentType: "main"),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 700),
      );
    } else if (errorLoadingSettings) {
      Get.offAll(
        () => const ErrorScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 700),
      );
    } else if (Preferences.getBoolean(Preferences.isLogin)) {
      Get.off(
        () => const DashBoard(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 700),
      );
    } else {
      Get.off(
        () => const OnBoardingScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 700),
      );
    }
  }
}
