import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = {
    'de': {
      // App title
      'appTitle': 'Mensa KSWE',

      // Navigation
      'back': 'Zurück',
      'info': 'Info',

      // Home Screen
      'loadingMenus': 'Menüs werden geladen...',
      'errorLoadingMenus': 'Fehler beim Laden der Menüs',
      'retry': 'Erneut versuchen',
      'noMenusAvailable': 'Keine Menüs verfügbar',
      'pleaseTryLater': 'Bitte versuchen Sie es später erneut',
      'dailyMenus': 'Tagesmenüs',

      // Menu Detail Screen
      'menuDetails': 'Menü Details',
      'noMenuAvailable': 'Kein Menü verfügbar',
      'errorLoadingMenu': 'Fehler beim Laden des Menüs',
      'mensaClosed': 'Mensa geschlossen',
      'mensaClosedMessage': 'Die Mensa ist heute geschlossen.',

      // Info Screen
      'aboutMensa': 'Über Mensa KSWE',
      'openingHours': 'Öffnungszeiten',
      'mondayFriday': 'Montag - Freitag',
      'saturday': 'Samstag',
      'sunday': 'Sonntag',
      'closed': 'Geschlossen',

      // App Features
      'appFeatures': 'App Features',
      'dailyMenusFeature': 'Tagesmenüs',
      'dailyMenusDescription': 'Aktuelle Menüs für jeden Tag der Woche',
      'vegetarianOptions': 'Vegetarische Optionen',
      'vegetarianOptionsDescription':
          'Spezielle Filterung für pflanzliche Gerichte',
      'allergenInfo': 'Allergen-Info',
      'allergenInfoDescription': 'Detaillierte Informationen zu Allergenen',

      // App Information
      'appInformation': 'App Information',
      'version': 'Version',
      'developer': 'Entwickler',
      'developerName': 'Mensa KSWE Team',
      'platform': 'Plattform',
      'platformName': 'iOS & Android',

      // Date formatting
      'today': 'Heute',
      'tomorrow': 'Morgen',
      'yesterday': 'Gestern',

      // Common
      'loading': 'Laden...',
      'error': 'Fehler',
      'ok': 'OK',
      'cancel': 'Abbrechen',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get info => _localizedValues[locale.languageCode]!['info']!;
  String get loadingMenus =>
      _localizedValues[locale.languageCode]!['loadingMenus']!;
  String get errorLoadingMenus =>
      _localizedValues[locale.languageCode]!['errorLoadingMenus']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get noMenusAvailable =>
      _localizedValues[locale.languageCode]!['noMenusAvailable']!;
  String get pleaseTryLater =>
      _localizedValues[locale.languageCode]!['pleaseTryLater']!;
  String get dailyMenus =>
      _localizedValues[locale.languageCode]!['dailyMenus']!;
  String get menuDetails =>
      _localizedValues[locale.languageCode]!['menuDetails']!;
  String get noMenuAvailable =>
      _localizedValues[locale.languageCode]!['noMenuAvailable']!;
  String get errorLoadingMenu =>
      _localizedValues[locale.languageCode]!['errorLoadingMenu']!;
  String get mensaClosed =>
      _localizedValues[locale.languageCode]!['mensaClosed']!;
  String get mensaClosedMessage =>
      _localizedValues[locale.languageCode]!['mensaClosedMessage']!;
  String get aboutMensa =>
      _localizedValues[locale.languageCode]!['aboutMensa']!;
  String get openingHours =>
      _localizedValues[locale.languageCode]!['openingHours']!;
  String get mondayFriday =>
      _localizedValues[locale.languageCode]!['mondayFriday']!;
  String get saturday => _localizedValues[locale.languageCode]!['saturday']!;
  String get sunday => _localizedValues[locale.languageCode]!['sunday']!;
  String get closed => _localizedValues[locale.languageCode]!['closed']!;

  // App Features
  String get appFeatures =>
      _localizedValues[locale.languageCode]!['appFeatures']!;
  String get dailyMenusFeature =>
      _localizedValues[locale.languageCode]!['dailyMenusFeature']!;
  String get dailyMenusDescription =>
      _localizedValues[locale.languageCode]!['dailyMenusDescription']!;
  String get vegetarianOptions =>
      _localizedValues[locale.languageCode]!['vegetarianOptions']!;
  String get vegetarianOptionsDescription =>
      _localizedValues[locale.languageCode]!['vegetarianOptionsDescription']!;
  String get allergenInfo =>
      _localizedValues[locale.languageCode]!['allergenInfo']!;
  String get allergenInfoDescription =>
      _localizedValues[locale.languageCode]!['allergenInfoDescription']!;

  // App Information
  String get appInformation =>
      _localizedValues[locale.languageCode]!['appInformation']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get developer => _localizedValues[locale.languageCode]!['developer']!;
  String get developerName =>
      _localizedValues[locale.languageCode]!['developerName']!;
  String get platform => _localizedValues[locale.languageCode]!['platform']!;
  String get platformName =>
      _localizedValues[locale.languageCode]!['platformName']!;

  String get today => _localizedValues[locale.languageCode]!['today']!;
  String get tomorrow => _localizedValues[locale.languageCode]!['tomorrow']!;
  String get yesterday => _localizedValues[locale.languageCode]!['yesterday']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
