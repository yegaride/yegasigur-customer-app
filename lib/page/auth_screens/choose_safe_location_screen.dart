// ignore_for_file: prefer_const_constructors

import 'package:cabme/constant/constant.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseSafeLocationScreen extends StatelessWidget {
  const ChooseSafeLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColors.fucsia,
        body: Placeholder(),
      ),
    );
  }
}
