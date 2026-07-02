import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/providers/support_provider.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class FaqItem {
  const FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class FaqTopic {
  FaqTopic({
    required this.icon,
    required this.label,
    required this.color,
    required this.items,
  });

  final IconData icon;
  final String label;
  final Color color;
  final List<FaqItem> items;

  factory FaqTopic.fromJson(Map<String, dynamic> json) {
    return FaqTopic(
      icon: _iconFromName(json['icon_name'] as String? ?? ''),
      label: json['label'] as String? ?? '',
      color: Color(json['color'] as int? ?? 0xFF6366F1),
      items: (json['items'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((i) => FaqItem(
                question: i['question'] as String? ?? '',
                answer: i['answer'] as String? ?? '',
              ))
          .toList(),
    );
  }

  static IconData _iconFromName(String name) => _iconMap[name] ?? Icons.help_outline_rounded;

  static const _iconMap = <String, IconData>{
    'payments_rounded':       Icons.payments_rounded,
    'route_rounded':          Icons.route_rounded,
    'person_off_rounded':     Icons.person_off_rounded,
    'badge_rounded':          Icons.badge_rounded,
    'directions_car_rounded': Icons.directions_car_rounded,
    'account_circle_rounded': Icons.account_circle_rounded,
    'star_rounded':           Icons.star_rounded,
    'security_rounded':       Icons.security_rounded,
    'help_outline_rounded':   Icons.help_outline_rounded,
  };
}

// ── Controller ────────────────────────────────────────────────────────────────

class DriverSupportController extends GetxController {
  final _provider = SupportProvider();

  final RxString searchQuery          = ''.obs;
  final RxBool isLoadingFaq           = true.obs;
  final RxBool isLoadingTickets       = true.obs;
  final RxList<FaqTopic> topics       = <FaqTopic>[].obs;
  final RxList<Map<String, dynamic>> tickets = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaq();
    _loadTickets();
  }

  Future<void> _loadFaq() async {
    isLoadingFaq.value = true;
    final result = await _provider.fetchFaq();
    isLoadingFaq.value = false;
    if (result.isSuccess) {
      topics.assignAll(result.data!.map(FaqTopic.fromJson).toList());
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  Future<void> _loadTickets() async {
    isLoadingTickets.value = true;
    final result = await _provider.fetchTickets();
    isLoadingTickets.value = false;
    if (result.isSuccess) {
      tickets.assignAll(result.data!);
    }
  }

  void onSearch(String value) => searchQuery.value = value;

  void onTopicTap(FaqTopic topic) {
    Get.bottomSheet(
      _FaqSheet(topic: topic, items: topic.items),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> onCreateTicket() async {
    final subjectCtrl  = TextEditingController();
    final descCtrl     = TextEditingController();
    final isSubmitting = false.obs;

    await Get.bottomSheet(
      _NewTicketSheet(
        subjectCtrl: subjectCtrl,
        descCtrl: descCtrl,
        isSubmitting: isSubmitting,
        onSubmit: () async {
          final subject     = subjectCtrl.text.trim();
          final description = descCtrl.text.trim();
          if (subject.isEmpty || description.isEmpty) {
            UIHelper().showSnackBar('MINIZON', 'Veuillez remplir tous les champs.', 2);
            return;
          }
          isSubmitting.value = true;
          final result = await _provider.createTicket(subject: subject, description: description);
          isSubmitting.value = false;
          if (result.isSuccess) {
            Get.back();
            UIHelper().showSnackBar('MINIZON', 'Ticket créé avec succès.', 0);
            _loadTickets();
          } else {
            UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onLiveChat() {
    const whatsapp = '+229 21 31 00 01';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.chat_rounded, color: Color(0xFF00A86B), size: 22),
            SizedBox(width: 10),
            Text('Chat avec le support', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temps de réponse moyen : moins de 5 minutes.'),
            const SizedBox(height: 16),
            _ContactOption(
              icon: Icons.phone_rounded,
              color: const Color(0xFF00A86B),
              title: 'WhatsApp / Appel',
              subtitle: whatsapp,
              onTap: () {
                Clipboard.setData(const ClipboardData(text: whatsapp));
                Get.back();
                UIHelper().showSnackBar(
                    'MINIZON', 'Numéro copié. Ouvrez WhatsApp pour démarrer le chat.', 0);
              },
            ),
            const SizedBox(height: 10),
            _ContactOption(
              icon: Icons.headset_mic_rounded,
              color: const Color(0xFF6366F1),
              title: 'Support téléphonique',
              subtitle: '+229 21 31 00 00',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '+229 21 31 00 00'));
                Get.back();
                UIHelper().showSnackBar('MINIZON', 'Numéro copié dans le presse-papiers.', 0);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
        ],
      ),
    );
  }

  void onCall() {
    const supportNumber = '+229 21 31 00 00';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.headset_mic_rounded, color: Color(0xFF00A86B), size: 22),
            SizedBox(width: 10),
            Text('Appeler le support', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Disponible 24h/24 · 7j/7',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                supportNumber,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00A86B),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: supportNumber));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié dans le presse-papiers.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(color: Color(0xFF00A86B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Sheet ─────────────────────────────────────────────────────────────────

class _FaqSheet extends StatefulWidget {
  const _FaqSheet({required this.topic, required this.items});
  final FaqTopic topic;
  final List<FaqItem> items;

  @override
  State<_FaqSheet> createState() => _FaqSheetState();
}

class _FaqSheetState extends State<_FaqSheet> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.topic.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.topic.icon, color: widget.topic.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.topic.label,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(
                        '${widget.items.length} question${widget.items.length > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item   = widget.items[i];
                final isOpen = _expanded == i;
                return GestureDetector(
                  onTap: () => setState(() => _expanded = isOpen ? null : i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.question,
                                style: TextStyle(
                                  fontWeight: isOpen ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 14,
                                  color: isOpen ? widget.topic.color : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: AppColors.textGhost,
                              size: 20,
                            ),
                          ],
                        ),
                        if (isOpen) ...[
                          const SizedBox(height: 10),
                          Text(
                            item.answer,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('Fermer',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── New Ticket Sheet ──────────────────────────────────────────────────────────

class _NewTicketSheet extends StatelessWidget {
  const _NewTicketSheet({
    required this.subjectCtrl,
    required this.descCtrl,
    required this.isSubmitting,
    required this.onSubmit,
  });
  final TextEditingController subjectCtrl;
  final TextEditingController descCtrl;
  final RxBool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Créer un ticket',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Notre équipe vous répondra sous 24h.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              const Text('Sujet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: subjectCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ex : Problème de paiement...',
                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Description',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Décrivez votre problème en détail...',
                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => GestureDetector(
                    onTap: isSubmitting.value ? null : onSubmit,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSubmitting.value ? AppColors.textHint : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Envoyer le ticket',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contact Option ────────────────────────────────────────────────────────────

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, size: 16, color: AppColors.textGhost),
          ],
        ),
      ),
    );
  }
}
