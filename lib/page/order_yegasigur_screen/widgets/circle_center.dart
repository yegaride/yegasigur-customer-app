import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CircleCenter extends StatelessWidget {
  const CircleCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      splashColor: const Color.fromARGB(255, 107, 17, 103),
      onTap: () {
        print('Botón presionado');
      },
      child: Ink(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ConstantColors.primary,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Yega\nSigur',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '.com',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
