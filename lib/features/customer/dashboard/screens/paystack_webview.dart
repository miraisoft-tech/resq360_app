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

  void _finish([bool success = true]) {
    if (finished || !mounted) return;
    finished = true;
    Navigator.of(context).pop(success);
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
          forceMaterialTransparency: true,
          backgroundColor: context.appColors.whiteColor,
          title: const GenText('Complete Payment'),
          actions: [
            TextButton(onPressed: _finish, child: const GenText('Done')),
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
              android: AndroidInAppWebViewOptions(),
              ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
            ),
            pullToRefreshController: pullToRefreshController,

            onWebViewCreated: (controller) {
              _controller = controller;
            },

            onLoadStart: (_, url) {
              setState(() => _loading = true);
              final urlStr = url.toString();
              log('the url is now: $urlStr');

              // match by origin + path only, ignore query params
              final uri = Uri.tryParse(urlStr);
              final callbackUri = Uri.tryParse(widget.callbackUrl);

              final isCallback =
                  uri != null &&
                  callbackUri != null &&
                  uri.host == callbackUri.host &&
                  uri.path == callbackUri.path;

              if (isCallback || urlStr.startsWith(widget.callbackUrl)) {
                _finish();
              }
            },

            onLoadStop: (_, _) async {
              await pullToRefreshController.endRefreshing();
              if (mounted) {
                setState(() => _loading = false);
              }
            },

            shouldOverrideUrlLoading: (_, nav) async {
              final url = nav.request.url.toString();
              final uri = Uri.tryParse(url);
              final callbackUri = Uri.tryParse(widget.callbackUrl);

              final isCallback =
                  uri != null &&
                  callbackUri != null &&
                  uri.host == callbackUri.host &&
                  uri.path == callbackUri.path;

              if (isCallback) {
                _finish();
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },

            onReceivedError: (_, _, _) async {
              await pullToRefreshController.endRefreshing();
            },
          ),
        ),
      ),
    );
  }
}
