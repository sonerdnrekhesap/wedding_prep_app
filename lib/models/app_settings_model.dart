enum PreparationType { onlyCeyiz, ceyizAndWedding, full }

extension PreparationTypeText on PreparationType {
  String get label => switch (this) {
        PreparationType.onlyCeyiz => 'Sadece çeyiz',
        PreparationType.ceyizAndWedding => 'Çeyiz + düğün',
        PreparationType.full => 'Tam evlilik hazırlığı',
      };
}

class AppSettings {
  const AppSettings({
    this.weddingDate,
    this.targetBudget = 0,
    this.coupleNames = '',
    this.preparationType = PreparationType.full,
    this.hasCompletedOnboarding = false,
  });

  final DateTime? weddingDate;
  final double targetBudget;
  final String coupleNames;
  final PreparationType preparationType;
  final bool hasCompletedOnboarding;

  AppSettings copyWith({
    DateTime? weddingDate,
    double? targetBudget,
    String? coupleNames,
    PreparationType? preparationType,
    bool? hasCompletedOnboarding,
    bool clearWeddingDate = false,
  }) {
    return AppSettings(
      weddingDate: clearWeddingDate ? null : (weddingDate ?? this.weddingDate),
      targetBudget: targetBudget ?? this.targetBudget,
      coupleNames: coupleNames ?? this.coupleNames,
      preparationType: preparationType ?? this.preparationType,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'weddingDate': weddingDate?.toIso8601String(),
        'targetBudget': targetBudget,
        'coupleNames': coupleNames,
        'preparationType': preparationType.name,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        weddingDate: json['weddingDate'] == null
            ? null
            : DateTime.parse(json['weddingDate'] as String),
        targetBudget: (json['targetBudget'] as num?)?.toDouble() ?? 0,
        coupleNames: json['coupleNames'] as String? ?? '',
        preparationType: PreparationType.values.byName(
          json['preparationType'] as String? ?? PreparationType.full.name,
        ),
        hasCompletedOnboarding:
            json['hasCompletedOnboarding'] as bool? ?? false,
      );
}
