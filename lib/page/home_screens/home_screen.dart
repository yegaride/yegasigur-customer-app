import 'package:cabme/constant/constant.dart';
import 'package:cabme/controller/home_controller.dart';
import 'package:cabme/model/home_model.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      init: HomeController(),
      builder: (controller) {
        // final e = controller.homePageViewPages.length;
        return Scaffold(
          body: Column(
            children: [
              Container(
                color: controller.selectedPageViewIndex.value == 1 ? Colors.red : Colors.blue,
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.homePageViewPages.length,
                  onPageChanged: (i) => controller.selectedPageViewIndex.value = i,
                  itemBuilder: (context, index) {
                    final HomeModel screen = controller.homePageViewPages[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Center(
                              child: Image.asset(
                                screen.imageAsset,
                                width: 260,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Column(
                              children: [
                                Text(
                                  "Welcome back ${Constant.getUserData().data?.prenom}",
                                  // screen.title,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: ConstantColors.primary,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                                  child: Text(
                                    screen.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, color: Colors.black45, letterSpacing: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
