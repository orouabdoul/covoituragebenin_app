import 'package:get/get.dart';

enum RefundHistoryStatus { pending, underReview, approved, refunded, rejected }

class RefundHistoryItem {
  const RefundHistoryItem({
    required this.id,
    required this.route,
    required this.date,
    required this.amount,
    required this.reason,
    required this.status,
    this.processedDate,
  });

  final String id;
  final String route;
  final String date;
  final String amount;
  final String reason;
  final RefundHistoryStatus status;
  final String? processedDate;
}

class RefundHistoryController extends GetxController {
  final List<RefundHistoryItem> items = const [
    RefundHistoryItem(
      id: 'RMB-001',
      route: 'Cotonou → Parakou',
      date: '24 juin 2026',
      amount: '3 500 FCFA',
      reason: 'Conducteur absent au rendez-vous',
      status: RefundHistoryStatus.refunded,
      processedDate: '26 juin 2026',
    ),
    RefundHistoryItem(
      id: 'RMB-002',
      route: 'Cotonou → Bohicon',
      date: '23 juin 2026',
      amount: '2 000 FCFA',
      reason: 'Trajet annulé par le conducteur',
      status: RefundHistoryStatus.approved,
      processedDate: '25 juin 2026',
    ),
    RefundHistoryItem(
      id: 'RMB-003',
      route: 'Cotonou → Porto-Novo',
      date: '20 juin 2026',
      amount: '1 600 FCFA',
      reason: 'Double paiement accidentel',
      status: RefundHistoryStatus.underReview,
    ),
    RefundHistoryItem(
      id: 'RMB-004',
      route: 'Cotonou → Ouidah',
      date: '18 juin 2026',
      amount: '1 500 FCFA',
      reason: 'Trajet non conforme à la description',
      status: RefundHistoryStatus.rejected,
      processedDate: '20 juin 2026',
    ),
    RefundHistoryItem(
      id: 'RMB-005',
      route: 'Cotonou → Abomey-Calavi',
      date: '15 juin 2026',
      amount: '4 000 FCFA',
      reason: 'Problème de sécurité',
      status: RefundHistoryStatus.pending,
    ),
  ];
}
