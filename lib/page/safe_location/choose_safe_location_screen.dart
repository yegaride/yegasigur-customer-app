import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/choose_safe_location_controller.dart';
import 'package:cabme/page/auth_screens/add_profile_photo_screen.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseSafeLocationScreen extends StatefulWidget {
  const ChooseSafeLocationScreen({super.key});

  @override
  State<ChooseSafeLocationScreen> createState() => _ChooseSafeLocationScreenState();
}

class _ChooseSafeLocationScreenState extends State<ChooseSafeLocationScreen> {
  final controller = Get.put(ChooseSafeLocationController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFE8EAED),
        body: Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition(
                target: controller.currentLocation,
                zoom: 14,
              ),
              onCameraMove: (cameraPosition) {
                controller.currentLocation = cameraPosition.target;
              },
            ),
            Align(
              alignment: Alignment.center,
              child: FractionalTranslation(
                translation: const Offset(0, -0.5),
                child: Image.asset(
                  'assets/icons/safe-location.png',
                  height: 40,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: ConstantColors.fucsia.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  // TODO: add internacionalization
                  child: Column(
                    children: [
                      Text(
                        'Please drag and select your safe location',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      ButtonThem.buildButton(
                        context,
                        title: 'Continue'.tr,
                        btnColor: ConstantColors.primary,
                        txtColor: Colors.white,
                        onPress: () => controller.saveSafeLocation().then(
                          (value) {
                            Get.to(AddProfilePhotoScreen());
                          },
                        ).catchError(
                          (value) {
                            ShowToastDialog.showToast(value.error);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
