import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../models/service_record.dart';
import '../models/checklist_item.dart';
import '../models/reminder.dart';
import '../models/guide.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  List<ServiceRecord> _serviceRecords = [];
  List<Reminder> _reminders = [];
  List<ChecklistItem> _bikeChecklist = [];
  List<ChecklistItem> _carChecklist = [];
  List<MaintenanceGuide> _guides = [];

  // Filter states
  String _vehicleFilter = 'All'; // 'All', 'Car', 'Motorcycle'
  String _historyVehicleFilter = 'All';
  String _historyServiceTypeFilter = 'All';

  AppState() {
    _initializeData();
  }

  void _initializeData() {
    _vehicles = MockData.getInitialVehicles();
    _serviceRecords = MockData.getInitialServiceRecords();
    _reminders = MockData.getInitialReminders();
    _bikeChecklist = MockData.getBikeRoutineChecklist();
    _carChecklist = MockData.getCarTuningChecklist();
    _guides = MockData.getGuides();
    if (_vehicles.isNotEmpty) {
      _selectedVehicleId = _vehicles.first.id;
    }
  }

  // Getters
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<ServiceRecord> get serviceRecords => List.unmodifiable(_serviceRecords);
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<MaintenanceGuide> get guides => List.unmodifiable(_guides);
  String? get selectedVehicleId => _selectedVehicleId;
  String get vehicleFilter => _vehicleFilter;
  String get historyVehicleFilter => _historyVehicleFilter;
  String get historyServiceTypeFilter => _historyServiceTypeFilter;

  Vehicle? get selectedVehicle {
    if (_vehicles.isEmpty) return null;
    return _vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => _vehicles.first,
    );
  }

  List<Vehicle> get filteredVehicles {
    if (_vehicleFilter == 'Car') {
      return _vehicles.where((v) => v.isCar).toList();
    } else if (_vehicleFilter == 'Motorcycle') {
      return _vehicles.where((v) => v.isBike).toList();
    }
    return _vehicles;
  }

  // Categories tailored to selected vehicle
  List<MaintenanceCategory> get categoriesForSelectedVehicle {
    final vehicle = selectedVehicle;
    if (vehicle == null) return [];
    if (vehicle.isBike) {
      return MockData.getBikeCategories();
    } else {
      // Filter car categories based on powertrain if necessary
      final carCategories = MockData.getCarCategories();
      return carCategories.where((cat) {
        if (cat.applicableFuelTypes.isEmpty) return true;
        return cat.applicableFuelTypes.contains(vehicle.fuelType);
      }).toList();
    }
  }

  // Checklists
  List<ChecklistItem> get bikeChecklist => List.unmodifiable(_bikeChecklist);
  List<ChecklistItem> get carChecklist => List.unmodifiable(_carChecklist);

  // Reminders breakdown
  List<Reminder> get upcomingReminders {
    final vehicle = selectedVehicle;
    final currentKm = vehicle?.odometer ?? 0;
    return _reminders
        .where((r) => !r.isCompleted && !r.isOverdue(currentKm))
        .toList();
  }

  List<Reminder> get overdueReminders {
    final vehicle = selectedVehicle;
    final currentKm = vehicle?.odometer ?? 0;
    return _reminders
        .where((r) => !r.isCompleted && r.isOverdue(currentKm))
        .toList();
  }

  List<Reminder> get completedReminders {
    return _reminders.where((r) => r.isCompleted).toList();
  }

  // Expense calculations in PKR
  double get totalExpenses {
    return _serviceRecords.fold(0.0, (sum, item) => sum + item.totalCost);
  }

  double get partsCostTotal {
    return _serviceRecords.fold(0.0, (sum, item) => sum + item.partsCost);
  }

  double get laborCostTotal {
    return _serviceRecords.fold(0.0, (sum, item) => sum + item.laborCost);
  }

  Map<String, double> get expensesByVehicle {
    final map = <String, double>{};
    for (var record in _serviceRecords) {
      map[record.vehicleName] = (map[record.vehicleName] ?? 0.0) + record.totalCost;
    }
    return map;
  }

  Map<String, double> get expensesByServiceType {
    final map = <String, double>{};
    for (var record in _serviceRecords) {
      map[record.serviceType] = (map[record.serviceType] ?? 0.0) + record.totalCost;
    }
    return map;
  }

  List<ServiceRecord> get filteredHistoryRecords {
    return _serviceRecords.where((record) {
      final matchesVehicle = _historyVehicleFilter == 'All' ||
          record.vehicleName == _historyVehicleFilter;
      final matchesType = _historyServiceTypeFilter == 'All' ||
          record.serviceType == _historyServiceTypeFilter;
      return matchesVehicle && matchesType;
    }).toList();
  }

  List<ServiceRecord> recordsForVehicle(String vehicleId) {
    return _serviceRecords.where((r) => r.vehicleId == vehicleId).toList();
  }

  // Vehicle Actions
  void selectVehicle(String id) {
    _selectedVehicleId = id;
    notifyListeners();
  }

  void setVehicleFilter(String filter) {
    _vehicleFilter = filter;
    notifyListeners();
  }

  void setHistoryVehicleFilter(String filter) {
    _historyVehicleFilter = filter;
    notifyListeners();
  }

  void setHistoryServiceTypeFilter(String filter) {
    _historyServiceTypeFilter = filter;
    notifyListeners();
  }

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    _selectedVehicleId = vehicle.id;
    notifyListeners();
  }

  void updateVehicle(Vehicle updated) {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      notifyListeners();
    }
  }

  void deleteVehicle(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    _serviceRecords.removeWhere((r) => r.vehicleId == id);
    _reminders.removeWhere((r) => r.vehicleId == id);
    if (_selectedVehicleId == id) {
      _selectedVehicleId = _vehicles.isNotEmpty ? _vehicles.first.id : null;
    }
    notifyListeners();
  }

  // Service Record Actions
  void addServiceRecord(ServiceRecord record) {
    _serviceRecords.insert(0, record);
    // Automatically update vehicle odometer if recorded mileage is higher
    final vIndex = _vehicles.indexWhere((v) => v.id == record.vehicleId);
    if (vIndex != -1) {
      if (record.odometer > _vehicles[vIndex].odometer) {
        _vehicles[vIndex] = _vehicles[vIndex].copyWith(odometer: record.odometer);
      }
    }
    notifyListeners();
  }

  void deleteServiceRecord(String id) {
    _serviceRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Reminder Actions
  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        isCompleted: !_reminders[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Checklist Actions
  void updateBikeChecklistTask(String id, String status, {String? notes}) {
    final index = _bikeChecklist.indexWhere((item) => item.id == id);
    if (index != -1) {
      _bikeChecklist[index] = _bikeChecklist[index].copyWith(
        status: status,
        notes: notes ?? _bikeChecklist[index].notes,
      );
      notifyListeners();
    }
  }

  void updateCarChecklistTask(String id, String status, {String? notes}) {
    final index = _carChecklist.indexWhere((item) => item.id == id);
    if (index != -1) {
      _carChecklist[index] = _carChecklist[index].copyWith(
        status: status,
        notes: notes ?? _carChecklist[index].notes,
      );
      notifyListeners();
    }
  }

  void resetBikeChecklist() {
    _bikeChecklist = MockData.getBikeRoutineChecklist();
    notifyListeners();
  }

  void resetCarChecklist() {
    _carChecklist = MockData.getCarTuningChecklist();
    notifyListeners();
  }
}

/// InheritedNotifier for zero-overhead reactive state delivery to the entire widget tree
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in widget tree');
    return scope!.notifier!;
  }
}
