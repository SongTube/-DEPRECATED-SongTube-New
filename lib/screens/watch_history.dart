import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:songtube/internal/cache_utils.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/text_styles.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({
    super.key});

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  // Remove Item
  void removeItem(dynamic infoItem) async {
    final index = CacheUtils.watchHistory.indexWhere((element) => element.id == infoItem.id);
    listKey.currentState!.removeItem(index, (context, animation) {
      return _animation(context, infoItem, animation);
    }, duration: const Duration(milliseconds: 300));
    ContentProvider.removeFromHistory(CacheUtils.watchHistory[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Iconsax.arrow_left, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Watch History",
                    style: textStyle(context)
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: AnimatedList(
              key: listKey,
              padding: const EdgeInsets.only(top: 12),
              physics: const BouncingScrollPhysics(),
              initialItemCount: CacheUtils.watchHistory.length,
              itemBuilder: (context, index, animation) {
                final item = CacheUtils.watchHistory[index];
                return _animation(context, item, animation);
              },
            )
          )
        ],
      ),
    );
  }

  Widget _animation(BuildContext context, dynamic item, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.ease,
        reverseCurve: Curves.ease)
      ),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastLinearToSlowEaseIn,
          reverseCurve: Curves.fastLinearToSlowEaseIn)
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: InfoItemRenderer(
            key: ValueKey(item.id),
            infoItem: item, expandItem: true, onDelete: () => removeItem(item)),
        ),
      ),
    );
  }

}