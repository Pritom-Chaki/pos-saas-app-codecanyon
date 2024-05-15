import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nb_utils/nb_utils.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key, required this.url, required this.onSuccess, required this.onError});
  final String url;
  final Function onSuccess;
  final Function onError;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse("${widget.url}?start=true")),
          onWebViewCreated: (InAppWebViewController controller) {
          },
          onLoadStart: (InAppWebViewController? controller, Uri? url) async{
            print((url!.origin + url.path + url.query));
            if((url.origin + url.path + url.query) == widget.url) {
              toast("Payment Success");
              widget.onSuccess.call();
            }else if((url.origin + url.path + url.query).contains("/completion")) {
              toast("Payment Failed");
              widget.onError.call();
            }
          },
          onLoadStop: (InAppWebViewController ?controller, Uri? url) {

          },
          onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
            print("console message: ${consoleMessage.message}");
          },
        ),
      ),
    );
  }
}