import 'package:cabme/controller/order_yegasigur_controller.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderYegasigurScreen extends StatelessWidget {
  OrderYegasigurScreen({super.key});

  final controller = Get.put(OrderYegasigurController());

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;

    final double paddingSize = screenHeight * 0.03;

    print(mediaQuery.orientation);
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
                  onTap: () => controller.onOrderYegasigurButtonPressed(),
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
                    '#6545',
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
