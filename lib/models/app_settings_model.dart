class AppSettings {
  const AppSettings({
    this.weddingDate,
    this.targetBudget = 0,
    this.brideName = '',
    this.groomName = '',
    this.isPremium = false,
    this.notificationsEnabled = false,
    this.hasCompletedOnboarding = false,
  });

  final DateTime? weddingDate;
  final double targetBudget;
  final String brideName;
  final String groomName;
  final bool isPremium;
  final bool notificationsEnabled;
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
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'weddingDate': weddingDate?.toIso8601String(),
        'targetBudget': targetBudget,
        'brideName': brideName,
        'groomName': groomName,
        'isPremium': isPremium,
        'notificationsEnabled': notificationsEnabled,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final legacyNames = (json['coupleNames'] as String? ?? '').trim();
    final legacyParts = legacyNames
        .split(RegExp(r'\s*(?:&|\+|,| ve )\s*', caseSensitive: false))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    return AppSettings(
      weddingDate: _parseDate(json['weddingDate']),
      targetBudget: _safeBudget(json['targetBudget']),
      brideName: json['brideName'] as String? ??
          (legacyParts.isNotEmpty ? legacyParts.first.trim() : ''),
      groomName: json['groomName'] as String? ??
          (legacyParts.length > 1
              ? legacyParts.sublist(1).join(' ').trim()
              : ''),
      isPremium: json['isPremium'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }
}

double _safeBudget(Object? value) {
  final parsed = value is num ? value.toDouble() : null;
  if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
    return 0;
  }
  return parsed;
}

DateTime? _parseDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
