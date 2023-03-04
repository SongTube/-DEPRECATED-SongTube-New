import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:songtube/internal/app_settings.dart';
import 'package:songtube/ui/components/circular_check_box.dart';
import 'package:songtube/ui/text_styles.dart';

class MusicPlayerSettings extends StatefulWidget {
  const MusicPlayerSettings({super.key});

  @override
  State<MusicPlayerSettings> createState() => _MusicPlayerSettingsState();
}

class _MusicPlayerSettingsState extends State<MusicPlayerSettings> {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 12),
      children: [
        ListTile(
          leading: SizedBox(
            height: double.infinity,
            child: Icon(Icons.blur_on, color: Theme.of(context).iconTheme.color),
          ),
          onTap: () {
            AppSettings.enableMusicPlayerBlur = !AppSettings.enableMusicPlayerBlur;
            setState(() {});
          },
          title: Text('Blur Background', style: subtitleTextStyle(context, bold: true)),
          subtitle: Text('Add blurred artwork background', style: tinyTextStyle(context, opacity: 0.7)),
          trailing: CircularCheckbox(
            value: AppSettings.enableMusicPlayerBlur,
            onChange: (value) {
              AppSettings.enableMusicPlayerBlur = value;
              setState(() {});
            },
          ),
        )
      ],
    );
  }
}