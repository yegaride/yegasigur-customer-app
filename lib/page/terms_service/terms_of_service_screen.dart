import 'package:cabme/controller/terms_of_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TermsOfServiceController>(
        init: TermsOfServiceController(),
        builder: (controller) {
          return SafeArea(
            child: Scaffold(
              body: Stack(
                children: [
                  Container(
                    color: Colors.white,
                    height: 60,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: controller.data != null
                        ? SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Html(
                                data: controller.data,
                              ),
                            ),
                          )
                        : const Offstage(),
                  ),
                  const _BackButton(),
                ],
              ),
            ),
          );
        });
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 3, bottom: 20),
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
    );
  }
}
