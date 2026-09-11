path = r'lib/app/core/services/push_notification/push_notification_service.dart'
with open(path, encoding='utf-8') as f:
    content = f.read()

old = """      // ── Messagerie ────────────────────────────────────────────────────────
      case 'message_new':
      case 'new_message':
        if (isDriver) {
          Get.toNamed(
            convUuid != null ? AppRoutes.driverMessageDetail : AppRoutes.driverMessages,
            arguments: convUuid != null ? {'uuid': convUuid} : null,
          );
        } else {
          Get.toNamed(
            convUuid != null ? AppRoutes.passengerMessageDetail : AppRoutes.passengerMessages,
            arguments: convUuid != null ? {'uuid': convUuid} : null,
          );
        }"""

new = """      // ── Messagerie ────────────────────────────────────────────────────────
      // Toujours passer par le dashboard pour conserver la bottom nav bar.
      case 'message_new':
      case 'new_message':
        if (isDriver) {
          if (Get.isRegistered<BottonNavController>()) {
            BottonNavController.goToTab(3);
          } else {
            Get.offAllNamed(AppRoutes.dashboardDriver, arguments: 3);
          }
          if (convUuid != null) {
            Get.toNamed(AppRoutes.driverMessageDetail, arguments: {'uuid': convUuid});
          }
        } else {
          if (Get.isRegistered<BottonNavController>()) {
            BottonNavController.goToTab(3);
          } else {
            Get.offAllNamed(AppRoutes.dashboardPassenger, arguments: 3);
          }
          if (convUuid != null) {
            Get.toNamed(AppRoutes.passengerMessageDetail, arguments: {'uuid': convUuid});
          }
        }"""

assert old in content, 'Pattern not found!'
content = content.replace(old, new)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('OK')
