import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloseAppOnConfirmation extends StatefulWidget {
  const CloseAppOnConfirmation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<CloseAppOnConfirmation> createState() => _CloseAppOnConfirmationState();
}

class _CloseAppOnConfirmationState extends State<CloseAppOnConfirmation> {
  DateTime? currentBackPressTime;

  bool closeOnConfirm() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          // TODO i18n
          content: Center(child: Text('Press back button again to exit')),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    currentBackPressTime = null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        if (closeOnConfirm()) SystemNavigator.pop();
      },
      child: widget.child,
    );
  }
}
