import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/screens/settings/customization_settings.dart';
import 'package:songtube/screens/settings/download_settings.dart';
import 'package:songtube/screens/settings/general_settings.dart';
import 'package:songtube/screens/settings/music_player_settings.dart.dart';
import 'package:songtube/ui/rounded_tab_indicator.dart';
import 'package:songtube/ui/text_styles.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> with TickerProviderStateMixin {

  // TabBar Controller
  late TabController tabController = TabController(length: 3, vsync: this);

  final List<Widget> pages = const [
    GeneralSettings(),
    // CustomizationSettings(),
    DownloadSettings(),
    MusicPlayerSettings()
  ];
  
  Widget _tabs() {
    return SizedBox(
      height: kToolbarHeight,
      child: TabBar(
        padding: const EdgeInsets.only(left: 8),
        controller: tabController,
        isScrollable: true,
        labelColor: Theme.of(context).textTheme.bodyText1!.color,
        unselectedLabelColor: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.8),
        labelStyle: smallTextStyle(context).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0),
        unselectedLabelStyle: smallTextStyle(context).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0),
        physics: const BouncingScrollPhysics(),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Theme.of(context).textTheme.bodyText1!.color,
        indicator: RoundedTabIndicator(color: Theme.of(context).textTheme.bodyText1!.color!, height: 4, radius: 100, bottomMargin: 0),
        tabs: const [
          // General Settings
          Tab(child: Text('General')),
          // Customization Settings
          // Tab(child: Text('Customization')),
          // Download Settings
          Tab(child: Text('Downloads')),
          // Music Player Settings
          Tab(child: Text('Music Player')),
        ],
      ),
    );
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
                    "Settings",
                    style: textStyle(context)
                  ),
                ),
              ],
            ),
          ),
          _tabs(),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              controller: tabController,
              children: pages
            ),
          ),
        ],
      ),
    );
  }
}