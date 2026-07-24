import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/guest_model.dart';
import 'package:wedding_prep_app/services/rsvp_message_service.dart';

void main() {
  test('buildReminder personalizes guest and couple names', () {
    final message = const RsvpMessageService().buildReminder(
      coupleNames: 'Ayşe & Can',
      guest: Guest(
        id: 'guest-1',
        name: 'Deniz',
        side: GuestSide.common,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

    expect(message, contains('Merhaba Deniz'));
    expect(message, contains('Ayşe & Can'));
    expect(message, contains('Katılıp katılamayacağını'));
  });

  test('buildReminder has safe generic fallback', () {
    final message = const RsvpMessageService().buildReminder(
      coupleNames: '',
    );

    expect(message, startsWith('Merhaba'));
    expect(message, contains('düğünümüz'));
  });
}
