import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class AppLocalizations {
  static const List<LocalizationsDelegate> delegates = [
    PersianMaterialLocalizations.delegate,
    PersianCupertinoLocalizations.delegate,
    DariMaterialLocalizations.delegate,
    DariCupertinoLocalizations.delegate,
    PashtoMaterialLocalizations.delegate,
    PashtoCupertinoLocalizations.delegate,
    SoraniMaterialLocalizations.delegate,
    SoraniCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('fa', 'IR'),
    Locale('en', 'US'),
  ];
}
