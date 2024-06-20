// ignore_for_file: must_be_immutable

import 'package:cabme/constant/constant.dart';
import 'package:cabme/controller/dash_board_controller.dart';
import 'package:cabme/routes/routes.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/utils/close_app_on_confirmation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ConstantColors.primary,
      ),
    );
    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        return SafeArea(
          child: CloseAppOnConfirmation(
            child: Scaffold(
              appBar: controller.selectedRoute.value != Routes.wallet && controller.selectedRoute.value != Routes.mapView
                  ? AppBar(
                      backgroundColor: controller.selectedRoute.value == Routes.myProfile ||
                              controller.selectedRoute.value == Routes.orderYegasigur
                          ? ConstantColors.primary
                          : ConstantColors.background,
                      elevation: 0,
                      centerTitle: true,
                      title: controller.selectedRoute.value != Routes.orderYegasigur &&
                              controller.selectedRoute.value != Routes.wallet
                          ? Text(
                              controller.selectedRoute.value.toString().tr,
                              // controller.drawerRoutes.firstWhere((item) => item.route == controller.selectedRoute.value).route.tr,
                              style: TextStyle(
                                color: controller.selectedRoute.value == Routes.myProfile ? Colors.white : Colors.black,
                              ),
                            )
                          : controller.selectedRoute.value == Routes.orderYegasigur
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'YegaSigur',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '.com',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(""),
                      leading: Builder(builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: ConstantColors.primary.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/icons/ic_side_menu.png",
                                  color: Colors.black,
                                )),
                          ),
                        );
                      }),
                    )
                  : null,
              drawer: buildAppDrawer(context, controller),
              body: controller.buildSelectedRoute(controller.selectedRoute.value),
            ),
          ),
        );
      },
    );
  }

  buildAppDrawer(BuildContext context, DashBoardController controller) {
    final List<Widget> drawerRoutes = controller.drawerRoutes.map((route) {
      return ListTile(
        leading: Icon(route.drawerIcon),
        title: Text(route.route.tr),
        selected: route.route == controller.selectedRoute.value,
        onTap: () => controller.onRouteSelected(route.route),
      );
    }).toList();

    return Drawer(
      child: Column(
        // padding: EdgeInsets.zero,
        children: [
          controller.userModel == null
              ? const Center(
                  child: CircularProgressIndicator(color: ConstantColors.primary),
                )
              : UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: ConstantColors.primary,
                  ),
                  currentAccountPicture: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0040096),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: controller.userModel!.data!.photoPath.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  accountName: Text(
                    "${controller.userModel!.data!.prenom} ${controller.userModel!.data!.nom}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  accountEmail: Text(controller.userModel!.data!.email.toString(), style: const TextStyle(color: Colors.white)),
                ),
          // Column(children: drawerOptions),
          Column(children: drawerRoutes),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(Routes.signOut.tr),
            onTap: () => controller.onRouteSelected(Routes.signOut),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
