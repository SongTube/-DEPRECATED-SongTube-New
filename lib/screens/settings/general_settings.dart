import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:songtube/providers/app_settings.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/components/circular_check_box.dart';
import 'package:songtube/ui/tiles/setting_tile.dart';

import '../../ui/text_styles.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  
  UiProvider get uiProvider => Provider.of(context, listen: false);

  void updateThemeMode({bool system = false}) {
    if (system) {
      if (uiProvider.themeMode != ThemeMode.system) {
        uiProvider.updateThemeMode(ThemeMode.system);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Theme.of(context).brightness
        ));
      } else {
        uiProvider.updateThemeMode(ThemeMode.light);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Theme.of(context).brightness
        ));
      }
    } else {
      if (uiProvider.themeMode == ThemeMode.dark) {
        uiProvider.updateThemeMode(ThemeMode.light);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Theme.of(context).brightness
        ));
      } else {
        uiProvider.updateThemeMode(ThemeMode.dark);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.transparent
        ));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      children: [
        // Use System Theme
        SettingTileCheckbox(
          leadingIcon: LineIcons.brush,
          title: 'Use system theme',
          subtitle: 'Let system override current theme',
          onChange: (_) => updateThemeMode(system: true),
          value: uiProvider.themeMode == ThemeMode.system,
        ),
        const SizedBox(height: 12),
        // Dark mode
        SettingTileCheckbox(
          leadingIcon: LineIcons.moon,
          title: 'Dark mode',
          subtitle: 'Enable/disable dark mode',
          onChange: (_) => updateThemeMode(),
          value: uiProvider.themeMode == ThemeMode.dark,
          enabled: uiProvider.themeMode != ThemeMode.system,
        ),
        const SizedBox(height: 12),
        // Default landing page
        SettingTileDropdown(
          title: 'Landing Page',
          subtitle: 'Change the default landing page when you open the app',
          leadingIcon: LineIcons.home,
          currentValue: landingPageName(AppSettings.defaultLandingPage),
          onChange: (name) {
            if (name == null) {
              return;
            }
            AppSettings.defaultLandingPage = landingPageNameToIndex(name);
            setState(() {});
          },
          items: List.generate(4, (index) {
            return DropdownMenuItem(
              value: landingPageName(index),
              child: Text(landingPageName(index)),
            );
          })
        ),
        // Lock Navigation Bar so it doesnt hide
        const SizedBox(height: 12),
        SettingTileCheckbox(
          title: 'Lock Navigation Bar',
          subtitle: 'Locks the navigation bar from hiding and showing automatically on scroll',
          leadingIcon: LineIcons.lock,
          value: AppSettings.lockNavigationBar,
          onChange: (value) {
            AppSettings.lockNavigationBar = value;
            setState(() {});
          }
        ),
        // Automatic Picture-in-Picture mode
        const SizedBox(height: 12),
        SettingTileCheckbox(
          leadingIcon: Icons.picture_in_picture_alt_outlined,
          title: 'Picture in Picture',
          subtitle: 'Automatically enters PiP mode upon tapping home button while watching a video',
          onChange: (value) => setState(() => AppSettings.enableAutoPictureInPictureMode = value),
          value: AppSettings.enableAutoPictureInPictureMode,
        ),
        // Background Playback (Alpha)
        const SizedBox(height: 12),
        SettingTileCheckbox(
          leadingIcon: LineIcons.playCircle,
          title: 'Background Playback (Alpha)',
          subtitle: 'Toggle background playback feature. Due to plugin limitations, only current video can be played in the background',
          onChange: (value) => setState(() => AppSettings.enableBackgroundPlayback = value),
          value: AppSettings.enableBackgroundPlayback,
        ),
      ],
    );
  }

  // Get landing page name from index
  String landingPageName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Music';
      case 2:
        return 'Downloads';
      case 3:
        return 'Library';
      default:
        return 'Home';
    }
  }

  // Transform landing page name to index
  int landingPageNameToIndex(String name) {
    switch (name) {
      case 'Home':
        return 0;
      case 'Music':
        return 1;
      case 'Downloads':
        return 2;
      case 'Library':
        return 3;
      default:
        return 0;
    }
  }

}