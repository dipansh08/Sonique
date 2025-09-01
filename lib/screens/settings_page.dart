import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sonique/API/sonique.dart';
import 'package:sonique/extensions/l10n.dart';
import 'package:sonique/main.dart';
import 'package:sonique/screens/search_page.dart';
import 'package:sonique/services/data_manager.dart';
import 'package:sonique/services/router_service.dart';
import 'package:sonique/services/settings_manager.dart';
import 'package:sonique/services/update_manager.dart';
import 'package:sonique/style/app_colors.dart';
import 'package:sonique/style/app_themes.dart';
import 'package:sonique/utilities/common_variables.dart';
import 'package:sonique/utilities/flutter_bottom_sheet.dart';
import 'package:sonique/utilities/flutter_toast.dart';
import 'package:sonique/utilities/url_launcher.dart';
import 'package:sonique/utilities/utils.dart';
import 'package:sonique/widgets/bottom_sheet_bar.dart';
import 'package:sonique/widgets/confirmation_dialog.dart';
import 'package:sonique/widgets/custom_bar.dart';
import 'package:sonique/widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final activatedColor = Theme.of(context).colorScheme.secondaryContainer;
    final inactivatedColor = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n!.settings)),
      body: SingleChildScrollView(
        padding: commonSingleChildScrollViewPadding,
        child: Column(
          children: <Widget>[
            _buildPreferencesSection(
              context,
              primaryColor,
              activatedColor,
              inactivatedColor,
            ),
            if (!offlineMode.value)
              _buildOnlineFeaturesSection(
                context,
                activatedColor,
                inactivatedColor,
                primaryColor,
              ),
            _buildOthersSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    Color primaryColor,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.preferences),
        CustomBar(
          context.l10n!.accentColor,
          FluentIcons.color_24_filled,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () => _showAccentColorPicker(context),
        ),
        CustomBar(
          context.l10n!.themeMode,
          FluentIcons.weather_sunny_28_filled,
          onTap: () =>
              _showThemeModePicker(context, activatedColor, inactivatedColor),
        ),
        CustomBar(
          context.l10n!.language,
          FluentIcons.translate_24_filled,
          onTap: () =>
              _showLanguagePicker(context, activatedColor, inactivatedColor),
        ),
        CustomBar(
          context.l10n!.audioQuality,
          Icons.music_note,
          onTap: () => _showAudioQualityPicker(
            context,
            activatedColor,
            inactivatedColor,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: useProxy,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.useProxy,
              FluentIcons.shield_24_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) {
                  useProxy.value = value;
                  addOrUpdateData('settings', 'useProxy', value);
                  showToast(context, context.l10n!.settingChangedMsg);
                },
              ),
            );
          },
        ),
        CustomBar(
          context.l10n!.dynamicColor,
          FluentIcons.toggle_left_24_filled,
          trailing: Switch(
            value: useSystemColor.value,
            onChanged: (value) => _toggleSystemColor(context, value),
          ),
        ),
        if (themeMode == ThemeMode.dark)
          CustomBar(
            context.l10n!.pureBlackTheme,
            FluentIcons.color_background_24_filled,
            trailing: Switch(
              value: usePureBlackColor.value,
              onChanged: (value) => _togglePureBlack(context, value),
            ),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: predictiveBack,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.predictiveBack,
              FluentIcons.position_backward_24_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) => _togglePredictiveBack(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: offlineMode,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.offlineMode,
              FluentIcons.cellular_off_24_regular,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleOfflineMode(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: backgroundPlay,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.backgroundPlay,
              FluentIcons.dual_screen_tablet_24_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleBackgroundPlay(context, value),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOnlineFeaturesSection(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
    Color primaryColor,
  ) {
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: sponsorBlockSupport,
          builder: (_, value, __) {
            return CustomBar(
              'SponsorBlock',
              FluentIcons.presence_blocked_24_regular,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleSponsorBlock(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: playNextSongAutomatically,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.automaticSongPicker,
              FluentIcons.music_note_2_play_20_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) {
                  audioHandler.changeAutoPlayNextStatus();
                  showToast(context, context.l10n!.settingChangedMsg);
                },
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: defaultRecommendations,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.originalRecommendations,
              FluentIcons.channel_share_24_regular,
              borderRadius: commonCustomBarRadiusLast,
              trailing: Switch(
                value: value,
                onChanged: (value) =>
                    _toggleDefaultRecommendations(context, value),
              ),
            );
          },
        ),

        _buildToolsSection(context),
        _buildSponsorSection(context, primaryColor),
      ],
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.tools),
        CustomBar(
          context.l10n!.clearCache,
          FluentIcons.broom_24_filled,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () async {
            final cleared = await clearCache();
            showToast(
              context,
              cleared ? '${context.l10n!.cacheMsg}!' : context.l10n!.error,
            );
          },
        ),
        CustomBar(
          context.l10n!.clearSearchHistory,
          FluentIcons.history_24_filled,
          onTap: () => _showClearSearchHistoryDialog(context),
        ),
        CustomBar(
          context.l10n!.clearRecentlyPlayed,
          FluentIcons.receipt_play_24_filled,
          onTap: () => _showClearRecentlyPlayedDialog(context),
        ),
        CustomBar(
          context.l10n!.backupUserData,
          FluentIcons.cloud_sync_24_filled,
          onTap: () => _backupUserData(context),
        ),
        CustomBar(
          context.l10n!.restoreUserData,
          FluentIcons.cloud_add_24_filled,
          onTap: () async {
            final response = await restoreData(context);
            showToast(context, response);
          },
        ),
        if (!isFdroidBuild)
          CustomBar(
            context.l10n!.downloadAppUpdate,
            FluentIcons.arrow_download_24_filled,
            borderRadius: commonCustomBarRadiusLast,
            onTap: checkAppUpdates,
          ),
      ],
    );
  }

  Widget _buildSponsorSection(BuildContext context, Color primaryColor) {
    final gradientEnd = Color.lerp(primaryColor, Colors.pink, 0.3)!;
    final shadowColor = primaryColor.withValues(alpha: 0.3);
    final iconBgColor = Colors.white.withValues(alpha: 0.2);
    final arrowBgColor = Colors.white.withValues(alpha: 0.15);
    final arrowColor = Colors.white.withValues(alpha: 0.9);

    return Column(
      children: [
        SectionHeader(title: context.l10n!.becomeSponsor),
        Padding(
          padding: commonBarPadding,
          child: Card(
            margin: const EdgeInsets.only(bottom: 3),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.8),
                    gradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () =>
                      launchURL(Uri.parse('https://ko-fi.com/gokadzev')),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      height: 45, // Match CustomBar's minTileHeight
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FluentIcons.heart_24_filled,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              context.l10n!.sponsorProject,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600, // Match CustomBar
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: arrowBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              FluentIcons.arrow_right_24_filled,
                              color: arrowColor,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOthersSection(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.others),
        CustomBar(
          context.l10n!.licenses,
          FluentIcons.document_24_filled,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () => NavigationManager.router.go('/settings/license'),
        ),
        CustomBar(
          '${context.l10n!.copyLogs} (${logger.getLogCount()})',
          FluentIcons.error_circle_24_filled,
          onTap: () async => showToast(context, await logger.copyLogs(context)),
        ),
        CustomBar(
          context.l10n!.about,
          FluentIcons.book_information_24_filled,
          borderRadius: commonCustomBarRadiusLast,
          onTap: () => NavigationManager.router.go('/settings/about'),
        ),
      ],
    );
  }

  void _showAccentColorPicker(BuildContext context) {
    showCustomBottomSheet(
      context,
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: availableColors.length,
        itemBuilder: (context, index) {
          final color = availableColors[index];
          final isSelected = color == primaryColorSetting;

          return GestureDetector(
            onTap: () {
              addOrUpdateData(
                'settings',
                'accentColor',
                // ignore: deprecated_member_use
                color.value,
              );
              Sonique.updateAppState(
                context,
                newAccentColor: color,
                useSystemColor: false,
              );
              showToast(context, context.l10n!.accentChangeMsg);
              Navigator.pop(context);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: themeMode == ThemeMode.light
                      ? color.withAlpha(150)
                      : color,
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showThemeModePicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableModes.length,
        itemBuilder: (context, index) {
          final mode = availableModes[index];
          final borderRadius = getItemBorderRadius(
            index,
            availableModes.length,
          );

          return BottomSheetBar(
            mode.name,
            () {
              addOrUpdateData('settings', 'themeMode', mode.name);
              Sonique.updateAppState(context, newThemeMode: mode);
              Navigator.pop(context);
            },
            themeMode == mode ? activatedColor : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableLanguages = appLanguages.keys.toList();
    final activeLanguageCode = Localizations.localeOf(context).languageCode;
    final activeScriptCode = Localizations.localeOf(context).scriptCode;
    final activeLanguageFullCode = activeScriptCode != null
        ? '$activeLanguageCode-$activeScriptCode'
        : activeLanguageCode;

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableLanguages.length,
        itemBuilder: (context, index) {
          final language = availableLanguages[index];
          final newLocale = getLocaleFromLanguageCode(appLanguages[language]);
          final newLocaleFullCode = newLocale.scriptCode != null
              ? '${newLocale.languageCode}-${newLocale.scriptCode}'
              : newLocale.languageCode;

          final borderRadius = getItemBorderRadius(
            index,
            availableLanguages.length,
          );

          return BottomSheetBar(
            language,
            () {
              addOrUpdateData('settings', 'language', newLocaleFullCode);
              Sonique.updateAppState(context, newLocale: newLocale);
              showToast(context, context.l10n!.languageMsg);
              Navigator.pop(context);
            },
            activeLanguageFullCode == newLocaleFullCode
                ? activatedColor
                : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _showAudioQualityPicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableQualities = ['low', 'medium', 'high'];

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableQualities.length,
        itemBuilder: (context, index) {
          final quality = availableQualities[index];
          final isCurrentQuality = audioQualitySetting.value == quality;
          final borderRadius = getItemBorderRadius(
            index,
            availableQualities.length,
          );

          return BottomSheetBar(
            quality,
            () {
              addOrUpdateData('settings', 'audioQuality', quality);
              audioQualitySetting.value = quality;
              showToast(context, context.l10n!.audioQualityMsg);
              Navigator.pop(context);
            },
            isCurrentQuality ? activatedColor : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _toggleSystemColor(BuildContext context, bool value) {
    addOrUpdateData('settings', 'useSystemColor', value);
    useSystemColor.value = value;
    Sonique.updateAppState(
      context,
      newAccentColor: primaryColorSetting,
      useSystemColor: value,
    );
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _togglePureBlack(BuildContext context, bool value) {
    addOrUpdateData('settings', 'usePureBlackColor', value);
    usePureBlackColor.value = value;
    Sonique.updateAppState(context);
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _togglePredictiveBack(BuildContext context, bool value) {
    addOrUpdateData('settings', 'predictiveBack', value);
    predictiveBack.value = value;
    transitionsBuilder = value
        ? const PredictiveBackPageTransitionsBuilder()
        : const CupertinoPageTransitionsBuilder();
    Sonique.updateAppState(context);
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleBackgroundPlay(BuildContext context, bool value) {
    addOrUpdateData('settings', 'backgroundPlay', value);
    backgroundPlay.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleOfflineMode(BuildContext context, bool value) {
    addOrUpdateData('settings', 'offlineMode', value);
    offlineMode.value = value;

    // Trigger router refresh and notify about the change
    NavigationManager.refreshRouter();
    offlineModeChangeNotifier.value = !offlineModeChangeNotifier.value;

    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleSponsorBlock(BuildContext context, bool value) {
    addOrUpdateData('settings', 'sponsorBlockSupport', value);
    sponsorBlockSupport.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleDefaultRecommendations(BuildContext context, bool value) {
    addOrUpdateData('settings', 'defaultRecommendations', value);
    defaultRecommendations.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _showClearSearchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          submitMessage: context.l10n!.clear,
          confirmationMessage: context.l10n!.clearSearchHistoryQuestion,
          onCancel: () => {Navigator.of(context).pop()},
          onSubmit: () => {
            Navigator.of(context).pop(),
            searchHistoryNotifier.value = [],
            deleteData('user', 'searchHistory'),
            showToast(context, '${context.l10n!.searchHistoryMsg}!'),
          },
        );
      },
    );
  }

  void _showClearRecentlyPlayedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          submitMessage: context.l10n!.clear,
          confirmationMessage: context.l10n!.clearRecentlyPlayedQuestion,
          onCancel: () => {Navigator.of(context).pop()},
          onSubmit: () => {
            Navigator.of(context).pop(),
            userRecentlyPlayed = [],
            deleteData('user', 'recentlyPlayedSongs'),
            showToast(context, '${context.l10n!.recentlyPlayedMsg}!'),
          },
        );
      },
    );
  }

  Future<void> _backupUserData(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(context.l10n!.folderRestrictions),
          actions: <Widget>[
            TextButton(
              child: Text(context.l10n!.understand.toUpperCase()),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    final response = await backupData(context);
    showToast(context, response);
  }
}
