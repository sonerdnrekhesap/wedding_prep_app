class LeadRequest {
  const LeadRequest({
    required this.id,
    required this.category,
    required this.city,
    required this.eventDate,
    required this.estimatedBudget,
    required this.guestCount,
    required this.contact,
    this.note = '',
    required this.createdAt,
  });

  final String id;
  final String category;
  final String city;
  final DateTime? eventDate;
  final double estimatedBudget;
  final int guestCount;
  final String contact;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'city': city,
        'eventDate': eventDate?.toIso8601String(),
        'estimatedBudget': estimatedBudget,
        'guestCount': guestCount,
        'contact': contact,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  LeadRequest sanitized() {
    return LeadRequest(
      id: id.trim(),
      category: category.trim(),
      city: city.trim(),
      eventDate: eventDate,
      estimatedBudget: estimatedBudget < 0 ? 0 : estimatedBudget,
      guestCount: guestCount < 0 ? 0 : guestCount,
      contact: contact.trim(),
      note: note.trim(),
      createdAt: createdAt,
    );
  }

  factory LeadRequest.fromJson(Map<String, dynamic> json) => LeadRequest(
        id: json['id'] as String,
        category: json['category'] as String? ?? '',
        city: json['city'] as String? ?? '',
        eventDate: json['eventDate'] == null
            ? null
            : DateTime.parse(json['eventDate'] as String),
        estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble() ?? 0,
        guestCount: (json['guestCount'] as num?)?.toInt() ?? 0,
        contact: json['contact'] as String? ?? '',
        note: json['note'] as String? ?? '',
        createdAt: json['createdAt'] == null
            ? DateTime.now()
            : DateTime.parse(json['createdAt'] as String),
      ).sanitized();
}
