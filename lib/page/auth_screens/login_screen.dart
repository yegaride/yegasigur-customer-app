import 'dart:convert';

import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/login_conroller.dart';
import 'package:cabme/page/auth_screens/add_profile_photo_screen.dart';
// import 'package:cabme/page/auth_screens/forgot_password.dart';
import 'package:cabme/page/dash_board.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/themes/text_field_them.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  static final _phoneController = TextEditingController();
  static final _passwordController = TextEditingController();
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColors.background,
        body: Container(
          decoration: const BoxDecoration(
            color: ConstantColors.fucsia,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/appIcon-130.png",
                      width: 130,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Login with Email".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        letterSpacing: 0.60,
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        width: 80,
                        child: Divider(
                          color: ConstantColors.yellow1,
                          thickness: 3,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFieldThem.boxBuildTextField(
                              hintText: 'email'.tr,
                              controller: _phoneController,
                              textInputType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              contentPadding: EdgeInsets.zero,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'password'.tr,
                                controller: _passwordController,
                                textInputType: TextInputType.text,
                                obscureText: true,
                                contentPadding: EdgeInsets.zero,
                                validators: (String? value) {
                                  if (value!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return 'required'.tr;
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: ButtonThem.buildButton(
                                  context,
                                  title: 'log in'.tr,
                                  btnHeight: 50,
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white,
                                  onPress: () async {
                                    FocusScope.of(context).unfocus();
                                    if (_loginFormKey.currentState!.validate()) {
                                      Map<String, String> bodyParams = {
                                        'email': _phoneController.text.trim(),
                                        'mdp': _passwordController.text,
                                        'user_cat': "customer",
                                      };

                                      await controller.loginAPI(bodyParams).then((value) {
                                        if (value != null) {
                                          if (value.success == "Success") {
                                            Preferences.setInt(Preferences.userId, int.parse(value.data!.id.toString()));
                                            Preferences.setString(Preferences.user, jsonEncode(value));
                                            _phoneController.clear();
                                            _passwordController.clear();
                                            if (value.data!.photo == null || value.data!.photoPath.toString().isEmpty) {
                                              Get.to(() => AddProfilePhotoScreen());
                                            } else {
                                              Preferences.setBoolean(Preferences.isLogin, true);
                                              Get.offAll(
                                                const DashBoard(),
                                                duration: const Duration(milliseconds: 400),
                                                //duration of transitions, default 1 sec
                                                transition: Transition.rightToLeft,
                                              );
                                            }
                                          } else {
                                            ShowToastDialog.showToast(value.error);
                                          }
                                        }
                                      });
                                    }
                                  },
                                )),
                            //TODO: forgot password
                            // GestureDetector(
                            //   onTap: () {
                            //     Get.to(ForgotPasswordScreen(),
                            //         duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
                            //         transition: Transition.rightToLeft);
                            //   },
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(top: 20),
                            //     child: Center(
                            //       child: Text(
                            //         "forgot".tr,
                            //         style: TextStyle(color: ConstantColors.primary, fontWeight: FontWeight.w600),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: ButtonThem.buildBorderButton(
                                context,
                                // TODO i18n
                                title: 'Continue with phone number',
                                btnHeight: 50,
                                btnColor: Colors.white,
                                txtColor: ConstantColors.primary,
                                onPress: () {
                                  FocusScope.of(context).unfocus();
                                  Get.back();
                                },
                                btnBorderColor: ConstantColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
