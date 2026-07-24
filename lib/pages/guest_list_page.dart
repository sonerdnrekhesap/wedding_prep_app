import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/guest_model.dart';
import '../services/calculation_service.dart';
import '../services/rsvp_message_service.dart';
import '../theme/app_colors.dart';
import '../widgets/summary_card.dart';
import '../widgets/visual_cards.dart';

enum GuestFilter { all, uncertain, coming, notComing, bride, groom, common }

extension GuestFilterText on GuestFilter {
  String get label => switch (this) {
        GuestFilter.all => 'Tümü',
        GuestFilter.uncertain => 'Belirsiz',
        GuestFilter.coming => 'Gelecek',
        GuestFilter.notComing => 'Gelmeyecek',
        GuestFilter.bride => 'Gelin tarafı',
        GuestFilter.groom => 'Damat tarafı',
        GuestFilter.common => 'Ortak',
      };
}

class GuestListPage extends StatefulWidget {
  const GuestListPage({super.key});

  @override
  State<GuestListPage> createState() => _GuestListPageState();
}

class _GuestListPageState extends State<GuestListPage> {
  final searchController = TextEditingController();
  GuestFilter filter = GuestFilter.all;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final stats = CalculationService().guestStats(controller.guests);
    final guests =
        controller.guests.where(_matchesFilter).where(_matchesSearch).toList()
          ..sort((a, b) {
            final status = a.status.index.compareTo(b.status.index);
            if (status != 0) return status;
            return a.name.compareTo(b.name);
          });

    return Scaffold(
      appBar: AppBar(title: const Text('Davetliler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGuestSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Davetli'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GuestSummaryGrid(stats: stats),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'İsimde veya telefonda ara',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final option in GuestFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(option.label),
                      selected: filter == option,
                      onSelected: (_) => setState(() => filter = option),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (stats.unsurePeople > 0) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareRsvpReminder(),
                icon: const Icon(Icons.chat_outlined),
                label: Text('${stats.unsurePeople} belirsiz davetliye mesaj'),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (controller.guests.isEmpty)
            const EmptyStateCard(
              icon: Icons.groups_outlined,
              title: 'Henüz davetli yok',
              message:
                  'İlk davetliyi ekleyince kişi sayıları burada toparlanır.',
            )
          else if (guests.isEmpty)
            const EmptyStateCard(
              icon: Icons.search_off_outlined,
              title: 'Sonuç yok',
              message: 'Arama veya filtreyi değiştirerek tekrar bakabilirsin.',
            )
          else
            for (final guest in guests)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GuestRow(
                  key: ValueKey(guest.id),
                  guest: guest,
                  onTap: () => _showGuestSheet(guest: guest),
                  onStatusTap: () => _showStatusSelector(guest),
                  onSwipeStatus: (status) => _setGuestStatus(guest, status),
                  onShareRsvp: () => _shareRsvpReminder(guest: guest),
                  onDelete: () => _deleteGuest(guest),
                ),
              ),
        ],
      ),
    );
  }

  bool _matchesSearch(Guest guest) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return guest.name.toLowerCase().contains(query) ||
        guest.phone.toLowerCase().contains(query);
  }

  bool _matchesFilter(Guest guest) => switch (filter) {
        GuestFilter.all => true,
        GuestFilter.uncertain => guest.status == GuestStatus.uncertain,
        GuestFilter.coming => guest.status == GuestStatus.coming,
        GuestFilter.notComing => guest.status == GuestStatus.notComing,
        GuestFilter.bride => guest.side == GuestSide.bride,
        GuestFilter.groom => guest.side == GuestSide.groom,
        GuestFilter.common => guest.side == GuestSide.common,
      };

  Future<void> _setGuestStatus(Guest guest, GuestStatus status) async {
    await AppScope.of(context).addOrUpdateGuest(guest.copyWith(status: status));
  }

  Future<void> _showStatusSelector(Guest guest) async {
    final status = await showModalBottomSheet<GuestStatus>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in GuestStatus.values)
                ListTile(
                  leading: Icon(
                    _statusIcon(option),
                    color: _statusForeground(option),
                  ),
                  title: Text(option.label),
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (status != null) await _setGuestStatus(guest, status);
  }

  Future<void> _deleteGuest(Guest guest) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Davetli silinsin mi?'),
        content: Text(guest.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await AppScope.of(context).deleteGuest(guest);
    }
  }

  Future<void> _shareRsvpReminder({Guest? guest}) async {
    final controller = AppScope.of(context);
    final message = const RsvpMessageService().buildReminder(
      coupleNames: controller.settings.coupleNames,
      guest: guest,
    );
    await Share.share(message, subject: 'Davetli dönüş mesajı');
  }

  Future<void> _showGuestSheet({Guest? guest}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GuestSheet(guest: guest),
    );
  }
}

class _GuestSummaryGrid extends StatelessWidget {
  const _GuestSummaryGrid({required this.stats});

  final GuestStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.36,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      children: [
        SummaryCard(
          title: 'Toplam kişi',
          value: '${stats.totalPeople}',
          icon: Icons.groups_outlined,
        ),
        SummaryCard(
          title: 'Gelecek',
          value: '${stats.comingPeople}',
          icon: Icons.check_circle_outline,
          tint: AppColors.mint,
        ),
        SummaryCard(
          title: 'Gelmeyecek',
          value: '${stats.notComingPeople}',
          icon: Icons.cancel_outlined,
          tint: AppColors.coral,
        ),
        SummaryCard(
          title: 'Belirsiz',
          value: '${stats.unsurePeople}',
          icon: Icons.help_outline,
          tint: AppColors.muted,
        ),
        SummaryCard(
          title: 'Gelin tarafı',
          value: '${stats.bridePeople}',
          icon: Icons.favorite_border,
          tint: AppColors.rose,
        ),
        SummaryCard(
          title: 'Damat tarafı',
          value: '${stats.groomPeople}',
          icon: Icons.person_outline,
          tint: const Color(0xFF7895A6),
        ),
      ],
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({
    super.key,
    required this.guest,
    required this.onTap,
    required this.onStatusTap,
    required this.onSwipeStatus,
    required this.onShareRsvp,
    required this.onDelete,
  });

  final Guest guest;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;
  final ValueChanged<GuestStatus> onSwipeStatus;
  final VoidCallback onShareRsvp;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('guest-${guest.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        onSwipeStatus(
          direction == DismissDirection.startToEnd
              ? GuestStatus.coming
              : GuestStatus.notComing,
        );
        return false;
      },
      background: const _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.mint,
        icon: Icons.check_circle_outline,
        label: 'Gelecek',
      ),
      secondaryBackground: const _SwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.coral,
        icon: Icons.cancel_outlined,
        label: 'Gelmeyecek',
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              guest.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (guest.phone.trim().isNotEmpty)
                            const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: AppColors.muted,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _SideChip(side: guest.side),
                          Text(
                            '${guest.guestCount} kişi',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          _StatusChip(status: guest.status, onTap: onStatusTap),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Davetli aksiyonları',
                  onSelected: (value) {
                    if (value == 'rsvp') onShareRsvp();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'rsvp',
                      child: Row(
                        children: [
                          Icon(Icons.chat_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Mesaj metni paylaş'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18),
                          SizedBox(width: 10),
                          Text('Sil'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) Text(label, style: TextStyle(color: color)),
          if (!isLeft) const SizedBox(width: 8),
          Icon(icon, color: color),
          if (isLeft) const SizedBox(width: 8),
          if (isLeft) Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.onTap});

  final GuestStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar:
          Icon(_statusIcon(status), size: 16, color: _statusForeground(status)),
      label: Text(status.label),
      backgroundColor: _statusBackground(status),
      labelStyle: TextStyle(
        color: _statusForeground(status),
        fontWeight: FontWeight.w800,
      ),
      onPressed: onTap,
    );
  }
}

class _SideChip extends StatelessWidget {
  const _SideChip({required this.side});

  final GuestSide side;

  @override
  Widget build(BuildContext context) {
    final color = switch (side) {
      GuestSide.bride => AppColors.rose,
      GuestSide.groom => const Color(0xFF7895A6),
      GuestSide.common => AppColors.gold,
    };
    return Chip(
      label: Text(side.label),
      backgroundColor: color.withValues(alpha: 0.14),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      side: BorderSide(color: color.withValues(alpha: 0.18)),
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

  @override
  void initState() {
    super.initState();
    final guest = widget.guest;
    nameController = TextEditingController(text: guest?.name ?? '');
    phoneController = TextEditingController(text: guest?.phone ?? '');
    countController =
        TextEditingController(text: (guest?.guestCount ?? 1).toString());
    noteController = TextEditingController(text: guest?.note ?? '');
    side = guest?.side ?? GuestSide.common;
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
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.guest == null ? 'Davetli ekle' : 'Davetliyi düzenle',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'İsim'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kişi sayısı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GuestSide>(
              initialValue: side,
              decoration: const InputDecoration(labelText: 'Taraf'),
              items: [
                for (final option in GuestSide.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => side = value);
              },
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('İsteğe bağlı detay'),
              childrenPadding: const EdgeInsets.only(bottom: 10),
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Not'),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
    final count = int.tryParse(countController.text.trim()) ?? 1;
    final guest = widget.guest?.copyWith(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          guestCount: count < 1 ? 1 : count,
          side: side,
          note: noteController.text.trim(),
        ) ??
        controller.newGuest(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          personCount: count < 1 ? 1 : count,
          side: side,
          status: GuestStatus.uncertain,
          note: noteController.text.trim(),
        );
    await controller.addOrUpdateGuest(guest);
    if (mounted) Navigator.pop(context);
  }
}

IconData _statusIcon(GuestStatus status) => switch (status) {
      GuestStatus.uncertain => Icons.help_outline,
      GuestStatus.coming => Icons.check_circle_outline,
      GuestStatus.notComing => Icons.cancel_outlined,
    };

Color _statusBackground(GuestStatus status) => switch (status) {
      GuestStatus.uncertain => AppColors.creamDeep,
      GuestStatus.coming => AppColors.mintSoft,
      GuestStatus.notComing => AppColors.coral.withValues(alpha: 0.14),
    };

Color _statusForeground(GuestStatus status) => switch (status) {
      GuestStatus.uncertain => AppColors.muted,
      GuestStatus.coming => AppColors.mint,
      GuestStatus.notComing => AppColors.coral,
    };
