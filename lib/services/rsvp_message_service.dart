import '../models/guest_model.dart';

class RsvpMessageService {
  const RsvpMessageService();

  String buildReminder({
    required String coupleNames,
    Guest? guest,
  }) {
    final greeting = guest == null || guest.name.trim().isEmpty
        ? 'Merhaba'
        : 'Merhaba ${guest.name.trim()}';
    final owner = coupleNames.trim().isEmpty ? 'düğünümüz' : coupleNames.trim();
    return '$greeting, $owner için davetli listemizi netleştiriyoruz. '
        'Katılıp katılamayacağını bize kısa bir mesajla iletebilir misin? '
        'Şimdiden çok teşekkür ederiz.';
  }
}
