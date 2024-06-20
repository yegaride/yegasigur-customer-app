// ignore_for_file: file_names, must_be_immutable, depend_on_referenced_packages

import 'package:cabme/service/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CxpayScreen extends StatefulWidget {
  const CxpayScreen({
    super.key,
    required this.amount,
  });

  final String amount;

  @override
  State<CxpayScreen> createState() => _CxpayScreenState();
}

class _CxpayScreenState extends State<CxpayScreen> {
  RegExp regExp = RegExp(r'=(\d+)');
  late WebViewController webViewController;

  double webProgress = 0;

  @override
  void initState() {
    super.initState();
    initWebViewController();
  }

  void initWebViewController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(onProgress: (progress) {
        setState(() {
          webProgress = progress / 100;
        });
      }, onNavigationRequest: (NavigationRequest request) async {
        if (request.url.contains('payment-success')) {
          final match = regExp.allMatches(request.url);
          String transactionId = match.isNotEmpty ? match.first.group(1)! : '';
          print("$transactionId 👈🏻👈🏻👈🏻");

          Get.back(result: true);
        }

        return NavigationDecision.navigate;
      }))
      ..loadRequest(
        Uri.parse('${API.host}/payments?amount=${widget.amount}'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        _showMyDialog(context);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // TODO i18n
            title: const Text('Credit Card Payment'),
          ),
          body: Column(
            children: [
              if (webProgress < 1)
                SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(value: webProgress),
                ),
              Expanded(
                child: WebViewWidget(controller: webViewController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // TODO i18n
          title: const Text('Cancel Payment'),
          content: const SingleChildScrollView(
            // TODO i18n
            child: Text('Are you want to cancel Payment?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                // TODO i18n
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                // TODO i18n
                'Continue',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
