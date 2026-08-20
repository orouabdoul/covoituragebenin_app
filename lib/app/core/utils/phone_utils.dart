import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class PhoneUtils {
  static Future<void> call(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Numéro non disponible.', 2);
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      UIHelper().showSnackBar('MINIZON', 'Impossible de lancer l\'appel.', 2);
    }
  }
}
