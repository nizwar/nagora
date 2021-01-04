import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences shared;

  Preferences(this.shared);
  set userAccount(String value) => shared.setString("token", value);
  set uid(int value) => shared.setInt("uid", value);

  String get userAccount => shared.getString("token");
  int get uid => shared.getInt("uid");

  static Future<Preferences> instance() =>
      SharedPreferences.getInstance().then((value) => Preferences(value));
}
