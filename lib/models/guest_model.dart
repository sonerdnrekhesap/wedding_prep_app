enum GuestSide { bride, groom, common }

enum GuestStatus { uncertain, coming, notComing }

extension GuestSideText on GuestSide {
  String get label => switch (this) {
        GuestSide.bride => 'Gelin tarafı',
        GuestSide.groom => 'Damat tarafı',
        GuestSide.common => 'Ortak',
      };
}

extension GuestStatusText on GuestStatus {
  String get label => switch (this) {
        GuestStatus.uncertain => 'Belirsiz',
        GuestStatus.coming => 'Gelecek',
        GuestStatus.notComing => 'Gelmeyecek',
      };
}

class Guest {
  const Guest({
    required this.id,
    required this.name,
    this.phone = '',
    required this.side,
    this.guestCount = 1,
    this.status = GuestStatus.uncertain,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final GuestSide side;
  final int guestCount;
  final GuestStatus status;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get personCount => guestCount;

  Guest copyWith({
    String? name,
    String? phone,
    GuestSide? side,
    int? guestCount,
    int? personCount,
    GuestStatus? status,
    String? note,
  }) {
    return Guest(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      side: side ?? this.side,
      guestCount: guestCount ?? personCount ?? this.guestCount,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'side': side.name,
        'guestCount': guestCount,
        'personCount': guestCount,
        'status': status.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Guest.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Guest(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      side: _parseSide(json['side'] as String?),
      guestCount: (json['guestCount'] as num?)?.toInt() ??
          (json['personCount'] as num?)?.toInt() ??
          1,
      status: _parseStatus(json['status'] as String?),
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? now
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? now
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
}

GuestSide _parseSide(String? value) {
  return GuestSide.values.firstWhere(
    (side) => side.name == value,
    orElse: () => GuestSide.common,
  );
}

GuestStatus _parseStatus(String? value) {
  if (value == 'unsure' || value == null) return GuestStatus.uncertain;
  return GuestStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => GuestStatus.uncertain,
  );
}
