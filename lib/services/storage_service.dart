import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_items.dart';
import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';

class StorageService {
  static const _itemsKey = 'prep_items';
  static const _guestsKey = 'guests';
  static const _settingsKey = 'settings';
  static const _schemaVersionKey = 'storage_schema_version';
  static const currentSchemaVersion = 1;

  Future<List<PrepItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null) {
      final seed = buildSeedItems();
      await saveItems(seed);
      return seed;
    }

    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map(PrepItem.fromJson)
          .toList();
    } catch (_) {
      await _quarantineCorruptValue(prefs, _itemsKey, raw);
      final seed = buildSeedItems();
      await saveItems(seed);
      return seed;
    }
  }

  Future<void> saveItems(List<PrepItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schemaVersionKey, currentSchemaVersion);
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<Guest>> loadGuests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_guestsKey);
    if (raw == null) return [];

    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map(Guest.fromJson)
          .toList();
    } catch (_) {
      await _quarantineCorruptValue(prefs, _guestsKey, raw);
      return [];
    }
  }

  Future<void> saveGuests(List<Guest> guests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schemaVersionKey, currentSchemaVersion);
    await prefs.setString(
      _guestsKey,
      jsonEncode(guests.map((guest) => guest.toJson()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();

    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _quarantineCorruptValue(prefs, _settingsKey, raw);
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schemaVersionKey, currentSchemaVersion);
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
    await prefs.remove(_guestsKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_schemaVersionKey);
  }

  Future<void> loadDemoData() async {
    await saveItems(buildSeedItems());
    await saveGuests(buildDemoGuests());
    await saveSettings(buildDemoSettings());
  }

  Future<void> _quarantineCorruptValue(
    SharedPreferences prefs,
    String key,
    String raw,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString('${key}_corrupt_$stamp', raw);
    await prefs.remove(key);
  }
}
