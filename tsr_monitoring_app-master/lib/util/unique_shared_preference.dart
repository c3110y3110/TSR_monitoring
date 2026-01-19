import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsr_monitoring_app/util/constants.dart';

class UniqueSharedPreference {
  static late final SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    await setString('selectedIndex', '0');
    await setString('selectedUnit', avgList[0]);
    await setString('maxvalue', '10.0');
    await setString('minvalue', '-10.0');
    if (!_instance.containsKey('selectedMachines')) {
      await setStringList('selectedMachines', List<String>.from(machineList));
    }
  }

  static String getString(String key, [String? defValue]) {
    return _instance.getString(key) ?? defValue ?? "";
  }

  static Future<void> setString(String key, String value) async {
    var prefs = await _instance;
    prefs.setString(key, value);
    await prefs.commit();
  }

  static List<String> getStringList(String key, [List<String>? defValue]) {
    return _instance.getStringList(key) ?? defValue ?? <String>[];
  }

  static Future<void> setStringList(String key, List<String> value) async {
    var prefs = await _instance;
    prefs.setStringList(key, value);
    await prefs.commit();
  }
}
