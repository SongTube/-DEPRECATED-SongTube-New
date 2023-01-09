import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:songtube/internal/global.dart';

class BackgroundCarousel extends StatefulWidget {
  const BackgroundCarousel({
    Key? key }) : super(key: key);

  @override
  State<BackgroundCarousel> createState() => _BackgroundCarouselState();
}

class _BackgroundCarouselState extends State<BackgroundCarousel> {

  @override
  void initState() {
    audioHandler.mediaItem.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final song = audioHandler.mediaItem.value;
    return Transform.scale(
      scale: 1.1,
      child: ImageFade(
        fadeDuration: const Duration(milliseconds: 600),
        image: FileImage(File(song!.artUri.toString()
          .replaceAll('file://', '')
          .replaceAll('file//', ''))),
        fit: BoxFit.cover,
      ),
    );
  }
}