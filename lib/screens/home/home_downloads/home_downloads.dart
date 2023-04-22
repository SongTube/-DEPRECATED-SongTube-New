import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/download_provider.dart';
import 'package:songtube/screens/home/home_downloads/pages/canceled.dart';
import 'package:songtube/screens/home/home_downloads/pages/completed.dart';
import 'package:songtube/screens/home/home_downloads/pages/queue.dart';
import 'package:songtube/ui/rounded_tab_indicator.dart';
import 'package:songtube/ui/text_styles.dart';

class HomeDownloads extends StatefulWidget {
  const HomeDownloads({Key? key}) : super(key: key);

  @override
  State<HomeDownloads> createState() => _HomeDownloadsState();
}

class _HomeDownloadsState extends State<HomeDownloads> with TickerProviderStateMixin {

  // TabBar Controller
  late TabController tabController = TabController(length: 3, vsync: this,
    initialIndex: Provider.of<DownloadProvider>(context, listen: false).queue.isEmpty ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top+8),
          SizedBox(
            height: kToolbarHeight-8,
            child: _appBar()),
          _tabs(),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        // UiUtils.pushRouteAsync(context, const SearchScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        padding: const EdgeInsets.only(left: 16),
        height: kToolbarHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.05),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(Iconsax.search_normal, size: 18),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  enabled: false,
                  style: subtitleTextStyle(context).copyWith(fontWeight: FontWeight.w500),
                  decoration: InputDecoration.collapsed(
                    hintStyle: smallTextStyle(context, opacity: 0.4).copyWith(fontWeight: FontWeight.w500),
                    hintText: 'Search downloads...'),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        )
      ),
    );
  }

  Widget _tabs() {
    return SizedBox(
      height: kToolbarHeight,
      child: TabBar(
        padding: const EdgeInsets.only(left: 8),
        controller: tabController,
        isScrollable: true,
        labelColor: Theme.of(context).textTheme.bodyText1!.color,
        unselectedLabelColor: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.8),
        labelStyle: smallTextStyle(context).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.4),
        unselectedLabelStyle: smallTextStyle(context).copyWith(fontWeight: FontWeight.normal, letterSpacing: 0.4),
        physics: const BouncingScrollPhysics(),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: RoundedTabIndicator(color: Theme.of(context).primaryColor, height: 3, radius: 100, bottomMargin: 0),
        tabs: const [
          // Queue
          Tab(child: Text('Queue')),
          // Completed
          Tab(child: Text('Completed')),
          // Canceled
          Tab(child: Text('Canceled')),
        ],
      ),
    );
  }

  Widget _body() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        controller: tabController,
        children: const [
          // Queue
          DownloadsQueuePage(),
          // Completed
          DownloadsCompletedPage(),
          // Canceled
          DownloadsCanceledPage()
        ]
      ),
    );
  }

}