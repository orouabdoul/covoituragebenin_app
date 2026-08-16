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
  paymentProviderError,
  alreadyPaid,
  invalidPhoneFormat;

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
      case AppError.invalidPhoneFormat:
        return 'Numéro invalide. Vérifiez que votre numéro commence par un préfixe béninois valide (ex : 0197, 0160, 0151...).';
      case AppError.phoneAlreadyInUse:
        return 'Ce numéro est déjà utilisé.';
      case AppError.permissionDenied:
        return 'Accès refusé — démarrez votre trajet pour accéder à la navigation.';
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
      case AppError.alreadyPaid:
        return 'Ce paiement a déjà été effectué.';
      default:
        return 'Une erreur inattendue est survenue.';
    }
  }
}
