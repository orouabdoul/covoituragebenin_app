class VehicleData {
  const VehicleData({
    required this.id,
    required this.uuid,
    required this.brand,
    required this.model,
    required this.color,
    required this.year,
    required this.licensePlate,
    required this.availableSeats,
    required this.vehicleType,
    required this.vehicleTypeSlug,
    required this.verificationStatus,
    required this.isApproved,
    required this.fullName,
    this.rejectionReason,
    this.vehiclePhotoUrl,
    this.registrationDocUrl,
    this.insuranceDocUrl,
    this.tvmDocUrl,
    this.technicalControlDocUrl,
  });

  final int id;
  final String uuid;
  final String brand;
  final String model;
  final String color;
  final int year;
  final String licensePlate;
  final int availableSeats;
  final String vehicleType;       // display name e.g. "Voiture"
  final String vehicleTypeSlug;   // slug e.g. "voiture", "moto"
  final String verificationStatus; // "pending" | "approved" | "rejected"
  final bool isApproved;
  final String fullName;
  final String? rejectionReason;
  final String? vehiclePhotoUrl;
  final String? registrationDocUrl;
  final String? insuranceDocUrl;
  final String? tvmDocUrl;
  final String? technicalControlDocUrl;

  factory VehicleData.fromJson(Map<String, dynamic> json) => VehicleData(
        id: (json['id'] as num?)?.toInt() ?? 0,
        uuid: (json['uuid'] as String?) ?? '',
        brand: (json['brand'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        color: (json['color'] as String?) ?? '',
        year: (json['year'] as num?)?.toInt() ?? 0,
        licensePlate: (json['license_plate'] as String?) ?? '',
        availableSeats: (json['available_seats'] as num?)?.toInt() ?? 0,
        vehicleType: (json['vehicle_type'] as String?) ?? '',
        vehicleTypeSlug: (json['vehicle_type_slug'] as String?) ?? '',
        verificationStatus: (json['verification_status'] as String?) ?? 'pending',
        isApproved: (json['is_approved'] as bool?) ?? false,
        fullName: (json['full_name'] as String?) ?? '',
        rejectionReason: json['rejection_reason'] as String?,
        vehiclePhotoUrl: json['vehicle_photo_url'] as String?,
        registrationDocUrl: json['registration_doc_url'] as String?,
        insuranceDocUrl: json['insurance_doc_url'] as String?,
        tvmDocUrl: json['tvm_doc_url'] as String?,
        technicalControlDocUrl: json['technical_control_doc_url'] as String?,
      );
}
