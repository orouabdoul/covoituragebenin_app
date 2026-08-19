import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import '../controllers/payment_webview_controller.dart';

class PaymentWebviewView extends GetView<PaymentWebviewController> {
  const PaymentWebviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _TopBar(),
          Expanded(
            child: Stack(
              children: [
                // WebView plein écran — jamais retiré de l'arbre
                Positioned.fill(
                  child: WebViewWidget(
                      controller: controller.webViewController),
                ),

                // Barre de progression verte en haut
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Obx(() {
                    final progress = controller.loadingProgress.value;
                    final loading = controller.isLoading.value;
                    if (!loading || progress >= 100) {
                      return const SizedBox.shrink();
                    }
                    return LinearProgressIndicator(
                      value: progress / 100.0,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      minHeight: 3,
                    );
                  }),
                ),

                // Overlay erreur par-dessus le WebView
                Positioned.fill(
                  child: Obx(() {
                    if (!controller.hasError.value) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      color: Colors.white,
                      child: _ErrorState(onRetry: controller.reload),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre de titre personnalisée ───────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPad + 4, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Bouton retour
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(9999),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close_rounded,
                    color: AppColors.textPrimary, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Logo + titre
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Paiement sécurisé',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Propulsé par FedaPay',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Badge SSL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAccent,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_user_rounded,
                    color: AppColors.primary, size: 11),
                SizedBox(width: 3),
                Text(
                  'SSL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── État erreur ────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.danger, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger la page',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vérifiez votre connexion internet et réessayez.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
