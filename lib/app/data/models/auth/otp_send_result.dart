class OtpSendResult {
  final String? otpCode;
  /// Seconds until next resend is allowed (from body.resend_available_in).
  /// Present on both HTTP 200 and HTTP 429.
  final int? resendIn;
  /// True only when the server returned HTTP 429 (OTP already active).
  final bool alreadyActive;

  const OtpSendResult({
    this.otpCode,
    this.resendIn,
    this.alreadyActive = false,
  });
}
