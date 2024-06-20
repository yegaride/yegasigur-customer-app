import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/localization_controller.dart';
import 'package:cabme/page/on_boarding_screen.dart';
import 'package:cabme/service/localization_service.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationScreens extends StatelessWidget {
  final String intentType;

  const LocalizationScreens({super.key, required this.intentType});

  @override
  Widget build(BuildContext context) {
    return GetX<LocalizationController>(
      init: LocalizationController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: ConstantColors.background,
            body: Stack(
              children: [
                if (intentType == 'dashBoard')
                  Positioned(
                    top: 10,
                    left: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: intentType == 'dashBoard' ? 45 : 30),
                        child: Text(
                          'select_language'.tr,
                          style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.languageList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  controller.selectedLanguage.value = controller.languageList[index].code.toString();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    decoration: controller.languageList[index].code == controller.selectedLanguage.value
                                        ? BoxDecoration(
                                            border: Border.all(color: ConstantColors.primary),
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(5.0) //                 <--- border radius here
                                                ),
                                          )
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            controller.languageList[index].flag.toString(),
                                            height: 60,
                                            width: 60,
                                          ),
                                          Expanded(
                                            child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: Text(controller.languageList[index].language.toString())),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  LocalizationService().changeLocale(controller.selectedLanguage.value);
                  Preferences.setString(Preferences.languageCodeKey, controller.selectedLanguage.toString());
                  if (intentType == "dashBoard") {
                    ShowToastDialog.showToast("Language change successfully".tr);
                  } else {
                    Get.offAll(const OnBoardingScreen());
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(Icons.navigate_next, size: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}
