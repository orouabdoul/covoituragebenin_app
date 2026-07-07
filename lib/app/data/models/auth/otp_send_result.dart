class OtpSendResult {
  final String? otpCode;
  final int? cooldown;

  const OtpSendResult({this.otpCode, this.cooldown});

  bool get hasCooldown => cooldown != null && cooldown! > 0;
}
