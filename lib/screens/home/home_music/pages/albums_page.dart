import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/models/media_item_models.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/ui/tiles/album_card_tile.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of(context);
    final albums = MediaItemAlbum.fetchAlbums(mediaProvider.songs);
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 4, right: 4, top: 12, bottom: kToolbarHeight+16),
      itemCount: albums.length,
      clipBehavior: Clip.none,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: AlbumCardTile(
            album: albums[index],
            onTap: (album) {
              //Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              //  return PlaylistScreen(playlistId: globalPlaylists[index].id);
              //}));
            },
          ),
        );
      },
    );
  }
}