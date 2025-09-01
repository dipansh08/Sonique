
import 'package:flutter/widgets.dart';
import 'package:sonique/localization/app_localizations.dart';

extension ContextX on BuildContext {
  AppLocalizations? get l10n => AppLocalizations.of(this);
}
