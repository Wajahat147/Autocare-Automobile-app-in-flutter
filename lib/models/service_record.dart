class ServiceRecord {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String serviceType;
  final DateTime serviceDate;
  final int odometer;
  final String workPerformed;
  final String? partsReplaced;
  final String? notes;
  final double partsCost;
  final double laborCost;
  final double totalCost;
  final DateTime? nextServiceDate;
  final int? nextServiceMileage;

  const ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.serviceType,
    required this.serviceDate,
    required this.odometer,
    required this.workPerformed,
    this.partsReplaced,
    this.notes,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    this.nextServiceDate,
    this.nextServiceMileage,
  });

  ServiceRecord copyWith({
    String? id,
    String? vehicleId,
    String? vehicleName,
    String? serviceType,
    DateTime? serviceDate,
    int? odometer,
    String? workPerformed,
    String? partsReplaced,
    String? notes,
    double? partsCost,
    double? laborCost,
    double? totalCost,
    DateTime? nextServiceDate,
    int? nextServiceMileage,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      serviceType: serviceType ?? this.serviceType,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      workPerformed: workPerformed ?? this.workPerformed,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      notes: notes ?? this.notes,
      partsCost: partsCost ?? this.partsCost,
      laborCost: laborCost ?? this.laborCost,
      totalCost: totalCost ?? this.totalCost,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
    );
  }
}
