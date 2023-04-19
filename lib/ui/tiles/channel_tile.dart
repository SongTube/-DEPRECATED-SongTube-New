import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:songtube/ui/components/shimmer_container.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/ui_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class ChannelTile extends StatelessWidget {
  const ChannelTile({
    required this.channel,
    super.key});
  final ChannelInfoItem channel;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<String?>(
          future: UiUtils.getAvatarUrl(channel.name!, channel.url!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FadeInImage(
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(File(snapshot.data!)),
                  height: 80,
                  width: 80,
                ),
              );
            } else {
              return ShimmerContainer(
                height: 80,
                width: 80,
                borderRadius: BorderRadius.circular(100),
              );
            }
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.name ?? '',
                style: subtitleTextStyle(context, bold: true),
                maxLines: 2,
              ),
              Text(
                channel.subscriberCount != -1 ? "${NumberFormat().format(channel.subscriberCount)} Subs • " : '' '${channel.streamCount} videos',
                style: smallTextStyle(context, opacity: 0.8)
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ],
    );
  }
}