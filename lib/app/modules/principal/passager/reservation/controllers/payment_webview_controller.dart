import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../search/controllers/search_controller.dart';

class PaymentWebviewController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  late final WebViewController webViewController;

  final RxBool isLoading = true.obs;
  final RxInt loadingProgress = 0.obs;
  final RxBool hasError = false.obs;
  final RxBool isPolling = false.obs;

  String _paymentUrl = '';
  String _paymentUuid = '';
  String _bookingUuid = '';
  SearchRide? _ride;
  int _amount = 0;
  int _seats = 0;

  Timer? _pollingTimer;
  int _pollCount = 0;
  bool _navigationDone = false;

  // Max 40 polls × 3s = 120s, then show timeout message
  static const int _maxPolls = 40;

  // Chrome mobile user-agent to avoid FedaPay detecting WebView
  static const String _mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0.0.0 Mobile Safari/537.36';

  static const String _pageFixJs = r'''
    (function() {
      var vp = document.querySelector('meta[name="viewport"]');
      if (!vp) {
        vp = document.createElement('meta');
        vp.name = 'viewport';
        document.head.appendChild(vp);
      }
      vp.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0';

      window.open = function(url, target, features) {
        if (url && url !== 'about:blank') window.location.href = url;
        return window;
      };
      document.addEventListener('click', function(e) {
        var el = e.target;
        while (el && el.tagName !== 'A') el = el.parentElement;
        if (el && el.getAttribute('target') === '_blank' && el.href) {
          e.preventDefault();
          window.location.href = el.href;
        }
      }, true);

      function checkPageStatus() {
        var body = (document.body && document.body.innerText) || '';
        var lower = body.toLowerCase();
        if (lower.includes('paiement réussi') ||
            lower.includes('transaction réussie') ||
            lower.includes('payment successful') ||
            lower.includes('approved') ||
            lower.includes('félicitations') ||
            lower.includes('votre paiement a été') ||
            lower.includes('payment approved')) {
          PaymentStatus.postMessage('success');
        } else if (lower.includes('transaction échouée') ||
                   lower.includes('paiement échoué') ||
                   lower.includes('payment failed') ||
                   lower.includes('échec du paiement') ||
                   lower.includes('annulé') ||
                   lower.includes('cancelled')) {
          PaymentStatus.postMessage('failed');
        }
      }

      var observer = new MutationObserver(function() { checkPageStatus(); });
      observer.observe(document.body, { childList: true, subtree: true, characterData: true });
      setTimeout(checkPageStatus, 1000);
    })();
  ''';

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _paymentUrl = (args['paymentUrl'] as String?) ?? '';
      _paymentUuid = (args['paymentUuid'] as String?) ?? '';
      _bookingUuid = (args['bookingUuid'] as String?) ?? '';
      final r = args['ride'];
      if (r is SearchRide) _ride = r;
      final amount = args['amount'];
      if (amount is int) _amount = amount;
      final seats = args['seats'];
      if (seats is int) _seats = seats;
    }
    _initWebView();
  }

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_mobileUserAgent)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'PaymentStatus',
        onMessageReceived: (JavaScriptMessage msg) {
          if (msg.message == 'success') {
            _onFedapayComplete();
          } else if (msg.message == 'failed') {
            _onFedapayFailed();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) => loadingProgress.value = progress,
          onPageStarted: (_) {
            isLoading.value = true;
            hasError.value = false;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            webViewController.runJavaScript(_pageFixJs);
            _detectResult(url);
          },
          onNavigationRequest: (NavigationRequest req) {
            final url = req.url;
            if (url.startsWith('http://') || url.startsWith('https://')) {
              _detectResult(url);
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? true) {
              isLoading.value = false;
              hasError.value = true;
            }
          },
        ),
      );

    if (_paymentUrl.isNotEmpty) {
      webViewController.loadRequest(Uri.parse(_paymentUrl));
    }
  }

  void _detectResult(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('/payment/success') ||
        lower.contains('/checkout/success') ||
        lower.contains('/pay/success') ||
        lower.contains('payment_success') ||
        lower.contains('status=approved') ||
        lower.contains('status=success') ||
        lower.contains('transaction=success') ||
        lower.contains('payment=success')) {
      _onFedapayComplete();
      return;
    }
    if (lower.contains('/payment/failed') ||
        lower.contains('/checkout/failed') ||
        lower.contains('/pay/failed') ||
        lower.contains('status=failed') ||
        lower.contains('status=cancelled') ||
        lower.contains('status=canceled') ||
        lower.contains('payment=failed') ||
        lower.contains('transaction=failed')) {
      _onFedapayFailed();
    }
  }

  // ── Step 4: Poll payment status until backend confirms ────────────────────

  void _onFedapayComplete() {
    if (_navigationDone) return;
    if (_paymentUuid.isNotEmpty) {
      _startPolling();
    } else {
      // No paymentUuid — navigate directly (fallback)
      _doNavigateSuccess();
    }
  }

  void _onFedapayFailed() {
    _cancelPolling();
    Get.back();
  }

  void _startPolling() {
    if (_navigationDone) return;
    if (_pollingTimer?.isActive ?? false) return;
    isPolling.value = true;
    _pollCount = 0;
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _pollOnce());
    _pollOnce(); // immediate first poll
  }

  Future<void> _pollOnce() async {
    if (_navigationDone) {
      _cancelPolling();
      return;
    }
    _pollCount++;
    if (_pollCount > _maxPolls) {
      _cancelPolling();
      logger.w('paymentPolling: timeout after ${_maxPolls * 3}s');
      UIHelper().showSnackBar(
        'MINIZON',
        'En attente de confirmation du paiement. Vérifiez vos réservations dans quelques instants.',
        5,
      );
      return;
    }

    logger.d('paymentPolling[$_pollCount] uuid=$_paymentUuid');
    final result = await _service.fetchPaymentStatus(_paymentUuid);
    if (!result.isSuccess) return; // network error — keep polling

    final data = result.data!;
    logger.d('paymentPolling status=${data.status}');

    if (data.status == 'locked' || data.status == 'success') {
      _cancelPolling();
      _doNavigateSuccess(
        transactionRef: data.transactionRef.isNotEmpty ? data.transactionRef : null,
        amount: data.grossAmount > 0 ? data.grossAmount : null,
      );
    } else if (data.status == 'failed') {
      _cancelPolling();
      UIHelper().showSnackBar(
          'MINIZON', 'Paiement échoué. Veuillez réessayer.', 3);
    }
    // 'pending' → keep polling
  }

  void _cancelPolling() {
    _pollingTimer?.cancel();
    isPolling.value = false;
  }

  void _doNavigateSuccess({String? transactionRef, int? amount}) {
    if (_navigationDone) return;
    _navigationDone = true;
    _cancelPolling();
    Get.offNamed(AppRoutes.passengerPaymentSuccess, arguments: {
      'ride': _ride,
      'bookingUuid': _bookingUuid,
      'seats': _seats,
      'amount': amount ?? _amount,
      if (transactionRef != null) 'ref': transactionRef,
    });
  }

  void reload() {
    hasError.value = false;
    _cancelPolling();
    _navigationDone = false;
    if (_paymentUrl.isNotEmpty) {
      webViewController.loadRequest(Uri.parse(_paymentUrl));
    }
  }

  @override
  void onClose() {
    _cancelPolling();
    super.onClose();
  }
}
