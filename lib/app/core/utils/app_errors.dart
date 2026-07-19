enum AppError {
  cancelled,
  invalidOtp,
  expiredOtp,
  permissionDenied,
  unexpected,
  contactAlreadyInUse,
  userNotFound,
  validationError,
  socket,
  serverTimeout,
  wrongPin,
  wrongEmailAndPasswordCombination,
  wrongPhonenumber,
  unAuthenticated,
  phoneAlreadyInUse,
  endpointNotAvailable,
  tripDataInvalid,
  tripNotFound,
  refundAlreadySubmitted,
  paymentProviderError;

  String get message {
    switch (this) {
      case AppError.socket:
        return 'Vérifiez votre connexion internet.';
      case AppError.serverTimeout:
        return 'Le serveur ne répond pas. Vérifiez votre réseau et réessayez.';
      case AppError.invalidOtp:
      case AppError.expiredOtp:
        return 'Code OTP incorrect ou expiré.';
      case AppError.userNotFound:
        return 'Utilisateur introuvable.';
      case AppError.validationError:
        return 'Numéro de téléphone invalide.';
      case AppError.phoneAlreadyInUse:
        return 'Ce numéro est déjà utilisé.';
      case AppError.unAuthenticated:
        return 'Session expirée. Reconnectez-vous.';
      case AppError.endpointNotAvailable:
        return 'Cette fonctionnalité n\'est pas encore disponible sur le serveur.';
      case AppError.tripDataInvalid:
        return 'Données invalides. Vérifiez les informations du trajet.';
      case AppError.tripNotFound:
        return 'Ce trajet n\'est plus disponible ou a déjà été effectué.';
      case AppError.refundAlreadySubmitted:
        return 'Une demande de remboursement a déjà été soumise pour cette réservation.';
      case AppError.paymentProviderError:
        return 'Erreur du système de paiement. Vérifiez la configuration FedPay côté serveur.';
      default:
        return 'Une erreur inattendue est survenue.';
    }
  }
}
