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
  const ChooseSafeLocationScreen({
    super.key,
    required this.continueButtonType,
  });

  final String continueButtonType;

  @override
  State<ChooseSafeLocationScreen> createState() => _ChooseSafeLocationScreenState();
}

class _ChooseSafeLocationScreenState extends State<ChooseSafeLocationScreen> {
  final controller = Get.put(ChooseSafeLocationController());

  Widget _buildTextField({required title, required TextEditingController textController}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: ConstantColors.titleTextColor),
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    );
  }

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
                zoom: 17,
              ),
              onCameraMove: (cameraPosition) {
                controller.currentLocation = cameraPosition.target;
              },
              onMapCreated: (GoogleMapController googleMapController) {
                controller.mapController = googleMapController;
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 62, left: 12, right: 12),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () async {
                  controller.placesPredictionAPI(context).then((prediction) {
                    if (prediction == null) return;
                    controller.searchLocationController.text = prediction.result.formattedAddress.toString();
                    controller.animateCameraToSearchedLocation(
                      LatLng(
                        prediction.result.geometry!.location.lat,
                        prediction.result.geometry!.location.lng,
                      ),
                    );
                  });
                },
                child: _buildTextField(
                  // TODO: add to ln10
                  title: "Search area",
                  textController: controller.searchLocationController,
                ),
              ),
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
                        title: widget.continueButtonType == 'back' ? 'Save'.tr : 'Continue'.tr,
                        btnColor: ConstantColors.primary,
                        txtColor: Colors.white,
                        onPress: () => controller.saveSafeLocation().then(
                          (value) {
                            if (widget.continueButtonType == 'back') {
                              Get.back();
                              return;
                            }
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
