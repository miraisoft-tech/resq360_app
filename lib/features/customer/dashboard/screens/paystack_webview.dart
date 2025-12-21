// i used the docs from the package website and the had no updated th the new version
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:resq360/__lib.dart';

class PaystackWebViewPage extends StatefulWidget {
  const PaystackWebViewPage({
    required this.authorizationUrl,
    required this.reference,
    required this.callbackUrl,
    super.key,
  });

  final String authorizationUrl;
  final String reference;
  final String callbackUrl;

  @override
  State<PaystackWebViewPage> createState() => _PaystackWebViewPageState();
}

class _PaystackWebViewPageState extends State<PaystackWebViewPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? _controller;
  bool _loading = true;
  double progress = 0;
  bool finished = false;

  late final PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      unawaited(
        AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true),
      );
    }

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: const Color(0xFFE8683B)),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await _controller?.reload();
        } else if (Platform.isIOS) {
          final url = await _controller?.getUrl();
          await _controller?.loadUrl(urlRequest: URLRequest(url: url));
        }
      },
    );
  }

  bool _isCallbackUrl(String? url) {
    if (url == null) return false;
    final lower = url.toLowerCase();
    log('lower $lower');

    if (widget.callbackUrl.isNotEmpty &&
        lower.contains(widget.callbackUrl.toLowerCase())) {
      return true;
    }

    if (lower.contains(widget.reference.toLowerCase())) return true;

    if (lower.contains('success') || lower.contains('close')) return true;

    return false;
  }

  void _finish([bool success = true]) {
    if (finished) return;
    finished = true;
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _finish(false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.appColors.whiteColor,
          title: const Text('Complete Payment'),
          actions: [
            TextButton(
              onPressed: _finish,
              child: const Text('Done'),
            ),
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(widget.authorizationUrl)),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              android: AndroidInAppWebViewOptions(
                // useHybridComposition: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            pullToRefreshController: pullToRefreshController,

            onWebViewCreated: (controller) {
              _controller = controller;
              controller
                ..addJavaScriptHandler(
                  handlerName: 'paystackSuccess',
                  callback: (args) {
                    _finish();
                  },
                )
                ..addJavaScriptHandler(
                  handlerName: 'paystackClose',
                  callback: (args) {
                    _finish(false);
                  },
                );
            },

            onLoadStart: (_, url) {
              setState(() => _loading = true);
              if (_isCallbackUrl(url?.toString())) _finish();
            },
            onLoadStop: (_, url) async {
              await pullToRefreshController.endRefreshing();
              setState(() => _loading = false);

              await _controller?.evaluateJavascript(
                source: """
    (function () {
      window.addEventListener('message', function (e) {
        if (!e.data) return;

        if (e.data.event === 'success') {
          window.flutter_inappwebview.callHandler('paystackSuccess');
        }

        if (e.data.event === 'close') {
          window.flutter_inappwebview.callHandler('paystackClose');
        }
      });
    })();
  """,
              );
            },

            shouldOverrideUrlLoading: (_, nav) async {
              final uri = nav.request.url.toString();

              if (_isCallbackUrl(uri)) {
                _finish();
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },

            onReceivedError: (
              _,
              _,
              _,
            ) async {
              await pullToRefreshController.endRefreshing();
            },
          ),
        ),
      ),
    );
  }
}
