import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/app_settings.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/screens/home/home_default/home_default.dart';
import 'package:songtube/screens/home/home_downloads/home_downloads.dart';
import 'package:songtube/screens/home/home_library/home_library.dart';
import 'package:songtube/screens/home/home_music/home_music.dart';
import 'package:songtube/ui/components/bottom_navigation_bar.dart';
import 'package:songtube/ui/components/fancy_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  // Bottom Navigation Bar Current Index
  int bottomNavigationBarIndex = AppSettings.defaultLandingPage;

  final List<Widget> screens = const [
    HomeDefault(),
    HomeMusic(),
    HomeDownloads(),
    HomeLibrary()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Provider.of<MediaProvider>(context, listen: false).fetchMedia();
        if (kDebugMode) {
          print('App resumed');
        }
        break;
      case AppLifecycleState.inactive:
        if (kDebugMode) {
          print('App inactive');
        }
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) {
          print('App paused');
        }
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('App detached');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).brightness
      )
    );
    return FancyScaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            fillColor: Colors.transparent,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        duration: const Duration(milliseconds: 300),
        child: screens[bottomNavigationBarIndex]
      ),
      bottomNavigationBar: SongTubeNavigation(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: bottomNavigationBarIndex,
        backgroundColor: Theme.of(context).cardColor,
        onItemTap: (int tappedIndex) {
          setState(() {
            bottomNavigationBarIndex = tappedIndex;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Ionicons.home_outline),
            selectedIcon: Icon(Ionicons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Ionicons.musical_note_outline),
            selectedIcon: Icon(Ionicons.musical_note, color: Colors.white),
            label: 'Music',
          ),
          NavigationDestination(
            icon: Icon(Ionicons.cloud_download_outline),
            selectedIcon: Icon(Ionicons.cloud_download, color: Colors.white),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Ionicons.library_outline),
            selectedIcon: Icon(Ionicons.library, color: Colors.white),
            label: 'Library',
          ),
        ],
      ),
    );
  }

}