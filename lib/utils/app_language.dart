// import 'package:flutter/material.dart';
// import 'package:shared_transport/config/storage_manager.dart';

// class AppLanguage extends ChangeNotifier {
//   static const localeValueList = ['en', 'hi'];

//   static const kLocaleIndex = 'kLocaleIndex';

//   int _localeIndex;

//   int get localeIndex => _localeIndex;

//   Locale get locale {
//     var value = localeValueList[_localeIndex].split("-");
//     return Locale(value[0], value.length == 2 ? value[1] : '');
//   }

//   AppLanguage() {
//     _localeIndex = StorageManager.sharedPreferences.getInt(kLocaleIndex) ?? 0;
//   }

//   switchLocale() {
//     _localeIndex = 1 - _localeIndex;
//     notifyListeners();
//     StorageManager.sharedPreferences.setInt(kLocaleIndex, _localeIndex);
//   }

//   static String localeName(index, context) {
//     switch (index) {
//       case 0:
//         return 'हिन्दी';
//       case 1:
//         return 'हिन्दी';
//       default:
//         return 'English';
//     }
//   }
// }
