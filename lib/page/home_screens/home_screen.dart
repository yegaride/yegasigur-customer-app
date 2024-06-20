import 'package:cabme/constant/constant.dart';
import 'package:cabme/controller/dash_board_controller.dart';
import 'package:cabme/controller/home_controller.dart';
import 'package:cabme/model/home_model.dart';
import 'package:cabme/routes/routes.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

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
                        // Expanded(
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(top: 30),
                        //     child: Center(
                        //       child: Image.asset(
                        //         screen.imageAsset,
                        //         width: 260,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/appIcon-130.png',
                                  height: 100,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '${'Welcome back'.tr} \n${_capitalize(Constant.getUserData().data?.prenom ?? 'User')}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: ConstantColors.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                                  child: Text(
                                    screen.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, color: Colors.black45, letterSpacing: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ButtonThem.buildButton(
                                  btnHeight: 70,
                                  context,
                                  // TODO i18n
                                  title: 'Order YegaSigur',
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white,
                                  onPress: () {
                                    Get.put(DashBoardController()).onRouteSelected(Routes.orderYegasigur);
                                  },
                                ),
                                const SizedBox(height: 20),
                                ButtonThem.buildButton(
                                  btnHeight: 70,
                                  context,
                                  // TODO i18n
                                  title: 'Wallet',
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white,
                                  onPress: () {
                                    Get.put(DashBoardController()).onRouteSelected(Routes.wallet);
                                  },
                                )
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
