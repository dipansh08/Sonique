// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:sonique/DB/albums.db.dart';
import 'package:sonique/DB/playlists.db.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:sonique/services/proxy_manager.dart';
import 'package:sonique/services/settings_manager.dart';

List playlists = [...playlistsDB, ...albumsDB];

void main() async {
  print('PLAYLISTS AND ALBUMS CHECKING RESULT:');
  print('      ');

  // Obtain a YoutubeExplode client that respects proxy setting.
  YoutubeExplode? ytClient;
  try {
    if (useProxy.value) {
      ytClient = await ProxyManager().getYoutubeExplodeClient();
    } else {
      ytClient = ProxyManager().getClientSync();
    }

    for (final playlist in playlists) {
      try {
        final plist = await ytClient!.playlists.get(playlist['ytid']);

        if (plist.videoCount == null) {
          if (playlist['isAlbum'] != null && playlist['isAlbum']) {
            print(
              '> The album with the ID ${playlist['ytid']} does not exist.',
            );
          } else {
            print(
              '> The playlist with the ID ${playlist['ytid']} does not exist.',
            );
          }
        }

        final imageAvailability = await isImageAvailable(playlist['image']);
        if (!imageAvailability) {
          if (playlist['isAlbum'] != null && playlist['isAlbum']) {
            print(
              '> The album artwork with the URL ${playlist['image']} is not available.',
            );
          } else {
            print(
              '> The playlist artwork with the URL ${playlist['image']} is not available.',
            );
          }
        }
      } catch (e) {
        print(
          'An error occurred while checking playlist ${playlist['title']}: $e',
        );
      }
    }
  } finally {
    try {
      if (useProxy.value) ytClient?.close();
    } catch (_) {}
  }

  print('      ');
  print('The checking process is done');
}

Future<bool> isImageAvailable(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    print('Something went wrong in isImageAvailable for the url: $url');
    return false;
  }
}
