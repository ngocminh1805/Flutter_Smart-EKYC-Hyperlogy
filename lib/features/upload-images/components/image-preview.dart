import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  final String path;
  ImagePreview({this.path});

  @override
  _ImagePreView createState() => _ImagePreView();
}

class _ImagePreView extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(image: FileImage(File(widget.path), scale: 2.5)),
    );
  }
}
