import 'package:covoiturage_benin_app/app/core/controller/loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loading_indicator.dart';

class UIHelper {
  final LoadingController loadingController = LoadingController.instance;
  final tKey = GlobalKey(debugLabel: 'overlay_parent');

  OverlayEntry? entry;

  void showOverlay(BuildContext context) {
    entry ??= OverlayEntry(
      builder: (context) => Scaffold(
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        body: const Center(
          child: LoadingIndicator(),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
    loadingController.showLoading();
  }

  void hideOverlay() {
    if (entry != null) {
      entry!.remove();
      entry = null;
      loadingController.hideLoading();
    }
  }

  //snackBars
  //messageType 0: sucess, 1: warning, 2: error
  void showSnackBar(String title, String message, int messageType) {
    Get.showSnackbar(GetSnackBar(
      title: title.isEmpty ? " " : title,
      message: message.isEmpty ? " " : message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: messageType == 0
          ? const Color(0xFF06C2A3)
          : messageType == 1
              ? const Color.fromARGB(62, 33, 31, 3)
              : const Color(0xFFE80B0B),
      margin: const EdgeInsets.only(
          left: 10, right: 10, bottom: kBottomNavigationBarHeight),
      snackStyle: SnackStyle.GROUNDED,
      mainButton: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {
          Get.back(); // Close the snackbar
        },
      ),
    ));
  }

  /* void showCustomDialog(BuildContext context,
      {required String title,
      required String message,
      String onConfirmMessage = 'Confirmer',
      String onBackMessage = 'Annuler',
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return kIsWeb
            ? AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(onBackMessage),
                  ),
                  TextButton(
                    onPressed: onConfirm,
                    child: Text(onConfirmMessage),
                  ),
                ],
              )
            : Platform.isIOS
                ? CupertinoAlertDialog(
                    title: Text(title),
                    content: Text(message),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Annuler'),
                      ),
                      CupertinoDialogAction(
                        onPressed: onConfirm,
                        child: Text(onConfirmMessage),
                      ),
                    ],
                  )
                : AlertDialog(
                    title: Text(title),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: onConfirm,
                        child: Text(onConfirmMessage),
                      ),
                    ],
                  );
      },
    );
  }
*/

  void showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget child,
    String? secondaryActionText,
    String primaryActionText = 'Confirmer',
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            contentPadding: const EdgeInsets.all(25),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF121212),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Color(0x4C121212),
                    thickness: 0.5,
                  ),
                  child,
                  const Divider(
                    color: Color(0x4C121212),
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 10),
                 ],
              ),
            ),
          );
        });
  }
}