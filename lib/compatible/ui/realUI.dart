import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) 'dart:io';
import 'dart:ui' as ui;

class WebImage extends StatelessWidget {
  String url;
  double width;
  double height;

  WebImage(this.url, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    // return Container(width: width, height: height);
    String _divId = "web_image_${DateTime.now().toIso8601String()}";
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _divId,
          (int viewId) =>
          ImageElement(src: url, width: width.toInt(), height: height.toInt()),
    );
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(
        key: UniqueKey(),
        viewType: _divId,
        onPlatformViewCreated: (id) {},
      ),
    );
  }
}
