class AppSettings {
  const AppSettings({
    this.weddingDate,
    this.targetBudget = 0,
    this.brideName = '',
    this.groomName = '',
    this.hasCompletedOnboarding = false,
  });

  final DateTime? weddingDate;
  final double targetBudget;
  final String brideName;
  final String groomName;
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
    bool? hasCompletedOnboarding,
    bool clearWeddingDate = false,
  }) {
    return AppSettings(
      weddingDate: clearWeddingDate ? null : (weddingDate ?? this.weddingDate),
      targetBudget: targetBudget ?? this.targetBudget,
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'weddingDate': weddingDate?.toIso8601String(),
        'targetBudget': targetBudget,
        'brideName': brideName,
        'groomName': groomName,
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
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }
}
