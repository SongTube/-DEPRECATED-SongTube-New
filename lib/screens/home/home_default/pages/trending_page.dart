import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/channel_data.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/ui/components/channel_image.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/shimmer_tile.dart';
import 'package:songtube/ui/tiles/stream_tile.dart';

class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: contentProvider.trendingVideos != null
        ? _trendingList(context)
        : _shimmerList()
    );
  }
  
  Widget _trendingList(context) {
    ContentProvider contentProvider = Provider.of(context);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 12),
              scrollDirection: Axis.horizontal,
              itemCount: contentProvider.channelSuggestions.length,
              itemBuilder: (context, index) {
                final channel = contentProvider.channelSuggestions[index];
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  height: 120,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ChannelImage(channelUrl: channel.url, heroId: channel.heroId, expand: true),
                      const SizedBox(height: 8),
                      Text(channel.name, style: tinyTextStyle(context).copyWith(fontWeight: FontWeight.w600), maxLines: 1, textAlign: TextAlign.center)
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            child: Text('Recent Videos', style: subtitleTextStyle(context, opacity: 0.8).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final video = contentProvider.trendingVideos![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InfoItemRenderer(
                infoItem: video,
                expandItem: true,
              ),
            );
          }, childCount: contentProvider.trendingVideos!.length),
        )
      ],
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 20,
      padding: const EdgeInsets.only(top: 12),
      itemBuilder: (context, index) {
        return const ShimmerTile();
      },
    );
  }

}