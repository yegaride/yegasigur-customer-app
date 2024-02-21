import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:get/get.dart';

class OrderYegasigurController extends GetxController {
  void onOrderYegasigurButtonPressed() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      await Future.delayed(const Duration(seconds: 2));

      ShowToastDialog.closeLoader();
    } catch (e) {
      //
    }
  }
}
