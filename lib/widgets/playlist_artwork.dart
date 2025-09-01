

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sonique/utilities/common_variables.dart';
import 'package:sonique/widgets/no_artwork_cube.dart';

class PlaylistArtwork extends StatelessWidget {
  const PlaylistArtwork({
    super.key,
    required this.playlistArtwork,
    this.playlistTitle,
    this.cubeIcon = FluentIcons.music_note_1_24_regular,
    this.iconSize,
    this.size = 220,
  });

  final String? playlistArtwork;
  final String? playlistTitle;
  final IconData cubeIcon;
  final double? iconSize;
  final double size;

  Widget _nullArtwork() => NullArtworkWidget(
    icon: cubeIcon,
    iconSize: iconSize ?? (size * 0.3), // Default to 30% of container size
    size: size,
    title: playlistTitle,
  );

  @override
  Widget build(BuildContext context) {
    final image = playlistArtwork;
    if (image == null) return _nullArtwork();

    if (image.startsWith('data:image')) {
      final commaIdx = image.indexOf(',');
      if (commaIdx == -1) return _nullArtwork();
      try {
        final bytes = base64Decode(image.substring(commaIdx + 1));
        return SizedBox(
          width: size,
          height: size,
          child: ClipRRect(
            borderRadius: commonBarRadius,
            child: Image.memory(
              bytes,
              height: size,
              width: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _nullArtwork(),
            ),
          ),
        );
      } catch (_) {
        return _nullArtwork();
      }
    }

    if (image.startsWith('http')) {
      return CachedNetworkImage(
        key: Key(image),
        height: size,
        width: size,
        imageUrl: image,
        fit: BoxFit.cover,
        imageBuilder:
            (_, imageProvider) => SizedBox(
              width: size,
              height: size,
              child: ClipRRect(
                borderRadius: commonBarRadius,
                child: Image(
                  image: imageProvider,
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        errorWidget: (_, __, ___) => _nullArtwork(),
      );
    }

    return _nullArtwork();
  }
}
