import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:songtube/internal/app_settings.dart';
import 'package:songtube/ui/components/circular_check_box.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/setting_tile.dart';

class MusicPlayerSettings extends StatefulWidget {
  const MusicPlayerSettings({super.key});

  @override
  State<MusicPlayerSettings> createState() => _MusicPlayerSettingsState();
}

class _MusicPlayerSettingsState extends State<MusicPlayerSettings> {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      children: [
        // Music Player blur background
        SettingTileCheckbox(
          title: 'Blur Background',
          subtitle: 'Add blurred artwork background',
          value: AppSettings.enableMusicPlayerBlur,
          onChange: (value) {
            AppSettings.enableMusicPlayerBlur = value;
            setState(() {});
          },
          leadingIcon: Icons.blur_on,
        ),
        const SizedBox(height: 12),
        // Music Player blur background intensity
        SettingTileSlider(
          title: 'Blur intensity',
          subtitle: 'Change the blur intensity of the artwork background',
          leadingIcon: Icons.blur_linear,
          value: AppSettings.musicPlayerBlurStrenght,
          min: 0.00001,
          max: 100,
          valueTrailingString: '%',
          onChange: (value) {
            AppSettings.musicPlayerBlurStrenght = value;
            setState(() {});
          }
        ),
        const SizedBox(height: 12),
        // Music Player blur background intensity
        SettingTileSlider(
          title: 'Backdrop opacity',
          subtitle: 'Change the colored backdrop opacity',
          leadingIcon: Icons.opacity_rounded,
          value: AppSettings.musicPlayerBackdropOpacity*100,
          min: 0,
          max: 100,
          valueTrailingString: '%',
          onChange: (value) {
            AppSettings.musicPlayerBackdropOpacity = value/100;
            setState(() {});
          }
        ),
        const SizedBox(height: 12),

      ],
    );
  }
}