import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // TODO i18n
        child: Text('An error ocurred getting the app settings'.tr),
      ),
    );
  }
}
