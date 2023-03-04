import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
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

  void updateThemeMode() {
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      children: [
        // Dark mode
        SettingTileCheckbox(
          leadingIcon: LineIcons.moon,
          title: 'Dark mode',
          subtitle: 'Enable/disable dark mode',
          onChange: (_) => updateThemeMode(),
          value: uiProvider.themeMode == ThemeMode.dark,
        ),
      ],
    );
  }
}