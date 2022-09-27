import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/media_utils.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ArtworkCarousel extends StatefulWidget {
  const ArtworkCarousel({
    required this.onSwitchSong,
    required this.animationController,
    Key? key }) : super(key: key);
  final Function(int) onSwitchSong;
  final AnimationController animationController;

  @override
  State<ArtworkCarousel> createState() => _ArtworkCarouselState();
}

class _ArtworkCarouselState extends State<ArtworkCarousel> {

  MediaProvider get mediaProvider => Provider.of(context, listen: false);
  SongItem get song => mediaProvider.songs.firstWhere((element) => element.id == audioHandler.mediaItem.value!.id);

  @override
  void initState() {
    audioHandler.mediaItem.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  // Image Getter
  Future<File> getAlbumImage() async {
    if (await artworkFile(song.id).exists()) {
      return artworkFile(song.id);
    } else {
      await MediaUtils.writeDefaultArtwork(song.id, song.modelId);
      return artworkFile(song.modelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.all(Tween<double>(begin: 14, end: 32).animate(widget.animationController).value),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Tween<double>(begin: 20, end: 25).animate(widget.animationController).value),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0,0),
                  color: Theme.of(context).shadowColor.withOpacity(0.2)
                )
              ],
            ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Tween<double>(begin: 20, end: 25).animate(widget.animationController).value),
            child: child
          ),
        );
      },
      child: FutureBuilder<File>(
        future: getAlbumImage(),
        builder: (context, snapshot) {
          return ImageFade(
            placeholder: const SizedBox(),
            image: snapshot.hasData
              ? FileImage(snapshot.data!)
              : MemoryImage(kTransparentImage) as ImageProvider,
            fit: BoxFit.cover,
          );
        }
      ),
    );
  }
}