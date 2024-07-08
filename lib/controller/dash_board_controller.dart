import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/drawer_item_model.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/page/auth_screens/mobile_number_screen.dart';
import 'package:cabme/page/contact_us/contact_us_screen.dart';
import 'package:cabme/page/home_screens/home_screen.dart';
import 'package:cabme/page/map_view/map_view_screen.dart';
import 'package:cabme/page/my_profile/my_profile_screen.dart';
import 'package:cabme/page/new_ride_screens/new_ride_screen.dart';
import 'package:cabme/page/order_yegasigur_screen/order_yegasigur_screen.dart';
import 'package:cabme/page/settings/user_settings_screen.dart';
import 'package:cabme/page/wallet/wallet_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cabme/routes/routes.dart';
// import 'package:launch_review/launch_review.dart';

class DashBoardController extends GetxController {
  RxString selectedRoute = Routes.home.obs;

  @override
  void onInit() {
    getUsrData();
    updateToken();
    super.onInit();
  }

  UserModel? userModel;

  getUsrData() {
    userModel = Constant.getUserData();
  }

  updateToken() async {
    // use the returned token to send messages to users from your custom server
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      updateFCMToken(token);
    }
  }

  final drawerRoutes = [
    DrawerRoute(Routes.home, CupertinoIcons.home),
    DrawerRoute(Routes.mapView, Icons.map),
    DrawerRoute(Routes.orderYegasigur, CupertinoIcons.car_detailed),
    DrawerRoute(Routes.myProfile, Icons.person_outline),
    DrawerRoute(Routes.allRides, Icons.local_car_wash),
    DrawerRoute(Routes.wallet, Icons.account_balance_wallet_outlined),
    DrawerRoute(Routes.settings, Icons.settings),
    DrawerRoute(Routes.contactUs, Icons.support_agent),
  ];

  Widget buildSelectedRoute(String route) {
    return switch (route) {
      Routes.home => const HomeScreen(),
      Routes.mapView => const MapViewScreen(),
      Routes.orderYegasigur => OrderYegasigurScreen(),
      Routes.myProfile => MyProfileScreen(),
      Routes.allRides => const NewRideScreen(),
      Routes.wallet => WalletScreen(),
      Routes.settings => const UserSettingsScreen(),
      Routes.contactUs => const ContactUsScreen(),
      _ => const Text('Error'),
    };
  }

  void onRouteSelected(String route) {
    // rate app
    // LaunchReview.launch(
    //   androidAppId: "com.cabme",
    //   iOSAppId: "com.cabme.ios",
    // );
    // log out
    if (route == Routes.signOut) {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(() => const MobileNumberScreen(isLogin: true));
    } else {
      selectedRoute.value = route;
    }

    Get.back();
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'fcm_id': token,
        'device_id': "",
        'user_cat': userModel!.data!.userCat
      };
      final response = await http.post(Uri.parse(API.updateToken), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response = await http.get(Uri.parse(API.paymentSetting), headers: API.header);

      log("---->");
      log("${API.header}");
      log(response.body);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
