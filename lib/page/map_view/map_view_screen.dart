import 'dart:async';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/map_view_controller.dart';
import 'package:cabme/controller/new_ride_controller.dart';
import 'package:cabme/model/driver_model.dart';
import 'package:cabme/model/vehicle_category_model.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/themes/custom_dialog_box.dart';
import 'package:cabme/themes/text_field_them.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final controller = Get.put(MapViewController());
  final newRideController = Get.put(NewRideController());

  Timer? timer;

  GoogleMapController? _controller;
  final Location currentLocation = Location();

  LatLng? departureLatLong;
  LatLng? destinationLatLong;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    controller.multiStopList.clear();
    controller.multiStopListNew.clear();
    controller.markers.clear();
    getCurrentLocation(true);
    getCurrentDriver();

    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      getCurrentDriver();
    });

    super.initState();
  }

  Future<void> getCurrentDriver() async {
    await newRideController.getNewRide();
    controller.getCurrentDriver(newRideController.rideList);
  }

  @override
  void dispose() {
    Get.delete<NewRideController>();

    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  getCurrentLocation(bool isDepartureSet) async {
    if (isDepartureSet) {
      LocationData location = await currentLocation.getLocation();
      List<get_cord_address.Placemark> placeMarks =
          await get_cord_address.placemarkFromCoordinates(location.latitude ?? 0.0, location.longitude ?? 0.0);

      final address = (placeMarks.first.subLocality!.isEmpty ? '' : "${placeMarks.first.subLocality}, ") +
          (placeMarks.first.street!.isEmpty ? '' : "${placeMarks.first.street}, ") +
          (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
          (placeMarks.first.subAdministrativeArea!.isEmpty ? '' : "${placeMarks.first.subAdministrativeArea}, ") +
          (placeMarks.first.administrativeArea!.isEmpty ? '' : "${placeMarks.first.administrativeArea}, ") +
          (placeMarks.first.country!.isEmpty ? '' : "${placeMarks.first.country}, ") +
          (placeMarks.first.postalCode!.isEmpty ? '' : "${placeMarks.first.postalCode}, ");
      controller.departureController.text = address;
      setState(() {
        setDepartureMarker(LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.background,
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            compassEnabled: false,
            initialCameraPosition: CameraPosition(
              target: controller.center,
              zoom: 14.0,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
            buildingsEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
              LocationData location = await currentLocation.getLocation();
              _controller!
                  .moveCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0), 14));
            },
            polylines: Set<Polyline>.of(polyLines.values),
            myLocationEnabled: true,
            markers: controller.markers.values.toSet(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: ElevatedButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      "assets/icons/ic_side_menu.png",
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: controller.confirmWidgetVisible.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: confirmWidget(),
            ),
          ),
        ],
      ),
    );
  }

  setDepartureMarker(LatLng departure) {
    setState(() {
      controller.markers.remove("Departure");
      controller.markers['Departure'] = Marker(
        markerId: const MarkerId('Departure'),
        infoWindow: const InfoWindow(title: "Departure"),
        position: departure,
        icon: controller.departureIcon!,
      );
      departureLatLong = departure;
      _controller!.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(departure.latitude, departure.longitude), zoom: 14)));

      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
      }
    });
  }

  setDestinationMarker(LatLng destination) {
    setState(() {
      controller.markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: destination,
        icon: controller.destinationIcon!,
      );
      destinationLatLong = destination;

      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
      }
    });
  }

  setStopMarker(LatLng destination, int index) {
    setState(() {
      controller.markers['Stop $index'] = Marker(
        markerId: MarkerId('Stop $index'),
        infoWindow: InfoWindow(title: "Stop ${String.fromCharCode(index + 65)}"),
        position: destination,
        icon: controller.stopIcon!,
      );

      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
      }
    });
  }

  Widget buildTextField({required title, required TextEditingController textController}) {
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

  getDirections() async {
    List<PolylineWayPoint> wayPointList = [];
    for (var i = 0; i < controller.multiStopList.length; i++) {
      wayPointList.add(PolylineWayPoint(location: controller.multiStopList[i].editingController.text));
    }
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constant.kGoogleApiKey.toString(),
      PointLatLng(departureLatLong!.latitude, departureLatLong!.longitude),
      PointLatLng(destinationLatLong!.latitude, destinationLatLong!.longitude),
      wayPoints: wayPointList,
      optimizeWaypoints: true,
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: ConstantColors.primary,
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );
    polyLines[id] = polyline;
    setState(() {});
  }

  confirmWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ButtonThem.buildIconButton(context,
                iconSize: 16.0,
                icon: Icons.arrow_back_ios,
                iconColor: Colors.black,
                btnHeight: 40,
                btnWidthRatio: 0.25,
                title: "Back".tr,
                btnColor: ConstantColors.yellow,
                txtColor: Colors.black, onPress: () {
              controller.confirmWidgetVisible.value = false;
            }),
          ),
          Expanded(
            child: ButtonThem.buildButton(context,
                btnHeight: 40, title: "Continue".tr, btnColor: ConstantColors.primary, txtColor: Colors.white, onPress: () async {
              await controller.getDurationDistance(departureLatLong!, destinationLatLong!).then((durationValue) async {
                print('===$durationValue');
                if (durationValue != null) {
                  await controller.getUserPendingPayment().then((value) async {
                    if (value != null) {
                      if (value['success'] == "success") {
                        if (value['data']['amount'] != 0) {
                          _pendingPaymentDialog(context);
                        } else {
                          if (Constant.distanceUnit == "KM") {
                            controller.distance.value =
                                durationValue['rows'].first['elements'].first['distance']['value'] / 1000.00;
                          } else {
                            controller.distance.value =
                                durationValue['rows'].first['elements'].first['distance']['value'] / 1609.34;
                          }

                          controller.duration.value = durationValue['rows'].first['elements'].first['duration']['text'];

                          controller.confirmWidgetVisible.value = false;
                          tripOptionBottomSheet(context);
                        }
                      } else {
                        if (Constant.distanceUnit == "KM") {
                          controller.distance.value =
                              durationValue['rows'].first['elements'].first['distance']['value'] / 1000.00;
                        } else {
                          controller.distance.value =
                              durationValue['rows'].first['elements'].first['distance']['value'] / 1609.34;
                        }
                        controller.duration.value = durationValue['rows'].first['elements'].first['duration']['text'];
                        controller.confirmWidgetVisible.value = false;

                        tripOptionBottomSheet(context);
                      }
                    }
                  });
                }
              });
            }),
          ),
        ],
      ),
    );
  }

  final passengerController = TextEditingController(text: "1");

  tripOptionBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Trip option".tr,
                          style: const TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: passengerController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            labelText: 'How many passenger'.tr,
                            hintText: 'How many passenger'.tr,
                          ),
                        ),
                      ),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.addChildList.length,
                          itemBuilder: (_, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: controller.addChildList[index].editingController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'Any children ? Age of child'.tr,
                                ),
                              ),
                            );
                          }),
                      Visibility(
                        visible: controller.addChildList.length < 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (controller.addChildList.length < 3) {
                                    controller.addChildList.add(AddChildModel(editingController: TextEditingController()));
                                  }
                                },
                                child: SizedBox(
                                  width: 60,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: ConstantColors.primary,
                                      ),
                                      Text("Add".tr),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ButtonThem.buildIconButton(context,
                                  iconSize: 16.0,
                                  icon: Icons.arrow_back_ios,
                                  iconColor: Colors.black,
                                  btnHeight: 40,
                                  btnWidthRatio: 0.25,
                                  title: "Back".tr,
                                  btnColor: ConstantColors.yellow,
                                  txtColor: Colors.black, onPress: () {
                                Get.back();
                              }),
                            ),
                            Expanded(
                              child: ButtonThem.buildButton(context,
                                  btnHeight: 40,
                                  title: "Book Now".tr,
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white, onPress: () async {
                                if (passengerController.text.isEmpty) {
                                  ShowToastDialog.showToast("Please Enter Passenger".tr);
                                } else {
                                  await controller.getVehicleCategory().then((value) {
                                    if (value != null) {
                                      if (value.success == "Success") {
                                        Get.back();

                                        chooseVehicleBottomSheet(
                                          context,
                                          value,
                                        );
                                      }
                                    }
                                  });
                                }
                              }),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  chooseVehicleBottomSheet(
    BuildContext context,
    VehicleCategoryModel vehicleCategoryModel,
  ) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Choose Your Vehicle Type".tr,
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset("assets/icons/ic_distance.png", height: 24, width: 24),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text("Distance".tr, style: const TextStyle(fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                        Text("${controller.distance.value.toStringAsFixed(2)} ${Constant.distanceUnit}")
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: vehicleCategoryModel.data!.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  controller.vehicleData = vehicleCategoryModel.data![index];
                                  controller.selectedVehicle.value = vehicleCategoryModel.data![index].id.toString();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: controller.selectedVehicle.value == vehicleCategoryModel.data![index].id.toString()
                                            ? ConstantColors.primary
                                            : Colors.black.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: vehicleCategoryModel.data![index].image.toString(),
                                            fit: BoxFit.fill,
                                            width: 80,
                                            height: 50,
                                            placeholder: (context, url) => Constant.loader(),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: Text(
                                                      vehicleCategoryModel.data![index].libelle.toString(),
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: controller.selectedVehicle.value ==
                                                                  vehicleCategoryModel.data![index].id.toString()
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 5),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        controller.duration.value,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: controller.selectedVehicle.value ==
                                                                  vehicleCategoryModel.data![index].id.toString()
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        Constant().amountShow(
                                                            amount: "${controller.calculateTripPrice(
                                                          distance: controller.distance.value,
                                                          deliveryCharges:
                                                              double.parse(vehicleCategoryModel.data![index].deliveryCharges!),
                                                          minimumDeliveryCharges: double.parse(
                                                              vehicleCategoryModel.data![index].minimumDeliveryCharges!),
                                                          minimumDeliveryChargesWithin: double.parse(
                                                              vehicleCategoryModel.data![index].minimumDeliveryChargesWithin!),
                                                        )}"),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: controller.selectedVehicle.value ==
                                                                  vehicleCategoryModel.data![index].id.toString()
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.black,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: ConstantColors.yellow,
                                txtColor: Colors.black, onPress: () {
                              Get.back();
                              tripOptionBottomSheet(context);
                            }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book Now".tr,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white, onPress: () async {
                              if (controller.selectedVehicle.value.isNotEmpty) {
                                double cout = 0.0;

                                if (controller.distance.value >
                                    double.parse(controller.vehicleData!.minimumDeliveryChargesWithin!)) {
                                  cout = (controller.distance.value * double.parse(controller.vehicleData!.deliveryCharges!))
                                      .toDouble();
                                } else {
                                  cout = double.parse(controller.vehicleData!.minimumDeliveryCharges.toString());
                                }

                                await controller
                                    .getDriverDetails(controller.vehicleData!.id.toString(),
                                        departureLatLong!.latitude.toString(), departureLatLong!.longitude.toString())
                                    .then((value) {
                                  if (value != null) {
                                    if (value.success == "Success") {
                                      List<DriverData> driverData = [];
                                      for (var i = 0; i < value.data!.length; i++) {
                                        if (double.parse(Constant.driverRadius!) >= double.parse(value.data![i].distance!)) {
                                          driverData.add(value.data![i]);
                                        }
                                      }
                                      if (driverData.isNotEmpty) {
                                        Get.back();
                                        conformDataBottomSheet(context, driverData[0], cout);
                                      } else {
                                        ShowToastDialog.showToast("Driver not available".tr);
                                      }
                                    } else {
                                      ShowToastDialog.showToast("Driver not available".tr);
                                    }
                                  }
                                });
                              } else {
                                ShowToastDialog.showToast("Please select Vehicle Type".tr);
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  conformDataBottomSheet(BuildContext context, DriverData driverModel, double tripPrice) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: driverModel.photo.toString(),
                                fit: BoxFit.cover,
                                height: 72,
                                width: 72,
                                placeholder: (context, url) => Constant.loader(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  driverModel.prenom.toString(),
                                  style:
                                      TextStyle(fontSize: 16, color: ConstantColors.titleTextColor, fontWeight: FontWeight.w800),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: StarRating(
                                      size: 18,
                                      rating: double.parse(driverModel.moyenne.toString()),
                                      color: ConstantColors.yellow),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "Total trips".tr + " ${driverModel.totalCompletedRide.toString()}",
                                    style: TextStyle(
                                      color: ConstantColors.subTitleTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Constant.makePhoneCall(driverModel.toString());
                                },
                                child: ClipOval(
                                  child: Container(
                                    color: ConstantColors.primary,
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: InkWell(
                                    onTap: () {
                                      _favouriteNameDialog(context);
                                    },
                                    child: Image.asset(
                                      'assets/icons/add_fav.png',
                                      height: 32,
                                      width: 32,
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _paymentMethodDialog(
                                    context,
                                  );
                                },
                                child: buildDetails(title: controller.paymentMethodType.value, value: 'Payment'.tr),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(child: buildDetails(title: controller.duration.value, value: 'Duration'.tr)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: buildDetails(
                                    title: Constant().amountShow(amount: tripPrice.toString()),
                                    value: 'Trip Price'.tr,
                                    txtColor: ConstantColors.primary)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "Cab Details:".tr,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  driverModel.model.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  "|",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  driverModel.brand.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  "|",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  driverModel.numberplate.toString(),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.black,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: ConstantColors.yellow,
                                txtColor: Colors.black, onPress: () async {
                              await controller.getVehicleCategory().then((value) {
                                if (value != null) {
                                  if (value.success == "Success") {
                                    Get.back();
                                    List tripPrice = [];
                                    for (int i = 0; i < value.data!.length; i++) {
                                      tripPrice.add(0.0);
                                    }
                                    if (value.data!.isNotEmpty) {
                                      for (int i = 0; i < value.data!.length; i++) {
                                        if (controller.distance.value >
                                            double.parse(value.data![i].minimumDeliveryChargesWithin!)) {
                                          tripPrice.add(
                                              (controller.distance.value * double.parse(value.data![i].deliveryCharges!))
                                                  .toDouble()
                                                  .toStringAsFixed(int.parse(Constant.decimal ?? "2")));
                                        } else {
                                          tripPrice.add(double.parse(value.data![i].minimumDeliveryCharges!)
                                              .toStringAsFixed(int.parse(Constant.decimal ?? "2")));
                                        }
                                      }
                                    }
                                    chooseVehicleBottomSheet(
                                      context,
                                      value,
                                    );
                                  }
                                }
                              });
                            }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book now".tr,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white, onPress: () {
                              if (controller.paymentMethodType.value == "Select Method") {
                                ShowToastDialog.showToast("Please select payment method".tr);
                              } else {
                                List stopsList = [];
                                for (var i = 0; i < controller.multiStopListNew.length; i++) {
                                  stopsList.add({
                                    "latitude": controller.multiStopListNew[i].latitude.toString(),
                                    "longitude": controller.multiStopListNew[i].longitude.toString(),
                                    "location": controller.multiStopListNew[i].editingController.text.toString()
                                  });
                                }

                                Map<String, dynamic> bodyParams = {
                                  'user_id': Preferences.getInt(Preferences.userId).toString(),
                                  'lat1': departureLatLong!.latitude.toString(),
                                  'lng1': departureLatLong!.longitude.toString(),
                                  'lat2': destinationLatLong!.latitude.toString(),
                                  'lng2': destinationLatLong!.longitude.toString(),
                                  'cout': tripPrice.toString(),
                                  'distance': controller.distance.toString(),
                                  'distance_unit': Constant.distanceUnit.toString(),
                                  'duree': controller.duration.toString(),
                                  'id_conducteur': driverModel.id.toString(),
                                  'id_payment': controller.paymentMethodId.value,
                                  'depart_name': controller.departureController.text,
                                  'destination_name': controller.destinationController.text,
                                  'stops': stopsList,
                                  'place': '',
                                  'number_poeple': passengerController.text,
                                  'image': '',
                                  'image_name': "",
                                  'statut_round': 'no',
                                  'trip_objective': controller.tripOptionCategory.value,
                                  'age_children1': controller.addChildList[0].editingController.text,
                                  'age_children2': controller.addChildList.length == 2
                                      ? controller.addChildList[1].editingController.text
                                      : "",
                                  'age_children3': controller.addChildList.length == 3
                                      ? controller.addChildList[2].editingController.text
                                      : "",
                                };

                                controller.bookRide(bodyParams).then((value) {
                                  if (value != null) {
                                    if (value['success'] == "success") {
                                      Get.back();
                                      controller.departureController.clear();
                                      controller.destinationController.clear();
                                      polyLines = {};
                                      departureLatLong = null;
                                      destinationLatLong = null;
                                      passengerController.clear();
                                      tripPrice = 0.0;
                                      controller.markers.clear();
                                      controller.clearData();
                                      getDirections();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                              title: "",
                                              descriptions: "Your booking has been sent successfully",
                                              onPress: () {
                                                Get.back();
                                              },
                                              img: Image.asset('assets/images/green_checked.png'),
                                            );
                                          });
                                    }
                                  }
                                });
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  final favouriteNameTextController = TextEditingController();

  _favouriteNameDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter Favourite Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldThem.buildTextField(
                  title: 'Favourite name'.tr,
                  labelText: 'Favourite name'.tr,
                  controller: favouriteNameTextController,
                  textInputType: TextInputType.text,
                  contentPadding: EdgeInsets.zero,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Text("cancel".tr)),
                      InkWell(
                          onTap: () {
                            Map<String, String> bodyParams = {
                              'id_user_app': Preferences.getInt(Preferences.userId).toString(),
                              'lat1': departureLatLong!.latitude.toString(),
                              'lng1': departureLatLong!.longitude.toString(),
                              'lat2': destinationLatLong!.latitude.toString(),
                              'lng2': destinationLatLong!.longitude.toString(),
                              'distance': controller.distance.value.toString(),
                              'distance_unit': Constant.distanceUnit.toString(),
                              'depart_name': controller.departureController.text,
                              'destination_name': controller.destinationController.text,
                              'fav_name': favouriteNameTextController.text,
                            };
                            controller.setFavouriteRide(bodyParams).then((value) {
                              if (value['success'] == "Success") {
                                Get.back();
                              } else {
                                ShowToastDialog.showToast(value['error']);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text("Ok".tr),
                          )),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  _pendingPaymentDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Get.back();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Cab me"),
      content: Text("You have pending payments. Please complete payment before book new trip.".tr),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _paymentMethodDialog(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Select Payment Method"),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.cash != null &&
                                controller.paymentSettingModel.value.cash!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.cash.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: controller.cash.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Cash",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = true.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId =
                                    controller.paymentSettingModel.value.cash!.idPaymentMethod.toString().obs;
                                Get.back();
                              },
                              selected: controller.cash.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/cash.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Cash".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.myWallet != null &&
                                controller.paymentSettingModel.value.myWallet!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.wallet.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: controller.wallet.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Wallet",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = true.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId =
                                    controller.paymentSettingModel.value.myWallet!.idPaymentMethod.toString().obs;
                                Get.back();
                              },
                              selected: controller.wallet.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/icons/walltet_icons.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Wallet".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.strip != null &&
                                controller.paymentSettingModel.value.strip!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.stripe.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: controller.stripe.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Stripe",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = true.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId =
                                    controller.paymentSettingModel.value.strip!.idPaymentMethod.toString().obs;
                                Get.back();
                              },
                              selected: controller.stripe.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/stripe.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Stripe".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payStack != null &&
                                controller.paymentSettingModel.value.payStack!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.payStack.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side:
                                      BorderSide(color: controller.payStack.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayStack",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = true.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId =
                                    controller.paymentSettingModel.value.payStack!.idPaymentMethod.toString().obs;
                                Get.back();
                              },
                              selected: controller.payStack.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/paystack.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayStack".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.flutterWave != null &&
                                controller.paymentSettingModel.value.flutterWave!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.flutterWave.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.flutterWave.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "FlutterWave",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = true.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value =
                                    controller.paymentSettingModel.value.flutterWave!.idPaymentMethod.toString();
                                Get.back();
                              },
                              selected: controller.flutterWave.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/flutterwave.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("FlutterWave".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.razorpay != null &&
                                controller.paymentSettingModel.value.razorpay!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.razorPay.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side:
                                      BorderSide(color: controller.razorPay.value ? ConstantColors.primary : Colors.transparent)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "RazorPay",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = true.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value =
                                    controller.paymentSettingModel.value.razorpay!.idPaymentMethod.toString();
                                Get.back();
                              },
                              selected: controller.razorPay.value,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                                        child:
                                            SizedBox(width: 80, height: 35, child: Image.asset("assets/images/razorpay_@3x.png")),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("RazorPay".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payFast != null &&
                                controller.paymentSettingModel.value.payFast!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.payFast.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side:
                                      BorderSide(color: controller.payFast.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayFast",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = true.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value =
                                    controller.paymentSettingModel.value.payFast!.idPaymentMethod.toString();
                                Get.back();
                              },
                              selected: controller.payFast.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/payfast.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Pay Fast".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.paytm != null &&
                                controller.paymentSettingModel.value.paytm!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.payTm.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: controller.payTm.value ? ConstantColors.primary : Colors.transparent)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayTm",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = true.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value =
                                    controller.paymentSettingModel.value.paytm!.idPaymentMethod.toString();
                                Get.back();
                              },
                              selected: controller.payTm.value,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                                              child: Image.asset(
                                                "assets/images/paytm_@3x.png",
                                              ),
                                            )),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Paytm".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.mercadopago != null &&
                                controller.paymentSettingModel.value.mercadopago!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.mercadoPago.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: controller.mercadoPago.value ? ConstantColors.primary : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "MercadoPago",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = false.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = true.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value =
                                    controller.paymentSettingModel.value.mercadopago!.idPaymentMethod.toString();
                                Get.back();
                              },
                              selected: controller.mercadoPago.value,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/mercadopago.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("Mercado Pago".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payPal != null &&
                                controller.paymentSettingModel.value.payPal!.isEnabled == "true"
                            ? true
                            : false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: controller.paypal.value ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: controller.paypal.value ? ConstantColors.primary : Colors.transparent)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayPal",
                              groupValue: controller.paymentMethodType.value,
                              onChanged: (String? value) {
                                controller.stripe = false.obs;
                                controller.wallet = false.obs;
                                controller.cash = false.obs;
                                controller.razorPay = false.obs;
                                controller.payTm = false.obs;
                                controller.paypal = true.obs;
                                controller.payStack = false.obs;
                                controller.flutterWave = false.obs;
                                controller.mercadoPago = false.obs;
                                controller.payFast = false.obs;
                                controller.paymentMethodType.value = value!;
                                controller.paymentMethodId.value =
                                    controller.paymentSettingModel.value.payPal!.idPaymentMethod.toString();
                                Get.back();
                              },
                              selected: controller.paypal.value,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                                              child: Image.asset("assets/images/paypal_@3x.png"),
                                            )),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayPal".tr),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  buildDetails({title, value, Color txtColor = Colors.black}) {
    return Container(
      height: 110,
      decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.9,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: txtColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
