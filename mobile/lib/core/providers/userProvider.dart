import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:nagora/core/utils/preferences.dart';
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  UserInfo _userInfo;
  bool _speaker = true;
  bool _microphone = true;

  UserInfo get userInfo => _userInfo;
  bool get speaker => _speaker;
  bool get microphone => _microphone;

  set userInfo(UserInfo val) {
    _userInfo = val;
    Preferences.instance().then((value) {
      value.userAccount = val.userAccount;
      value.uid = val.uid;
    });
    notifyListeners();
  }

  set speaker(bool val) {
    _speaker = val;
    notifyListeners();
  }

  set microphone(bool val) {
    _microphone = val;
    notifyListeners();
  }

  static UserProvider instance(BuildContext context) =>
      Provider.of(context, listen: false);
}
