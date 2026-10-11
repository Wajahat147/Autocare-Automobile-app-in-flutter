class AppConstants {
  static const String appName = 'AutoCare';
  static const String appTagline = 'Your vehicles. Their maintenance. All in one place.';
  static const String appVersion = '1.0.0 (GUI Phase)';

  static const String currencySymbol = 'Rs.';
  static const String currencyCode = 'PKR';

  // Vehicle Types
  static const String typeCar = 'Car';
  static const String typeBike = 'Motorcycle';

  // Fuel Types
  static const List<String> fuelTypesCar = [
    'Petrol',
    'Diesel',
    'Hybrid',
    'Electric (EV)',
    'CNG',
  ];

  static const List<String> fuelTypesBike = [
    'Petrol',
    'Electric (EV)',
  ];

  // Service Types
  static const String serviceRoutine = 'Routine Service';
  static const String serviceTuning = 'Complete Tuning';
  static const String serviceCleaning = 'Cleaning & Detailing';
  static const String serviceRepair = 'Repair & Adjustment';
  static const String servicePartReplacement = 'Part Replacement';
  static const String serviceInspection = 'General Inspection';

  static const List<String> allServiceTypes = [
    serviceRoutine,
    serviceTuning,
    serviceCleaning,
    serviceRepair,
    servicePartReplacement,
    serviceInspection,
  ];

  // Checklist Item Statuses
  static const String statusNotStarted = 'Not Started';
  static const String statusDone = 'Done';
  static const String statusNotRequired = 'Not Required';
  static const String statusNeedsRepair = 'Needs Repair/Adjustment';
  static const String statusNeedsReplacement = 'Needs Replacement';

  static const List<String> checklistStatuses = [
    statusNotStarted,
    statusDone,
    statusNotRequired,
    statusNeedsRepair,
    statusNeedsReplacement,
  ];
}
