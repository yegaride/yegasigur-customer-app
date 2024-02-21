import 'package:cabme/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedPageViewIndex = 0.obs;

  var pageController = PageController(viewportFraction: 0.75);

  List<HomeModel> homePageViewPages = const [
    HomeModel(
      imageAsset: 'assets/images/intro_1.png',
      title: 'Welcome back dear user!',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
    ),
    HomeModel(
      imageAsset: 'assets/images/intro_2.png',
      title: 'Lorem ipsum dolor 2',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
    ),
    HomeModel(
      imageAsset: 'assets/images/intro_3.png',
      title: 'Lorem ipsum dolor 3',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
    ),
  ];
}
