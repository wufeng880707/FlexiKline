import 'package:flutter/cupertino.dart';

import '../../lang/generated/l10n.dart';

extension LocalizaExtension on BuildContext {
  AppLocalizations get trans {
    try {
      return AppLocalizations.of(this);
    } catch (e) {
      return AppLocalizations.current;
    }
  }

  static AppLocalizations get gTrans => AppLocalizations.current;
}
