// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/sign_up_controller.dart';
import 'package:cabme/page/safe_location/choose_safe_location_screen.dart';
import 'package:cabme/page/auth_screens/login_screen.dart';
import 'package:cabme/themes/button_them.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:cabme/themes/text_field_them.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  String? phoneNumber;

  SignupScreen({super.key, required this.phoneNumber});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  var _phoneController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  final _referralCodeController = TextEditingController();

  String? _gender;

  String? _transmisionType;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  // final _addressController = TextEditingController();
  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    _phoneController = TextEditingController(text: widget.phoneNumber);
    return Scaffold(
      backgroundColor: ConstantColors.fucsia,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: SignupScreen._formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/appIcon-130.png",
                          width: 130,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Sign up".tr.toUpperCase(),
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
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Name'.tr,
                                controller: _firstNameController,
                                textInputType: TextInputType.text,
                                maxLength: 22,
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
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Last Name'.tr,
                                controller: _lastNameController,
                                textInputType: TextInputType.text,
                                maxLength: 22,
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
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: DropdownButtonFormField(
                            key: const Key('gender'),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 8),
                              errorStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            // isExpanded: true,
                            hint: Text(
                              'gender'.tr,
                              style: const TextStyle(height: 1.8),
                            ),
                            value: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                            items: ['male', 'female'].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.tr,
                                  style: const TextStyle(height: 1.8),
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (_gender == null) {
                                return 'required'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'phone'.tr,
                            controller: _phoneController,
                            textInputType: TextInputType.number,
                            maxLength: 13,
                            enabled: false,
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
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'email'.tr,
                            controller: _emailController,
                            textInputType: TextInputType.emailAddress,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
                              if (!emailValid) {
                                return 'email not valid'.tr;
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: DropdownButtonFormField(
                            key: const Key('transmissionType'),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 8),
                              errorStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            isExpanded: true,
                            hint: Text(
                              'transmissionType'.tr,
                              style: const TextStyle(height: 1.8),
                            ),
                            value: _transmisionType,
                            onChanged: (value) {
                              setState(() {
                                _transmisionType = value;
                              });
                            },
                            items: ['automatic', 'standart'].map(
                              (e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e.tr,
                                    style: const TextStyle(height: 1.8),
                                  ),
                                );
                              },
                            ).toList(),
                            validator: (value) {
                              if (_transmisionType == null) {
                                return 'required'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 16),
                        //   child: TextFieldThem.boxBuildTextField(
                        //     hintText: 'address'.tr,
                        //     controller: _addressController,
                        //     textInputType: TextInputType.text,
                        //     contentPadding: EdgeInsets.zero,
                        //     validators: (String? value) {
                        //       if (value!.isNotEmpty) {
                        //         return null;
                        //       } else {
                        //         return 'required'.tr;
                        //       }
                        //     },
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'password'.tr,
                            controller: _passwordController,
                            textInputType: TextInputType.text,
                            obscureText: false,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.length >= 6) {
                                return null;
                              } else {
                                return 'Password required at least 6 characters'.tr;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'confirm_password'.tr,
                            controller: _confirmPasswordController,
                            textInputType: TextInputType.text,
                            obscureText: false,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (_passwordController.text != value) {
                                return 'Confirm password is invalid'.tr;
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 16),
                        //   child: TextFieldThem.boxBuildTextField(
                        //     hintText: 'Referral Code (Optional)'.tr,
                        //     controller: _referralCodeController,
                        //     textInputType: TextInputType.text,
                        //     contentPadding: EdgeInsets.zero,
                        //   ),
                        // ),
                        Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'Continue'.tr,
                              btnHeight: 45,
                              btnColor: ConstantColors.primary,
                              txtColor: Colors.white,
                              onPress: () async {
                                FocusScope.of(context).unfocus();

                                if (SignupScreen._formKey.currentState!.validate()) {
                                  Map<String, String> bodyParams = {
                                    'firstname': _firstNameController.text.trim().toString(),
                                    'lastname': _lastNameController.text.trim().toString(),
                                    'gender': _gender!,
                                    'phone': _phoneController.text.trim(),
                                    'car_transmission_type': _transmisionType!,
                                    'email': _emailController.text.trim(),
                                    'password': _passwordController.text,
                                    'referral_code': _referralCodeController.text.toString(),
                                    // 'address': _addressController.text,
                                    'login_type': 'phone',
                                    'tonotify': 'yes',
                                    'account_type': 'customer',
                                  };

                                  await controller.signUp(bodyParams).then((value) {
                                    if (value != null) {
                                      if (value.success == "success") {
                                        Preferences.setInt(Preferences.userId, int.parse(value.data!.id.toString()));
                                        Preferences.setString(Preferences.user, jsonEncode(value));
                                        Get.to(const ChooseSafeLocationScreen());
                                        // Get.to(AddProfilePhotoScreen());
                                      } else {
                                        ShowToastDialog.showToast(value.error);
                                      }
                                    }
                                  });
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black,
                      ),
                    )),
              ),
            )
          ],
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
                    text: 'Already have an account? '.tr,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll(LoginScreen(),
                            duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
                            transition: Transition.rightToLeft); //transition effect);
                      },
                  ),
                  TextSpan(
                    text: 'login'.tr.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: ConstantColors.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll(LoginScreen(),
                            duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
                            transition: Transition.rightToLeft); //transition effect);
                      },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
