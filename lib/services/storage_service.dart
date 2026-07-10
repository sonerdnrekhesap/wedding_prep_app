import 'dart:convert';
import 'dart:developer' as developer;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_items.dart';
import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import '../models/lead_request_model.dart';

class StorageService {
  static const _itemsKey = 'prep_items';
  static const _guestsKey = 'guests';
  static const _settingsKey = 'settings';
  static const _leadsKey = 'lead_requests';

  static const _boxName = 'wedding_prep_data_v1';
  static const _schemaVersionKey = 'schema_version';
  static const _migrationCompleteKey = 'hive_migration_complete_v1';
  static const _currentSchemaVersion = 1;

  Box<dynamic>? _box;
  bool _initAttempted = false;
  bool _usePrefsFallback = false;

  Future<void> initialize() async {
    if (_initAttempted) return;
    _initAttempted = true;
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<dynamic>(_boxName);
      await _box!.put(_schemaVersionKey, _currentSchemaVersion);
      await _migrateSharedPreferencesIfNeeded();
    } catch (error, stackTrace) {
      _usePrefsFallback = true;
      developer.log(
        'Local database initialization failed; using preferences fallback.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<PrepItem>> loadItems() async {
    await initialize();
    final raw = await _readStructured(_itemsKey);
    if (raw == null) {
      final seed = _dedupeItems(buildSeedItems());
      await saveItems(seed);
      return seed;
    }
    final items = _decodeList(raw, PrepItem.fromJson);
    if (items.isEmpty) {
      final seed = _dedupeItems(buildSeedItems());
      await saveItems(seed);
      return seed;
    }
    return _dedupeItems(items);
  }

  Future<void> saveItems(List<PrepItem> items) async {
    await initialize();
    await _writeStructured(
      _itemsKey,
      _dedupeItems(items).map((item) => item.toJson()).toList(),
    );
  }

  Future<List<Guest>> loadGuests() async {
    await initialize();
    final raw = await _readStructured(_guestsKey);
    if (raw == null) return [];
    return _dedupeGuests(_decodeList(raw, Guest.fromJson));
  }

  Future<void> saveGuests(List<Guest> guests) async {
    await initialize();
    await _writeStructured(
      _guestsKey,
      _dedupeGuests(guests).map((guest) => guest.toJson()).toList(),
    );
  }

  Future<List<LeadRequest>> loadLeads() async {
    await initialize();
    final raw = await _readStructured(_leadsKey);
    if (raw == null) return [];
    return _dedupeLeads(_decodeList(raw, LeadRequest.fromJson));
  }

  Future<void> saveLeads(List<LeadRequest> leads) async {
    await initialize();
    await _writeStructured(
      _leadsKey,
      _dedupeLeads(leads).map((lead) => lead.toJson()).toList(),
    );
  }

  Future<AppSettings> loadSettings() async {
    await initialize();
    final raw = await _readStructured(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(_asMap(raw));
    } catch (error, stackTrace) {
      await _backupCorruptedValue(_settingsKey, raw);
      developer.log(
        'Settings data was invalid; safe defaults are used.',
        error: error,
        stackTrace: stackTrace,
      );
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await initialize();
    await _writeStructured(_settingsKey, settings.toJson());
  }

  Future<void> resetAll() async {
    await initialize();
    final box = _box;
    if (!_usePrefsFallback && box != null) {
      await box.delete(_itemsKey);
      await box.delete(_guestsKey);
      await box.delete(_settingsKey);
      await box.delete(_leadsKey);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
    await prefs.remove(_guestsKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_leadsKey);
  }

  Future<void> loadDemoData() async {
    await saveItems(buildSeedItems());
    await saveGuests(buildDemoGuests());
    await saveSettings(buildDemoSettings());
  }

  Future<void> _migrateSharedPreferencesIfNeeded() async {
    final box = _box;
    if (box == null || box.get(_migrationCompleteKey) == true) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_itemsKey, _guestsKey, _settingsKey, _leadsKey]) {
      final raw = prefs.getString(key);
      if (raw == null || box.containsKey(key)) continue;
      await prefs.setString('backup_before_hive_$key', raw);
      try {
        final decoded = jsonDecode(raw);
        await box.put(key, decoded);
      } catch (error, stackTrace) {
        await prefs.setString('corrupted_before_hive_$key', raw);
        developer.log(
          'SharedPreferences migration skipped invalid value for $key.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    await box.put(_migrationCompleteKey, true);
  }

  Future<dynamic> _readStructured(String key) async {
    if (!_usePrefsFallback && _box != null) {
      final value = _box!.get(key);
      if (value != null) return value;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (error, stackTrace) {
      await prefs.setString('corrupted_$key', raw);
      developer.log(
        'Stored JSON was invalid for $key.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _writeStructured(String key, Object value) async {
    if (!_usePrefsFallback && _box != null) {
      await _box!.put(key, value);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backup_current_$key', jsonEncode(value));
    if (_usePrefsFallback) {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  List<T> _decodeList<T>(
    dynamic raw,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final source = raw is List ? raw : const [];
    final result = <T>[];
    for (final entry in source) {
      try {
        result.add(fromJson(_asMap(entry)));
      } catch (error, stackTrace) {
        developer.log(
          'A stored record was skipped because it was invalid.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return result;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Expected a JSON object.');
  }

  Future<void> _backupCorruptedValue(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'corrupted_${key}_${DateTime.now().millisecondsSinceEpoch}',
      jsonEncode(value),
    );
  }

  List<PrepItem> _dedupeItems(List<PrepItem> items) {
    final byId = <String, PrepItem>{};
    for (final item in items) {
      if (item.id.trim().isEmpty || item.title.trim().isEmpty) continue;
      byId[item.id] = item;
    }
    return byId.values.toList();
  }

  List<Guest> _dedupeGuests(List<Guest> guests) {
    final byId = <String, Guest>{};
    for (final guest in guests) {
      if (guest.id.trim().isEmpty || guest.name.trim().isEmpty) continue;
      byId[guest.id] = guest;
    }
    return byId.values.toList();
  }

  List<LeadRequest> _dedupeLeads(List<LeadRequest> leads) {
    final byId = <String, LeadRequest>{};
    for (final lead in leads) {
      if (lead.id.trim().isEmpty) continue;
      byId[lead.id] = lead;
    }
    return byId.values.toList();
  }
}
