import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
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
    final r = AppResponsive(context);
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(r.w(8), topPad + r.h(4), r.w(16), r.h(8)),
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
              child: SizedBox(
                width: r.w(44),
                height: r.w(44),
                child: Icon(Icons.close_rounded,
                    color: AppColors.textPrimary, size: r.text(22)),
              ),
            ),
          ),
          SizedBox(width: r.w(4)),
          // Logo + titre
          Container(
            width: r.w(32),
            height: r.w(32),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(r.radius(8)),
            ),
            child: Icon(Icons.lock_rounded, color: Colors.white, size: r.text(16)),
          ),
          SizedBox(width: r.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Paiement sécurisé',
                  style: AppTextStyles.body(r).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Propulsé par FedaPay',
                  style: AppTextStyles.caption(r).copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          // Badge SSL
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.w(8), vertical: r.h(4)),
            decoration: BoxDecoration(
              color: AppColors.surfaceAccent,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded,
                    color: AppColors.primary, size: r.text(11)),
                SizedBox(width: r.w(3)),
                Text(
                  'SSL',
                  style: AppTextStyles.labelSmall(r).copyWith(
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
    final r = AppResponsive(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: r.w(64),
              height: r.w(64),
              decoration: BoxDecoration(
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(r.radius(18)),
              ),
              child: Icon(Icons.wifi_off_rounded,
                  color: AppColors.danger, size: r.text(32)),
            ),
            SizedBox(height: r.h(16)),
            Text(
              'Impossible de charger la page',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(r),
            ),
            SizedBox(height: r.h(6)),
            Text(
              'Vérifiez votre connexion internet et réessayez.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(r).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: r.h(24)),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: r.text(18)),
              label: Text('Réessayer', style: AppTextStyles.button(r)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: r.w(24), vertical: r.h(12)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.radius(12))),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
