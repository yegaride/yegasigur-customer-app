import 'package:cabme/constant/constant.dart';
import 'package:cabme/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedPageViewIndex = 0.obs;

  var pageController = PageController(viewportFraction: 0.75);

  @override
  void onInit() {
    getTaxiData();
    super.onInit();
  }

  Future getTaxiData() async {
    Constant.driverLocationUpdateCollection.where("active", isEqualTo: true).snapshots().listen((event) {
      print("=======>😂😂");
      print(event.docs.length);
    });
  }

  List<HomeModel> homePageViewPages = const [
    HomeModel(
      imageAsset: 'assets/images/intro_1.png',
      title: 'Welcome back dear user!',
      description: 'YegaSigur.com is a Designated Driver Service. Get home Safe,  with YegaSigur.com',
    ),
    // HomeModel(
    //   imageAsset: 'assets/images/intro_2.png',
    //   title: 'Lorem ipsum dolor 2',
    //   description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
    // ),
    // HomeModel(
    //   imageAsset: 'assets/images/intro_3.png',
    //   title: 'Lorem ipsum dolor 3',
    //   description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
    // ),
  ];
}
