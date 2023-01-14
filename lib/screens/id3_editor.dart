import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_tagger/audio_tagger.dart' as tagger;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/media_utils.dart';
import 'package:songtube/internal/models/audio_tags.dart';
import 'package:songtube/internal/models/music_brainz_record.dart';
import 'package:songtube/internal/models/song_item.dart';
import 'package:songtube/pages/music_brainz_search.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/services/music_brainz_service.dart';
import 'package:songtube/ui/animations/blue_page_route.dart';
import 'package:songtube/ui/components/custom_snackbar.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:songtube/ui/tiles/text_field_tile.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:validators/validators.dart';

class ID3Editor extends StatefulWidget {
  const ID3Editor({
    required this.song,
    Key? key
  }) : super(key: key);
  final MediaItem song;
  @override
  // ignore: library_private_types_in_public_api
  _ID3EditorState createState() => _ID3EditorState();
}

class _ID3EditorState extends State<ID3Editor> {

  AudioTags tags = AudioTags();
  String? originalArtwork;

  // Writting Tags Status
  bool processingTags = false;

  @override
  void initState() {
    loadTagsControllers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).cardColor,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 4/3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _artworkImage(),
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
                ),
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    'Tags Editor',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.white
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        final path = (await FilePicker.platform
                          .pickFiles(type: FileType.image))?.paths[0];
                        if (path == null) return;
                        tags.artwork = path;
                        setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: const Icon(EvaIcons.brushOutline,
                          color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)
                  )
                ),
                child: _textfields(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _floatingButtons(),
    );
  }

  Widget _artworkImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (tags.artwork != null)
          FadeInImage(
            fadeInDuration: const Duration(milliseconds: 300),
            image: isURL(tags.artwork)
              ? NetworkImage(tags.artwork)
              : FileImage(File(tags.artwork)) as ImageProvider,
            placeholder: MemoryImage(kTransparentImage),
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _textfields() {
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(top: 20, bottom: 50),
      children: [
        // Title TextField
        TextFieldTile(
          textController: tags.titleController,
          inputType: TextInputType.text,
          labelText: 'Title',
          icon: EvaIcons.textOutline,
        ),
        const SizedBox(height: 16),
        // Album & Artist TextField Row
        TextFieldTile(
          textController: tags.albumController,
          inputType: TextInputType.text,
          labelText: 'Album',
          icon: EvaIcons.bookOpenOutline,
        ),
        const SizedBox(height: 16),
        // Artist TextField
        TextFieldTile(
          textController: tags.artistController,
          inputType: TextInputType.text,
          labelText: 'Artist',
          icon: EvaIcons.personOutline,
        ),
        const SizedBox(height: 16),
        // Gender & Date TextField Row
        TextFieldTile(
          textController: tags.genreController,
          inputType: TextInputType.text,
          labelText: 'Genre',
          icon: EvaIcons.bookOutline,
        ),
        const SizedBox(height: 16),
        // Date TextField
        TextFieldTile(
          textController: tags.dateController,
          inputType: TextInputType.datetime,
          labelText: 'Date',
          icon: EvaIcons.calendarOutline,
        ),
        const SizedBox(height: 16),
        // Disk & Track TextField Row
        TextFieldTile(
          textController: tags.discController,
          inputType: TextInputType.number,
          labelText: 'Disc',
          icon: EvaIcons.playCircleOutline
        ),
        const SizedBox(height: 16),
        // Track TextField
        TextFieldTile(
          textController: tags.trackController,
          inputType: TextInputType.number,
          labelText: 'Track',
          icon: EvaIcons.musicOutline,
        ),
        const Divider(color: Colors.transparent),
        ListTile(
          onTap: () {
            setState(() {
              tags.artwork = originalArtwork;
            });
          },
          title: Text(
            "Restore Artwork",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w800
            ),
          ),
        ),
      ],
    );
  }

  Widget _floatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Search on MusicBrainz
        FloatingActionButton(
          heroTag: 'fabSearch',
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Colors.white,
          child: Icon(Icons.search,
            color: Theme.of(context).primaryColor),
          onPressed: () async {
            manualWriteTags();
          },
        ),
        const SizedBox(width: 16),
        // Save Audio Information
        FloatingActionButton.extended(
          heroTag: 'fabSave',
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          label: Row(
            children: [
              const Icon(Icons.save_outlined,
                color: Colors.white),
              const SizedBox(width: 8),
              Text(
                processingTags ? 'Applying...' : 'Apply',
                style: textStyle(context)
              )
            ],
          ),
          onPressed: () async {
            setState(() {
              processingTags = true;
            });
            final status = await MediaUtils.writeMetadata(widget.song.id, tags);
            if (status != null) {
              CustomSnackbar.showSnackBar(
                icon: Iconsax.warning_2,
                title: 'Audio format not compatible',
                duration: const Duration(seconds: 2),
                context: context,
              );
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void loadTagsControllers() async {
    final audioTags = await tagger.AudioTagger.extractAllTags(widget.song.id);
    tags.titleController.text = audioTags?.title ?? widget.song.title;
    tags.albumController.text = audioTags?.album ?? widget.song.album!;
    tags.artistController.text = audioTags?.artist ?? widget.song.artist ?? 'Unknown';
    tags.genreController.text = audioTags?.genre ?? widget.song.genre ?? 'Unknown';
    tags.dateController.text = audioTags?.year ?? '';
    tags.discController.text = audioTags?.disc ?? '';
    tags.trackController.text = audioTags?.track ?? '';
    setState(() {});
    tags.artwork = widget.song.extras?['artwork'];
    originalArtwork = tags.artwork;
    setState(() {});
  }

  void manualWriteTags() async {
    MusicBrainzRecord? record = await Navigator.push(context,
      BlurPageRoute(builder: (context) => 
        MusicBrainzSearch(
          title: tags.titleController.text,
          artist: tags.artistController.text),
        ));
    if (record == null) return;
    String lastArtwork = tags.artwork;
    tags = await MusicBrainzAPI.getSongTags(record);
    tags.artwork ??= lastArtwork;
    setState(() {});
  }

}