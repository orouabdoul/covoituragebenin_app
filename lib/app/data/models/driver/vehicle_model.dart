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
    this.fuelType,
    this.status,
    this.isActive,
  });

  final int id;
  final String uuid;
  final String brand;
  final String model;
  final String color;
  final int year;
  final String licensePlate;
  final int availableSeats;
  final String vehicleType; // "car" | "motorcycle"
  final String? fuelType;
  final String? status;
  final bool? isActive;

  factory VehicleData.fromJson(Map<String, dynamic> json) => VehicleData(
        id: (json['id'] as num?)?.toInt() ?? 0,
        uuid: (json['uuid'] as String?) ?? '',
        brand: (json['brand'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        color: (json['color'] as String?) ?? '',
        year: (json['year'] as num?)?.toInt() ?? 0,
        licensePlate: (json['license_plate'] as String?) ?? '',
        availableSeats: (json['available_seats'] as num?)?.toInt() ?? 0,
        vehicleType: (json['vehicle_type'] as String?) ?? 'car',
        fuelType: json['fuel_type'] as String?,
        status: json['status'] as String?,
        isActive: json['is_active'] as bool?,
      );
}
