import 'package:flutter/material.dart';

import '../main.dart';
import '../models/guest_model.dart';
import '../services/calculation_service.dart';
import '../widgets/summary_card.dart';

class GuestListPage extends StatelessWidget {
  const GuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final stats = CalculationService().guestStats(controller.guests);

    return Scaffold(
      appBar: AppBar(title: const Text('Davetliler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGuestSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Davetli'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.22,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: [
              SummaryCard(
                title: 'Toplam davetli',
                value: '${stats.totalPeople}',
                icon: Icons.groups_outlined,
              ),
              SummaryCard(
                title: 'Gelecek kişi',
                value: '${stats.comingPeople}',
                icon: Icons.check_circle_outline,
                tint: const Color(0xFF0D9488),
              ),
              SummaryCard(
                title: 'Gelmeyecek',
                value: '${stats.notComingPeople}',
                icon: Icons.cancel_outlined,
                tint: const Color(0xFFB7791F),
              ),
              SummaryCard(
                title: 'Belirsiz',
                value: '${stats.unsurePeople}',
                icon: Icons.help_outline,
                tint: const Color(0xFF5F6FD9),
              ),
              SummaryCard(
                title: 'Gelin tarafı',
                value: '${stats.bridePeople}',
                icon: Icons.favorite_border,
              ),
              SummaryCard(
                title: 'Damat tarafı',
                value: '${stats.groomPeople}',
                icon: Icons.person_outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.guests.isEmpty)
            const Center(child: Text('İlk davetliyi ekle'))
          else
            for (final guest in controller.guests)
              Card(
                child: ListTile(
                  title: Text(guest.name),
                  subtitle: Text(
                    '${guest.side.label} · ${guest.status.label} · ${guest.personCount} kişi',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.deleteGuest(guest),
                  ),
                  onTap: () => _showGuestSheet(context, guest: guest),
                ),
              ),
        ],
      ),
    );
  }

  void _showGuestSheet(BuildContext context, {Guest? guest}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GuestSheet(guest: guest),
    );
  }
}

class _GuestSheet extends StatefulWidget {
  const _GuestSheet({this.guest});

  final Guest? guest;

  @override
  State<_GuestSheet> createState() => _GuestSheetState();
}

class _GuestSheetState extends State<_GuestSheet> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController countController;
  late final TextEditingController noteController;
  late GuestSide side;
  late GuestStatus status;

  @override
  void initState() {
    super.initState();
    final guest = widget.guest;
    nameController = TextEditingController(text: guest?.name ?? '');
    phoneController = TextEditingController(text: guest?.phone ?? '');
    countController =
        TextEditingController(text: (guest?.personCount ?? 1).toString());
    noteController = TextEditingController(text: guest?.note ?? '');
    side = guest?.side ?? GuestSide.common;
    status = guest?.status ?? GuestStatus.unsure;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    countController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'İsim'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefon'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kişi sayısı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GuestSide>(
              value: side,
              decoration: const InputDecoration(labelText: 'Taraf'),
              items: [
                for (final option in GuestSide.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => side = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GuestStatus>(
              value: status,
              decoration: const InputDecoration(labelText: 'Durum'),
              items: [
                for (final option in GuestStatus.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => status = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Not'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final controller = AppScope.of(context);
    if (nameController.text.trim().isEmpty) return;
    final count = int.tryParse(countController.text) ?? 1;
    final guest = widget.guest?.copyWith(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          personCount: count,
          side: side,
          status: status,
          note: noteController.text.trim(),
        ) ??
        controller.newGuest(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          personCount: count,
          side: side,
          status: status,
          note: noteController.text.trim(),
        );
    await controller.addOrUpdateGuest(guest);
    if (mounted) Navigator.pop(context);
  }
}
