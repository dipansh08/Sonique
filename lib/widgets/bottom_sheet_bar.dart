
import 'package:flutter/material.dart';
import 'package:sonique/utilities/common_variables.dart';

class BottomSheetBar extends StatelessWidget {
  const BottomSheetBar(
    this.title,
    this.onTap,
    this.backgroundColor, {
    this.borderRadius = BorderRadius.zero,
    super.key,
  });
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      margin: const EdgeInsets.only(bottom: 3),
      child: Padding(
        padding: commonBarContentPadding,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: ListTile(minTileHeight: 45, title: Text(title)),
        ),
      ),
    );
  }
}
