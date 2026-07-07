enum GuestSide { bride, groom, common }

enum GuestStatus { coming, notComing, unsure }

extension GuestSideText on GuestSide {
  String get label => switch (this) {
        GuestSide.bride => 'Gelin',
        GuestSide.groom => 'Damat',
        GuestSide.common => 'Ortak',
      };
}

extension GuestStatusText on GuestStatus {
  String get label => switch (this) {
        GuestStatus.coming => 'Gelecek',
        GuestStatus.notComing => 'Gelmeyecek',
        GuestStatus.unsure => 'Belirsiz',
      };
}

class Guest {
  const Guest({
    required this.id,
    required this.name,
    this.phone = '',
    required this.side,
    this.personCount = 1,
    required this.status,
    this.note = '',
  });

  final String id;
  final String name;
  final String phone;
  final GuestSide side;
  final int personCount;
  final GuestStatus status;
  final String note;

  Guest copyWith({
    String? name,
    String? phone,
    GuestSide? side,
    int? personCount,
    GuestStatus? status,
    String? note,
  }) {
    return Guest(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      side: side ?? this.side,
      personCount: personCount ?? this.personCount,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'side': side.name,
        'personCount': personCount,
        'status': status.name,
        'note': note,
      };

  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        side: GuestSide.values.byName(json['side'] as String),
        personCount: json['personCount'] as int? ?? 1,
        status: GuestStatus.values.byName(json['status'] as String),
        note: json['note'] as String? ?? '',
      );
}
