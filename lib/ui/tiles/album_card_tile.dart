import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:image_fade/image_fade.dart';
import 'package:ionicons/ionicons.dart';
import 'package:songtube/internal/album_utils.dart';
import 'package:songtube/internal/artwork_manager.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/media_utils.dart';
import 'package:songtube/internal/models/media_item_models.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:transparent_image/transparent_image.dart';

class AlbumCardTile extends StatefulWidget {
  const AlbumCardTile({
    required this.album,
    required this.onTap,
    this.height = 100,
    this.width = 100,
    this.showDetails = false,
    Key? key }) : super(key: key);
  final MediaItemAlbum album;
  final double height;
  final double width;
  final bool showDetails;
  final Function(MediaItemAlbum) onTap;

  @override
  State<AlbumCardTile> createState() => _AlbumCardTileState();
}

class _AlbumCardTileState extends State<AlbumCardTile> {

  // Image Getter
  Future<File> getAlbumImage() async {
    await ArtworkManager.writeArtwork(widget.album.mediaItems.first.id);
    return artworkFile(widget.album.mediaItems.first.id);
  }

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 80),
      onPressed: () {
        widget.onTap(widget.album);
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Album Artwork
            Container(
              height: widget.height,
              width: widget.width,
              margin: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0,0),
                    color: Theme.of(context).shadowColor.withOpacity(0.1)
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FutureBuilder<File>(
                  future: AlbumUtils.getAlbumImageFromSong(widget.album.mediaItems.first.id, widget.album.mediaItems.first.modelId),
                  builder: (context, snapshot) {
                    Widget shimmer() => const ShimmerContainer(height: double.infinity, width: double.infinity);
                    return ImageFade(
                      placeholder: shimmer(),
                      image: snapshot.hasData
                        ? FileImage(snapshot.data!)
                        : MemoryImage(kTransparentImage) as ImageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (context, child, exception) {
                        return shimmer();
                      },
                    );
                  }
                ),
              )
            ),
            // Album Details
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
                  width: double.infinity,
                  height: kToolbarHeight,
                  decoration: BoxDecoration(
                    color: widget.album.mediaItems.first.palette!.dominant!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Album Title
                                Text(
                                  widget.album.albumTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: tinyTextStyle(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.album.mediaItems.first.palette!.text)
                                ),
                                Text(
                                  widget.album.albumAuthor,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: tinyTextStyle(context).copyWith(color: (widget.album.mediaItems.first.palette!.text).withOpacity(0.6))
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Ionicons.albums_outline, color: widget.album.mediaItems.first.palette!.text, size: 16)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}