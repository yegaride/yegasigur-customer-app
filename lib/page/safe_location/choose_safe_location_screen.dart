import 'package:cabme/controller/choose_safe_location_controller.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/widget/back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SavebuttonBehavior { saveAndBack, saveAndContinue }

class ChooseSafeLocationScreen extends StatefulWidget {
  const ChooseSafeLocationScreen({
    super.key,
    required this.saveButtonBehavior,
  });

  final SavebuttonBehavior saveButtonBehavior;

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
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: ConstantColors.primary, width: 1.5)),
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
                zoom: 18,
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
                  controller.placesPredictionAPI(context).then(
                    (prediction) {
                      if (prediction == null) return;
                      controller.searchLocationController.text = prediction.result.formattedAddress.toString();
                      controller.animateCameraToSearchedLocation(
                        LatLng(
                          prediction.result.geometry!.location.lat,
                          prediction.result.geometry!.location.lng,
                        ),
                      );
                    },
                  );
                },
                child: _buildTextField(
                  // TODO: i18n
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
                  child: Obx(() {
                    return Column(
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
                        if (controller.isLoading.value)
                          const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        else
                          ButtonThem.buildButton(
                            context,
                            // TODO i18n
                            title: widget.saveButtonBehavior == SavebuttonBehavior.saveAndBack ? 'Save'.tr : 'Continue'.tr,
                            btnColor: ConstantColors.primary,
                            txtColor: Colors.white,
                            onPress: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return _SaveLocationConfirmationDialog(
                                    // TODO i18n
                                    controller: controller,
                                    title: 'Are you sure you want to save the following address as your safe location?',
                                    onPressPositive: () {
                                      Get.back();
                                      controller.saveSafeLocation(savebuttonBehavior: widget.saveButtonBehavior);
                                    },
                                    onPressNegative: () => Get.back(),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            if (widget.saveButtonBehavior == SavebuttonBehavior.saveAndBack) const AppBackButton()
          ],
        ),
      ),
    );
  }
}

class _SaveLocationConfirmationDialog extends StatefulWidget {
  const _SaveLocationConfirmationDialog({
    required this.title,
    required this.onPressPositive,
    required this.onPressNegative,
    required this.controller,
  });

  final String title;
  final Function() onPressPositive;
  final Function() onPressNegative;
  final ChooseSafeLocationController controller;

  @override
  _SaveLocationConfirmationDialogState createState() => _SaveLocationConfirmationDialogState();
}

class _SaveLocationConfirmationDialogState extends State<_SaveLocationConfirmationDialog> {
  String address = '';
  @override
  void initState() {
    super.initState();
    _fetchChosenAddress();
  }

  _fetchChosenAddress() async {
    address = await widget.controller.getAddressFromLatLng();
    widget.controller.addressDecodedFromCoordinates = address;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 10),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (widget.controller.isGettingAddress.value)
                  const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                else
                  Text(
                    '$address. \n\ncoordinates: ${widget.controller.currentLocation.latitude.toStringAsFixed(4)}, ${widget.controller.currentLocation.longitude.toStringAsFixed(4)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ButtonThem.buildButton(
                        context,
                        title: 'Yes'.tr,
                        btnHeight: 45,
                        btnWidthRatio: 0.8,
                        btnColor: ConstantColors.primary,
                        txtColor: widget.controller.isGettingAddress.value ? Colors.black45 : Colors.white,
                        onPress: widget.controller.isGettingAddress.value ? null : widget.onPressPositive,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: ButtonThem.buildBorderButton(
                        context,
                        title: 'No'.tr,
                        btnHeight: 45,
                        btnWidthRatio: 0.8,
                        btnColor: Colors.white,
                        txtColor: ConstantColors.primary,
                        btnBorderColor: ConstantColors.primary,
                        onPress: widget.onPressNegative,
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
        ),
      ],
    );
  }
}
