import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/dash_board_controller.dart';
import 'package:cabme/controller/new_ride_controller.dart';
import 'package:cabme/controller/order_yegasigur_controller.dart';
import 'package:cabme/page/route_view_screen/route_view_screen.dart';
import 'package:cabme/routes/routes.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/themes/custom_alert_dialog.dart';
import 'package:cabme/themes/custom_dialog_box.dart';
// import 'package:cabme/themes/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderYegasigurScreen extends StatefulWidget {
  const OrderYegasigurScreen({super.key});

  @override
  State<OrderYegasigurScreen> createState() => _OrderYegasigurScreenState();
}

class _OrderYegasigurScreenState extends State<OrderYegasigurScreen> {
  final controller = Get.put(OrderYegasigurController());

  @override
  void dispose() {
    Get.delete<OrderYegasigurController>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;

    final double paddingSize = screenHeight * 0.03;

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Text(
          '© Copyright 2024 MSA.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            height: 3,
            fontSize: 12,
            color: ConstantColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: ConstantColors.fucsia,
        body: Stack(
          children: [
            Center(
              child: Image.asset('assets/images/yegasigur-button.png'),
            ),
            Container(
              color: ConstantColors.primary,
              height: 7,
              width: double.infinity,
            ),
            Center(
              child: ClipPath(
                clipper: _CustomGesture(substractPixels: 0),
                child: GestureDetector(
                  onTap: () => {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomAlertDialog(
                          // TODO: i18n
                          title: "Are you sure you want to order yegasigur?",
                          onPressNegative: () => Get.back(),
                          onPressPositive: () async {
                            if (controller.isLoading.value) return;
                            final res = await controller.orderYegaSigur();

                            if (!context.mounted) return;

                            if (controller.insufficientBalance) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: 'Insufficient balance',
                                    descriptions:
                                        'Your wallet does not have enough balance for this ride \n\nPlease add money to your wallet to continue.',
                                    img: Image.asset('assets/images/walltet_history.png', width: 128),
                                    onPress: () {
                                      Get.back();
                                      Get.back();
                                      Get.put(DashBoardController()).onRouteSelected(Routes.wallet);
                                    },
                                  );
                                },
                              );
                              return;
                            }

                            if (res == null) return;

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogBox(
                                  // TODO: i18n
                                  title: "Yegasigur requested successfully",
                                  // TODO: i18n
                                  descriptions: "You will be notified when a driver accepts your request",
                                  onPress: () {
                                    Get.back();
                                    Get.back();
                                    final controllerDashBoard = Get.put(DashBoardController());

                                    ShowToastDialog.showLoader("Please wait");
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
                                        final newRideController = Get.put(NewRideController());

                                        newRideController.getNewRide().then((value) {
                                          controllerDashBoard.onRouteSelected(Routes.allRides);
                                          final lastRide = newRideController.rideList.first;

                                          var argumentData = {
                                            'type': 'new',
                                            'data': lastRide,
                                          };

                                          ShowToastDialog.closeLoader();
                                          Get.to(() => const RouteViewScreen(), arguments: argumentData);
                                        }).catchError((e) => ShowToastDialog.closeLoader());
                                      },
                                    );
                                  },
                                  img: Image.asset('assets/images/green_checked.png'),
                                );
                              },
                            );
                          },
                        );
                      },
                    )
                  },
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 30,
              child: Row(
                children: [
                  Text(
                    'Cust. ',
                    style: GoogleFonts.poppins(
                      height: 3,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "#${Constant.getUserData().data!.custNumber}",
                    style: GoogleFonts.poppins(
                      height: 3,
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (Orientation.landscape != mediaQuery.orientation)
              Positioned(
                left: 0,
                right: 0,
                bottom: paddingSize,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Order YegaSigur Now \n and',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Get Home Safe!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: ConstantColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _CustomGesture extends CustomClipper<Path> {
  _CustomGesture({
    required this.substractPixels,
  });

  final double substractPixels;

  @override
  getClip(Size size) {
    Path path = Path();

    double radius = size.width / 2 - substractPixels;
    path.moveTo(size.width / 2, size.height / 2);
    path.addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}
