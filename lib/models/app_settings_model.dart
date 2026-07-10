class AppSettings {
  const AppSettings({
    this.weddingDate,
    this.targetBudget = 0,
    this.brideName = '',
    this.groomName = '',
    this.isPremium = false,
    this.notificationsEnabled = false,
    this.reminderHour = 20,
    this.weeklySummaryEnabled = true,
    this.paymentRemindersEnabled = true,
    this.hasCompletedOnboarding = false,
  });

  final DateTime? weddingDate;
  final double targetBudget;
  final String brideName;
  final String groomName;
  final bool isPremium;
  final bool notificationsEnabled;
  final int reminderHour;
  final bool weeklySummaryEnabled;
  final bool paymentRemindersEnabled;
  final bool hasCompletedOnboarding;

  String get coupleNames {
    final names = [brideName, groomName].where((name) => name.isNotEmpty);
    return names.join(' & ');
  }

  AppSettings copyWith({
    DateTime? weddingDate,
    double? targetBudget,
    String? brideName,
    String? groomName,
    bool? isPremium,
    bool? notificationsEnabled,
    int? reminderHour,
    bool? weeklySummaryEnabled,
    bool? paymentRemindersEnabled,
    bool? hasCompletedOnboarding,
    bool clearWeddingDate = false,
  }) {
    return AppSettings(
      weddingDate: clearWeddingDate ? null : (weddingDate ?? this.weddingDate),
      targetBudget: targetBudget ?? this.targetBudget,
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      isPremium: isPremium ?? this.isPremium,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      weeklySummaryEnabled:
          weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      paymentRemindersEnabled:
          paymentRemindersEnabled ?? this.paymentRemindersEnabled,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  AppSettings sanitized() {
    return AppSettings(
      weddingDate: weddingDate,
      targetBudget: targetBudget < 0 ? 0 : targetBudget,
      brideName: brideName.trim(),
      groomName: groomName.trim(),
      isPremium: isPremium,
      notificationsEnabled: notificationsEnabled,
      reminderHour: reminderHour.clamp(0, 23).toInt(),
      weeklySummaryEnabled: weeklySummaryEnabled,
      paymentRemindersEnabled: paymentRemindersEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'weddingDate': weddingDate?.toIso8601String(),
        'targetBudget': targetBudget,
        'brideName': brideName,
        'groomName': groomName,
        'isPremium': isPremium,
        'notificationsEnabled': notificationsEnabled,
        'reminderHour': reminderHour,
        'weeklySummaryEnabled': weeklySummaryEnabled,
        'paymentRemindersEnabled': paymentRemindersEnabled,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final legacyNames = (json['coupleNames'] as String? ?? '').trim();
    final legacyParts = legacyNames
        .split(RegExp(r'\s*(?:&|\+|,| ve )\s*', caseSensitive: false))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    return AppSettings(
      weddingDate: json['weddingDate'] == null
          ? null
          : DateTime.parse(json['weddingDate'] as String),
      targetBudget: (json['targetBudget'] as num?)?.toDouble() ?? 0,
      brideName: json['brideName'] as String? ??
          (legacyParts.isNotEmpty ? legacyParts.first.trim() : ''),
      groomName: json['groomName'] as String? ??
          (legacyParts.length > 1
              ? legacyParts.sublist(1).join(' ').trim()
              : ''),
      isPremium: json['isPremium'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 20,
      weeklySummaryEnabled: json['weeklySummaryEnabled'] as bool? ?? true,
      paymentRemindersEnabled:
          json['paymentRemindersEnabled'] as bool? ?? true,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    ).sanitized();
  }
}
