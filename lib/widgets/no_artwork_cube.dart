

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class NullArtworkWidget extends StatelessWidget {
  const NullArtworkWidget({
    super.key,
    this.icon = FluentIcons.music_note_1_24_regular,
    this.size = 220,
    this.iconSize,
    this.title,
  });

  final IconData icon;
  final double? iconSize;
  final double size;
  final String? title;

  static const double paddingValue = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    // Calculate icon size based on container size if not provided
    final calculatedIconSize = iconSize ?? (size * 0.29);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryColor.withAlpha(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: calculatedIconSize, color: primaryColor),
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(paddingValue),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: primaryColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
