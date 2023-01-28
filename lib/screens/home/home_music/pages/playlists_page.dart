import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/playlist_provider.dart';
import 'package:songtube/screens/playlist.dart';
import 'package:songtube/ui/tiles/playlist_grid_tile.dart';
import 'package:songtube/ui/ui_utils.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlaylistProvider playlistProvider = Provider.of(context);
    final globalPlaylists = playlistProvider.globalPlaylists;
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 4, right: 4, top: 12, bottom: kToolbarHeight+16),
      itemCount: globalPlaylists.length,
      clipBehavior: Clip.none,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: PlaylistGridTile(
            playlist: globalPlaylists[index],
            onTap: () {
              UiUtils.pushRouteAsync(context, PlaylistScreen(mediaSet: globalPlaylists[index].toMediaSet()));
            },
          ),
        );
      },
    );
  }

  Widget _emptyPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: Column(
          
        ),
      ),
    );
  }

}