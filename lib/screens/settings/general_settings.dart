import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:songtube/internal/app_settings.dart';
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
          systemNavigationBarColor: Theme.of(context).canvasColor,
          systemNavigationBarIconBrightness: Theme.of(context).brightness
        ));
      } else {
        uiProvider.updateThemeMode(ThemeMode.light);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Theme.of(context).brightness
        ));
      }
    } else {
      if (uiProvider.themeMode == ThemeMode.dark) {
        uiProvider.updateThemeMode(ThemeMode.light);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Theme.of(context).brightness
        ));
      } else {
        uiProvider.updateThemeMode(ThemeMode.dark);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
        )
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