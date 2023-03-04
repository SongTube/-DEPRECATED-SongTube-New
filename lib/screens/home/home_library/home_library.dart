import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_fade/image_fade.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/cache_utils.dart';
import 'package:songtube/internal/enums/download_type.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/internal/http_server.dart';
import 'package:songtube/internal/models/audio_tags.dart';
import 'package:songtube/internal/models/download/download_info.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/providers/download_provider.dart';
import 'package:songtube/screens/settings.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/ui_utils.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeLibrary extends StatefulWidget {
  const HomeLibrary({Key? key}) : super(key: key);

  @override
  State<HomeLibrary> createState() => _HomeLibraryState();
}

class _HomeLibraryState extends State<HomeLibrary> {

  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Library', style: bigTextStyle(context).copyWith(fontSize: 24)),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              UiUtils.pushRouteAsync(internalNavigatorKey.currentContext!, const ConfigurationScreen());
            },
            icon: Icon(Iconsax.setting, color: Theme.of(context).primaryColor)
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (CacheUtils.watchHistory.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 12),
                itemCount: CacheUtils.watchHistory.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final video = CacheUtils.watchHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AspectRatio(
                      aspectRatio: 16/9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ImageFade(
                            fadeDuration: const Duration(milliseconds: 300),
                            image: NetworkImage(video.thumbnails!.hqdefault),
                            placeholder: Image.memory(kTransparentImage),
                            fit: BoxFit.cover)),
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: SizedBox(
                height: double.infinity,
                child: Icon(LineIcons.history, color: Theme.of(context).primaryColor)),
              title: Text('Watch History', style: subtitleTextStyle(context, bold: true)),
              subtitle: Text('Look at which videos you have seen', style: smallTextStyle(context)),
              onTap: () {
                // Open watch history page
      
              },
            ),
            ListTile(
              leading: SizedBox(
                height: double.infinity,
                child: Icon(Iconsax.save_2, color: Theme.of(context).primaryColor)),
              title: Text('Backup & Restore', style: subtitleTextStyle(context, bold: true)),
              subtitle: Text('Save or resture all of your local data', style: smallTextStyle(context)),
              onTap: () {
                // Open backup or restore sheet
      
              },
            ),
            GestureDetector(
              onLongPress: () {
                // Show more information about SongTube Link
      
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: CheckboxListTile(
                  title: Text('SongTube Link', style: textStyle(context, bold: true)),
                  subtitle: Text('Allow SongTube browser extension to detect this device, long press to learn more', style: smallTextStyle(context)),
                  value: linkServer != null,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) async {
                    if (linkServer != null) {
                      await LinkServer.close();
                    } else {
                      await LinkServer.initialize();
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
            ListTile(
              onTap: () {
                launchUrl(Uri.parse("https://paypal.me/artixo"));
              },
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(
                  EvaIcons.heart,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              title: Text(
                'Donate',
                textAlign: TextAlign.start,
                style: subtitleTextStyle(context, bold: true)
              ),
              subtitle: Text(
                "Support Development!",
                style: smallTextStyle(context)
              ),
            ),
            _socialIcons(),
          ],
        ),
      ),
    );
  }

  Widget _socialIcons() {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text('Social Links', style: subtitleTextStyle(context, bold: true, opacity: 0.7)),
      ),
      contentPadding: EdgeInsets.zero,
      subtitle: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, top: 16),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => launchUrl(Uri.parse("https://t.me/songtubechannel")),
              child: Image.asset('assets/images/telegram.png')
            ),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse("https://github.com/SongTube")),
              child: Image.asset('assets/images/github.png')
            ),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse("https://facebook.com/songtubeapp/")),
              child: Image.asset('assets/images/facebook.png')
            ),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse("https://instagram.com/songtubeapp")),
              child: Image.asset('assets/images/instagram.png')
            ),
          ],
        ),
      ),
    );
  }

}