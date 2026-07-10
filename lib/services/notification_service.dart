import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings_model.dart';
import '../models/item_model.dart';
import 'calculation_service.dart';

class NotificationDecision {
  const NotificationDecision({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<bool> configure({required bool enabled}) async {
    if (kIsWeb || !enabled) {
      if (!enabled) await cancelAll();
      return false;
    }
    return _ensureInitialized();
  }

  Future<void> rescheduleAll(AppSettings settings, List<PrepItem> items) async {
    if (!settings.notificationsEnabled || kIsWeb) {
      await cancelAll();
      return;
    }
    final ready = await _ensureInitialized();
    if (!ready) return;
    await cancelAll();
    for (final decision in buildSchedule(settings, items)) {
      await _schedule(decision);
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (error, stackTrace) {
      developer.log(
        'Notification cancel failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  List<NotificationDecision> buildSchedule(
    AppSettings settings,
    List<PrepItem> items,
  ) {
    final calc = CalculationService();
    final days = calc.daysUntilWedding(settings);
    if (days == null || days < 0) return const [];

    final now = DateTime.now();
    final hour = settings.reminderHour.clamp(0, 23).toInt();
    final missing = calc.missingItems(items);
    final mustHaveMissing = calc.missingMustHaveItems(items).length;
    final decisions = <NotificationDecision>[];

    if (days > 0) {
      decisions.add(NotificationDecision(
        id: 1001,
        title: 'Düğün geri sayımı',
        body: 'Düğüne $days gün kaldı. Eksiklerin kısa özetini kontrol et.',
        scheduledAt: _nextAt(hour, now),
      ));
    }

    if (settings.weeklySummaryEnabled && missing > 0) {
      decisions.add(NotificationDecision(
        id: 1002,
        title: 'Haftalık hazırlık özeti',
        body: 'Bu hafta $missing eksik kalem görünüyor.',
        scheduledAt: _nextWeeklyAt(hour, now),
      ));
    }

    if (mustHaveMissing > 0 && days <= 90) {
      decisions.add(NotificationDecision(
        id: 1003,
        title: 'Kritik eksikler',
        body: 'Olmazsa olmaz listende $mustHaveMissing önemli eksik var.',
        scheduledAt: _nextAt(hour, now.add(const Duration(days: 1))),
      ));
    }

    final budgetUsage = calc.budgetUsagePercent(settings, items);
    if (settings.targetBudget > 0 && budgetUsage >= .8) {
      decisions.add(NotificationDecision(
        id: 1004,
        title: 'Bütçe uyarısı',
        body: 'Hedef bütçenin %80 sınırına gelindi.',
        scheduledAt: _nextAt(hour, now.add(const Duration(days: 2))),
      ));
    }

    if (missing > 0 && days <= 45) {
      decisions.add(NotificationDecision(
        id: 1005,
        title: 'Yaklaşan hazırlıklar',
        body: 'Düğün yaklaşırken eksik ürünleri önceliğe göre gözden geçir.',
        scheduledAt: _nextAt(hour, now.add(const Duration(days: 3))),
      ));
    }

    return decisions.take(5).toList();
  }

  List<String> previewMessages(AppSettings settings, List<PrepItem> items) {
    final calc = CalculationService();
    final days = calc.daysUntilWedding(settings);
    final mustHaveMissing = calc.missingMustHaveItems(items).length;
    final missing = calc.missingItems(items);
    return [
      'Bu hafta $missing eksik ürünün kaldı.',
      if (days != null) 'Düğüne $days gün kaldı.',
      if (mustHaveMissing > 0)
        'Olmazsa olmaz listende $mustHaveMissing önemli eksik var.',
    ];
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: darwin);
      final initialized = await _plugin.initialize(settings) ?? false;
      if (!initialized) return false;

      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

      const channel = AndroidNotificationChannel(
        'wedding_prep_reminders',
        'Hazırlık hatırlatmaları',
        description: 'Düğün ve çeyiz hazırlığı hatırlatmaları',
        importance: Importance.defaultImportance,
      );
      await androidPlugin?.createNotificationChannel(channel);
      _initialized = true;
      return true;
    } catch (error, stackTrace) {
      developer.log(
        'Notification initialization failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _schedule(NotificationDecision decision) async {
    try {
      await _plugin.zonedSchedule(
        decision.id,
        decision.title,
        decision.body,
        tz.TZDateTime.from(decision.scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'wedding_prep_reminders',
            'Hazırlık hatırlatmaları',
            channelDescription: 'Düğün ve çeyiz hazırlığı hatırlatmaları',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Notification scheduling failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  DateTime _nextAt(int hour, DateTime from) {
    var target = DateTime(from.year, from.month, from.day, hour);
    if (!target.isAfter(DateTime.now())) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }

  DateTime _nextWeeklyAt(int hour, DateTime from) {
    var target = _nextAt(hour, from);
    while (target.weekday != DateTime.monday) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }
}
