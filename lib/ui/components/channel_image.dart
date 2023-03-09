import 'dart:io';

import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:songtube/services/content_service.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:transparent_image/transparent_image.dart';

class ChannelImage extends StatelessWidget {
  const ChannelImage({
    required this.channelUrl,
    required this.heroId,
    this.expand = false,
    super.key});
  final String? channelUrl;
  final String heroId;
  final bool expand;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: ContentService.channelAvatarPictureFile(channelUrl!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              // Navigator.push(context, TODO
              //   BlurPageRoute(
              //     blurStrength: Provider.of<PreferencesProvider>
              //       (context, listen: false).enableBlurUI ? 20 : 0,
              //     builder: (_) => 
              //     YoutubeChannelPage(
              //       url: infoItem.uploaderUrl,
              //       name: infoItem.uploaderName,
              //       lowResAvatar: snapshot.data,
              //       heroTag: infoItem.uploaderUrl + infoItem.id,
              // )));
            },
            child: Hero(
              tag: "$channelUrl + $heroId",
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(0,0),
                      color: Theme.of(context).shadowColor.withOpacity(0.1)
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 300),
                    placeholder: MemoryImage(kTransparentImage),
                    image: FileImage(snapshot.data!),
                    fit: BoxFit.cover,
                    height: expand ? 80 : 50,
                    width: expand ? 80 : 50,
                  ),
                ),
              ),
            ),
          );
        } else {
          return ShimmerContainer(
            height: expand ? 80 : 50,
            width: expand ? 80 : 50,
            borderRadius: BorderRadius.circular(100),
          );
        }
      },
    );
  }
}