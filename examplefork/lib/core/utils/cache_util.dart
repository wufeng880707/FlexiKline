import 'package:mmkv/mmkv.dart';

class CacheUtil {
  static MMKV? mmkv;

  static Future<void> init() async {
    if (mmkv == null) {
      await MMKV.initialize();
      mmkv = MMKV.defaultMMKV();
    }
  }

  static MMKV getMMKv() {
    if (mmkv == null) init();
    return mmkv!;
  }

  static bool putString<T>(String key, String? data) => getMMKv().encodeString(key, data);

  static String? getString<T>(String key) => getMMKv().decodeString(key);

  static String getSafeString<T>(String key, {String? defaultValue}) => getString(key) ?? defaultValue ?? "";

  static bool putListString(String key, List<String> data) {
    return getMMKv().encodeString(key, data.join(','));
  }

  static List<String>? getListString(String key) {
    final s = getMMKv().decodeString(key);
    if (s == null || s.isEmpty) return null;
    return s.split(',').map((e) => e.trim()).toList();
  }

  static bool putBool(String key, bool data) => getMMKv().encodeBool(key, data);

  static bool getBool(String key, {bool defaultValue = false}) => getMMKv().decodeBool(key, defaultValue: defaultValue);

  static bool putInt(String key, int data) => getMMKv().encodeInt(key, data);

  static int getInt(String key, {int defaultValue = 0}) => getMMKv().decodeInt(key, defaultValue: defaultValue);

  static putDouble(String s, double chartHeight) => getMMKv().encodeDouble(s, chartHeight);

  static double getDouble(String s, {double def = 0}) => getMMKv().decodeDouble(s, defaultValue: def);

  static remove(String key) => getMMKv().removeValue(key);
}
