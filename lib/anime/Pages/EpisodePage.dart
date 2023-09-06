import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EpisodePage extends StatefulWidget {

  String url;
  int epNum;
  EpisodePage(this.url,this.epNum);
  @override
  State<EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> {

  WebViewController controller = WebViewController();
  @override
  void initState() {
    super.initState();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(const Color(0x00000000));
    controller.setNavigationDelegate(NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onWebResourceError: (WebResourceError error) {},
    ),
    );
      controller.loadRequest(Uri.parse(widget.url));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Episode ${widget.epNum}'
        ),),
      body: WebViewWidget(controller: controller,),
    );
  }

  @override
  void dispose() {
    super.dispose();

  }
}
