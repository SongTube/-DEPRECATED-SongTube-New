import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:songtube/internal/cache_utils.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/text_styles.dart';

class WatchHistoryPage extends StatelessWidget {
  const WatchHistoryPage({
    super.key});
  @override
  Widget build(BuildContext context) {
    final List<dynamic> infoItems = CacheUtils.watchHistory;
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
            child: ListView.builder(
              itemCount: infoItems.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 12),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: InfoItemRenderer(infoItem: infoItems[index], expandItem: true),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}