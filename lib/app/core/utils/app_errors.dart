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
  wrongPin,
  wrongEmailAndPasswordCombination,
  wrongPhonenumber,
  unAuthenticated,
  phoneAlreadyInUse,
}

extension AppErrorMessage on AppError {
  String get message {
    switch (this) {
      case AppError.socket:
        return 'Vérifiez votre connexion internet.';
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
      default:
        return 'Une erreur inattendue est survenue.';
    }
  }
}