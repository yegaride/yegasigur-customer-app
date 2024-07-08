import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/phone_number_controller.dart';
import 'package:cabme/page/auth_screens/login_screen.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/utils/close_app_on_confirmation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key, required this.isLogin});

  final bool isLogin;

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final controller = Get.put(PhoneNumberController());

  late bool _isLogin;

  @override
  void initState() {
    super.initState();

    _isLogin = widget.isLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.background,
      body: CloseAppOnConfirmation(
        child: SafeArea(
          child: Container(
            height: Get.height,
            decoration: const BoxDecoration(
              color: ConstantColors.fucsia,
              // image: DecorationImage(
              //   image: AssetImage(
              //     "assets/images/login_bg.png",
              //   ),
              //   fit: BoxFit.cover,
              // ),
            ),
            child: Stack(
              children: [
                Center(
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLogin
                                ? Text(
                                    // TODO i18n
                                    key: const Key('login'),
                                    "Login Phone".tr,
                                    style: const TextStyle(
                                      letterSpacing: 0.60,
                                      fontSize: 22,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Text(
                                    // TODO i18n
                                    key: const Key('signUp'),
                                    "Signup Phone".tr,
                                    style: const TextStyle(
                                      letterSpacing: 0.60,
                                      fontSize: 22,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          SizedBox(
                              width: 80,
                              child: Divider(
                                color: ConstantColors.yellow1,
                                thickness: 3,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: ConstantColors.textFieldBoarderColor,
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(6))),
                              padding: const EdgeInsets.only(left: 10),
                              child: IntlPhoneField(
                                initialCountryCode: 'AW',
                                onChanged: (phone) {
                                  controller.phoneNumber.value = phone.completeNumber;
                                },
                                invalidNumberMessage: "number invalid",
                                showDropdownIcon: false,
                                disableLengthCheck: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  hintText: 'Phone Number'.tr,
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Continue'.tr,
                                btnHeight: 50,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white,
                                onPress: () async {
                                  FocusScope.of(context).unfocus();
                                  if (controller.phoneNumber.value.isNotEmpty) {
                                    ShowToastDialog.showLoader("Code sending".tr);
                                    controller.sendCode(controller.phoneNumber.value);
                                  }
                                },
                              )),
                          Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Login With Email'.tr,
                                btnHeight: 50,
                                btnColor: ConstantColors.yellow,
                                txtColor: Colors.white,
                                onPress: () {
                                  FocusScope.of(context).unfocus();
                                  Get.to(
                                    LoginScreen(),
                                    duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
                                    transition: Transition.rightToLeft,
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                // if (!_isLogin)
                //   Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: GestureDetector(
                //       onTap: () {
                //         Get.back();
                //       },
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(30),
                //           color: Colors.white,
                //           boxShadow: <BoxShadow>[
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.3),
                //               blurRadius: 10,
                //               offset: const Offset(0, 2),
                //             ),
                //           ],
                //         ),
                //         child: const Padding(
                //           padding: EdgeInsets.all(8),
                //           child: Icon(
                //             Icons.arrow_back_ios_rounded,
                //             color: Colors.black,
                //           ),
                //         ),
                //       ),
                //     ),
                //   )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: '${'You don’t have an account yet? '.tr} ',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                ),
                TextSpan(
                  text: 'SIGNUP'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: ConstantColors.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
