import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';

/// Gère la présence en temps réel via Firebase Realtime Database.
///
/// Structure : presence/{conversationUuid}/{userUuid} → {online, ts}
///
/// Le .onDisconnect() de Firebase garantit que l'état passe à "offline"
/// automatiquement si l'app se ferme, crash, ou perd la connexion.
class PresenceService {
  static PresenceService get instance => _instance;
  static final PresenceService _instance = PresenceService._();
  PresenceService._();

  bool _ready = false;

  /// À appeler dans main() après Firebase.initializeApp() réussi.
  void markReady() => _ready = true;

  DatabaseReference _ref(String conversationUuid, String userUuid) =>
      FirebaseDatabase.instance.ref('presence/$conversationUuid/$userUuid');

  /// Signaler que l'utilisateur courant est en ligne dans cette conversation.
  Future<void> goOnline({
    required String conversationUuid,
    required String myUserUuid,
  }) async {
    if (!_ready || conversationUuid.isEmpty || myUserUuid.isEmpty) return;
    try {
      final ref = _ref(conversationUuid, myUserUuid);
      await ref.set({'online': true, 'ts': ServerValue.timestamp});
      // Firebase met automatiquement offline en cas de déconnexion réseau ou de fermeture app
      await ref.onDisconnect().set({'online': false, 'ts': ServerValue.timestamp});
    } catch (e) {
      logger.e('PresenceService.goOnline: $e');
    }
  }

  /// Signaler que l'utilisateur courant est hors ligne (quitte le chat).
  Future<void> goOffline({
    required String conversationUuid,
    required String myUserUuid,
  }) async {
    if (!_ready || conversationUuid.isEmpty || myUserUuid.isEmpty) return;
    try {
      final ref = _ref(conversationUuid, myUserUuid);
      await ref.onDisconnect().cancel();
      await ref.set({'online': false, 'ts': ServerValue.timestamp});
    } catch (e) {
      logger.e('PresenceService.goOffline: $e');
    }
  }

  /// Stream qui émet true/false en temps réel selon l'état de l'autre utilisateur.
  Stream<bool> watch({
    required String conversationUuid,
    required String otherUserUuid,
  }) {
    if (!_ready || conversationUuid.isEmpty || otherUserUuid.isEmpty) {
      return Stream.value(false);
    }
    try {
      return _ref(conversationUuid, otherUserUuid).onValue.map((event) {
        final data = event.snapshot.value as Map?;
        return data?['online'] == true;
      });
    } catch (e) {
      logger.e('PresenceService.watch: $e');
      return Stream.value(false);
    }
  }
}
