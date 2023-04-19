import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/extractors/search.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/models/channel_data.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/screens/channel.dart';
import 'package:songtube/ui/components/channel_image.dart';
import 'package:songtube/ui/components/infinite_scrolling_adapter.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/channel_tile.dart';
import 'package:songtube/ui/tiles/shimmer_tile.dart';
import 'package:songtube/ui/tiles/stream_tile.dart';
import 'package:songtube/ui/ui_utils.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: contentProvider.searchContent != null
        ? _contentList(context)
        : _shimmerList()
    );
  }
  
  Widget _contentList(context) {
    ContentProvider contentProvider = Provider.of(context);
    final list = <dynamic>[...contentProvider.searchContent!.searchPlaylists!, ...contentProvider.searchContent!.searchVideos!];
    return InfiniteScrollingAdapter(
      onReachingEnd: () {
        contentProvider.searchContentLoadNextPage();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentProvider.searchContent!.searchChannels?.isNotEmpty ?? false)
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contentProvider.searchContent!.searchChannels!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    UiUtils.pushRouteAsync(context, ChannelPage(infoItem: contentProvider.searchContent!.searchChannels![index]));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(12).copyWith(bottom: 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: ChannelTile(channel: contentProvider.searchContent!.searchChannels![index])),
                );
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 12).copyWith(bottom: audioHandler.mediaItem.value != null ? (kToolbarHeight*1.6)+24 : 24),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: InfoItemRenderer(
                    infoItem: item,
                    expandItem: true,
                  ),
                );
              } 
            ),
          ],
        ),
      ),
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