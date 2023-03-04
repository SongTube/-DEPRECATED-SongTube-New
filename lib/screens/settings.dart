import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/text_styles.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  
  UiProvider get uiProvider => Provider.of(context, listen: false);

  void updateThemeMode() {
    if (uiProvider.themeMode == ThemeMode.dark) {
      uiProvider.updateThemeMode(ThemeMode.light);
    } else {
      uiProvider.updateThemeMode(ThemeMode.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: textStyle(context)
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 12, right: 12),
        children: [
          ListTile(
            leading: SizedBox(
              height: double.infinity,
              child: Icon(LineIcons.moon, color: Theme.of(context).iconTheme.color),
            ),
            title: Text('Dark mode', style: subtitleTextStyle(context, bold: true)),
            subtitle: Text('Enable/disable dark mode', style: tinyTextStyle(context, opacity: 0.7)),
            trailing: RoundCheckBox(
              size: 24,
              isChecked: uiProvider.themeMode == ThemeMode.dark,
              onTap: (_) {
                updateThemeMode();
              },
            ),
          ),
        ],
      ),
    );
  }
}