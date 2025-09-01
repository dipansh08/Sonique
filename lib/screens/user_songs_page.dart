
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sonique/API/sonique.dart';
import 'package:sonique/extensions/l10n.dart';
import 'package:sonique/main.dart';
import 'package:sonique/services/settings_manager.dart';
import 'package:sonique/utilities/utils.dart';
import 'package:sonique/widgets/playlist_cube.dart';
import 'package:sonique/widgets/playlist_header.dart';
import 'package:sonique/widgets/song_bar.dart';

class UserSongsPage extends StatefulWidget {
  const UserSongsPage({super.key, required this.page});

  final String page;

  @override
  State<UserSongsPage> createState() => _UserSongsPageState();
}

class _UserSongsPageState extends State<UserSongsPage> {
  bool _isEditEnabled = false;

  @override
  Widget build(BuildContext context) {
    final title = getTitle(widget.page, context);
    final icon = getIcon(widget.page);
    final songsList = getSongsList(widget.page);
    final length = getLength(widget.page);
    final isLikedSongs = title == context.l10n!.likedSongs;

    return Scaffold(
      appBar: AppBar(
        title: offlineMode.value ? Text(title) : null,
        actions: [
          if (isLikedSongs)
            IconButton(
              onPressed: _toggleEditMode,
              icon: Icon(
                FluentIcons.re_order_24_filled,
                color:
                    _isEditEnabled
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      body: _buildCustomScrollView(title, icon, songsList, length),
    );
  }

  void _toggleEditMode() {
    setState(() => _isEditEnabled = !_isEditEnabled);
  }

  Widget _buildCustomScrollView(
    String title,
    IconData icon,
    List songsList,
    ValueNotifier<int> length,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: buildPlaylistHeader(title, icon, songsList.length),
          ),
        ),
        buildSongList(title, songsList, length),
      ],
    );
  }

  String getTitle(String page, BuildContext context) {
    return switch (page) {
      'liked' => context.l10n!.likedSongs,
      'offline' => context.l10n!.offlineSongs,
      'recents' => context.l10n!.recentlyPlayed,
      _ => context.l10n!.playlist,
    };
  }

  IconData getIcon(String page) {
    return switch (page) {
      'liked' => FluentIcons.heart_24_regular,
      'offline' => FluentIcons.cellular_off_24_regular,
      'recents' => FluentIcons.history_24_regular,
      _ => FluentIcons.heart_24_regular,
    };
  }

  List getSongsList(String page) {
    return switch (page) {
      'liked' => userLikedSongsList,
      'offline' => userOfflineSongs,
      'recents' => userRecentlyPlayed,
      _ => userLikedSongsList,
    };
  }

  ValueNotifier<int> getLength(String page) {
    return switch (page) {
      'liked' => currentLikedSongsLength,
      'offline' => currentOfflineSongsLength,
      'recents' => currentRecentlyPlayedLength,
      _ => currentLikedSongsLength,
    };
  }

  Widget buildPlaylistHeader(String title, IconData icon, int songsLength) {
    return PlaylistHeader(_buildPlaylistImage(title, icon), title, songsLength);
  }

  Widget _buildPlaylistImage(String title, IconData icon) {
    return PlaylistCube(
      {'title': title},
      size: MediaQuery.sizeOf(context).width / 2.5,
      cubeIcon: icon,
    );
  }

  Widget buildSongList(
    String title,
    List songsList,
    ValueNotifier<int> currentSongsLength,
  ) {
    final playlist = {
      'ytid': '',
      'title': title,
      'source': 'user-created',
      'list': songsList,
    };
    final isLikedSongs = title == context.l10n!.likedSongs;
    final isRecentlyPlayed = title == context.l10n!.recentlyPlayed;

    return ValueListenableBuilder(
      valueListenable: currentSongsLength,
      builder: (_, value, __) {
        if (isLikedSongs) {
          return SliverReorderableList(
            itemCount: songsList.length,
            itemBuilder: (context, index) {
              final song = songsList[index];
              final borderRadius = getItemBorderRadius(index, songsList.length);

              return ReorderableDragStartListener(
                enabled: _isEditEnabled,
                key: Key(song['ytid'].toString()),
                index: index,
                child: _buildSongBar(
                  song,
                  index,
                  borderRadius,
                  playlist,
                  isRecentSong: isRecentlyPlayed,
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                moveLikedSong(oldIndex, newIndex);
              });
            },
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = songsList[index];
              song['isOffline'] = title == context.l10n!.offlineSongs;
              final borderRadius = getItemBorderRadius(index, songsList.length);

              return _buildSongBar(
                song,
                index,
                borderRadius,
                playlist,
                isRecentSong: isRecentlyPlayed,
              );
              // ignore: require_trailing_commas
            }, childCount: songsList.length),
          );
        }
      },
    );
  }

  Widget _buildSongBar(
    Map song,
    int index,
    BorderRadius borderRadius,
    Map playlist, {
    bool isRecentSong = false,
  }) {
    return SongBar(
      song,
      true,
      onPlay: () {
        audioHandler.playPlaylistSong(
          playlist: activePlaylist != playlist ? playlist : null,
          songIndex: index,
        );
      },
      borderRadius: borderRadius,
      isRecentSong: isRecentSong,
    );
  }
}
