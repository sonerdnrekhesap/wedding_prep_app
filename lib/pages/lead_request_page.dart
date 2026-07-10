import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../models/lead_request_model.dart';
import '../services/formatters.dart';

class LeadRequestPage extends StatefulWidget {
  const LeadRequestPage({super.key});

  @override
  State<LeadRequestPage> createState() => _LeadRequestPageState();
}

class _LeadRequestPageState extends State<LeadRequestPage> {
  static const categories = [
    'Düğün salonu',
    'Fotoğrafçı',
    'Kuaför / makyaj',
    'Organizasyon',
    'Gelinlik',
    'Beyaz eşya paketi',
    'Balayı',
  ];

  final cityController = TextEditingController();
  final budgetController = TextEditingController();
  final guestCountController = TextEditingController();
  final contactController = TextEditingController();
  final noteController = TextEditingController();
  String category = categories.first;
  DateTime? eventDate;

  @override
  void dispose() {
    cityController.dispose();
    budgetController.dispose();
    guestCountController.dispose();
    contactController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leads = AppScope.of(context).leads;
    return Scaffold(
      appBar: AppBar(title: const Text('Teklif Al')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: [
              for (final option in categories)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => category = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(labelText: 'Şehir'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(eventDate == null
                ? 'Tarih seç'
                : '${eventDate!.day}.${eventDate!.month}.${eventDate!.year}'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tahmini bütçe'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: guestCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Kişi sayısı'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contactController,
            decoration:
                const InputDecoration(labelText: 'Telefon veya e-posta'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Not'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Teklif isteğini kaydet'),
          ),
          const SizedBox(height: 18),
          if (leads.isNotEmpty) ...[
            Text(
              'Kaydedilen talepler',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final lead in leads.reversed.take(10))
              Card(
                child: ListTile(
                  title: Text(lead.category),
                  subtitle: Text(
                    '${lead.city} · ${money(lead.estimatedBudget)} · ${lead.contact}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: eventDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => eventDate = picked);
  }

  Future<void> _save() async {
    if (cityController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şehir ve iletişim bilgisi gerekli.')),
      );
      return;
    }
    await AppScope.of(context).addLead(
      LeadRequest(
        id: const Uuid().v4(),
        category: category,
        city: cityController.text.trim(),
        eventDate: eventDate,
        estimatedBudget: parseMoney(budgetController.text),
        guestCount: int.tryParse(guestCountController.text.trim()) ?? 0,
        contact: contactController.text.trim(),
        note: noteController.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Talep kaydedildi.')),
    );
    cityController.clear();
    budgetController.clear();
    guestCountController.clear();
    contactController.clear();
    noteController.clear();
    setState(() => eventDate = null);
  }
}
