import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/media_utils.dart';
import 'package:songtube/internal/models/media_playlist.dart';

class PlaylistArtwork extends StatefulWidget {
  const PlaylistArtwork({
    required this.playlist,
    this.useThumbnail = false,
    this.enableHeroAnimation = true,
    this.fit = BoxFit.cover,
    this.opacity = 0,
    this.color = Colors.transparent,
    this.enableBlur = false,
    this.shadowIntensity = 1,
    this.shadowSpread = 12,
    Key? key}) : super(key: key);
  final MediaPlaylist playlist;
  final bool useThumbnail;
  final bool enableHeroAnimation;
  final BoxFit fit;
  final double opacity;
  final Color color;
  final bool enableBlur;
  final double shadowIntensity;
  final double shadowSpread;
  @override
  State<PlaylistArtwork> createState() => _PlaylistArtworkState();
}

class _PlaylistArtworkState extends State<PlaylistArtwork> {

  void extractArtwork() async {
    await MediaUtils.writeDefaultArtwork(widget.playlist.songs.first.id, widget.playlist.songs.first.modelId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    Widget _body() {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: widget.enableBlur ? 15 : 0, sigmaY: widget.enableBlur ? 15 : 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: widget.shadowSpread,
                offset: const Offset(0,0),
                color: Theme.of(context).shadowColor.withOpacity(0.1*widget.shadowIntensity)
              )
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _image(),
                  Container(
                    color: widget.color.withOpacity(widget.opacity),
                  )
                ],
              ))),
        ),
      );
    }

    if (widget.enableHeroAnimation) {
      return Hero(
        tag: widget.playlist.id,
        child: _body()
      );
    } else {
      return _body();
    }
  }

  Widget _image() {
    final fit = widget.fit;
    if (widget.playlist.artworkPath == null) {
      if (widget.playlist.songs.isNotEmpty) {
        if (widget.useThumbnail) {
          return Image.file(widget.playlist.songs.first.thumbnailPath!, key: ValueKey('${widget.playlist.songs.first.title}pl'), fit: fit, width: double.infinity, height: double.infinity);
        } else {
          final artwork = artworkFile(widget.playlist.songs.first.modelId);
          if (artwork.existsSync()) {
            return Image.file(artworkFile(widget.playlist.songs.first.modelId), key: ValueKey('${widget.playlist.songs.first.title}pl'), fit: fit, width: double.infinity, height: double.infinity);
          } else {
            extractArtwork();
            return Image.asset('assets/images/artworkPlaceholder_big.png', key: ValueKey('${widget.playlist.name}asset'), fit: fit, width: double.infinity, height: double.infinity);
          }
        }
      } else {
        return Image.asset('assets/images/artworkPlaceholder_big.png', key: ValueKey('${widget.playlist.name}asset'), fit: fit, width: double.infinity, height: double.infinity);
      }
    } else {
      return Image.file(File(widget.playlist.artworkPath!), key: ValueKey('${widget.playlist.name}predef'), fit: fit, width: double.infinity, height: double.infinity);
    }
  }

}