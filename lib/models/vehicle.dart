enum VehicleType { car, bike }

class Vehicle {
  final String id;
  final String name;
  final VehicleType type;
  final String brand;
  final String model;
  final int year;
  final String? registrationNumber;
  final int odometer;
  final DateTime? purchaseDate;
  final String fuelType;
  final String? photoUrl;

  const Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    this.registrationNumber,
    required this.odometer,
    this.purchaseDate,
    required this.fuelType,
    this.photoUrl,
  });

  bool get isCar => type == VehicleType.car;
  bool get isBike => type == VehicleType.bike;

  Vehicle copyWith({
    String? id,
    String? name,
    VehicleType? type,
    String? brand,
    String? model,
    int? year,
    String? registrationNumber,
    int? odometer,
    DateTime? purchaseDate,
    String? fuelType,
    String? photoUrl,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      odometer: odometer ?? this.odometer,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      fuelType: fuelType ?? this.fuelType,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
