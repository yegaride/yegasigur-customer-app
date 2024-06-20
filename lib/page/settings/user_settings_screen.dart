import 'package:cabme/page/coupon_code/coupon_code_screen.dart';
import 'package:cabme/page/localization_screens/localization_screen.dart';
import 'package:cabme/page/privacy_policy/privacy_policy_screen.dart';
import 'package:cabme/page/referral_screen/referral_screen.dart';
import 'package:cabme/page/terms_service/terms_of_service_screen.dart';
import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            _SettingsItem(
              icon: Icons.language,
              title: 'change_language'.tr,
              // TODO i18n
              subTitle: 'Change your app\'s language',
              onTap: () {
                Get.to(
                  const LocalizationScreens(intentType: "dashBoard"),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            _SettingsItem(
              icon: Icons.design_services,
              title: 'term_service'.tr,
              // TODO i18n
              subTitle: 'Read our terms of use',
              onTap: () {
                Get.to(
                  const TermsOfServiceScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            _SettingsItem(
              icon: Icons.privacy_tip,
              title: 'privacy_policy'.tr,
              // TODO i18n
              subTitle: 'Commitment to your privacy',
              onTap: () {
                Get.to(
                  const PrivacyPolicyScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            _SettingsItem(
              icon: Icons.people_sharp,
              title: 'refer_a_friend'.tr,
              // TODO i18n
              subTitle: 'Make money referring friends',
              onTap: () {
                Get.to(
                  const ReferralScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            _SettingsItem(
              icon: Icons.discount,
              title: 'promo_code'.tr,
              // TODO i18n
              subTitle: 'Register your promo code!',
              onTap: () {
                Get.to(
                  const CouponCodeScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: ListTile(
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: ConstantColors.primary.withOpacity(0.08), borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(icon, size: 20, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          subtitle: Text(subTitle),
          onTap: onTap,
        ),
      ),
    );
  }
}
