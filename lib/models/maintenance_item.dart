import 'package:flutter/material.dart';

enum MaintenanceStatus { healthy, upcoming, overdue, needsAttention }

class MaintenanceCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isForCar;
  final bool isForBike;
  final List<String> applicableFuelTypes; // Empty means all
  final MaintenanceStatus status;
  final String? lastServiced;
  final String? nextDue;
  final String defaultAction;

  const MaintenanceCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isForCar = true,
    this.isForBike = true,
    this.applicableFuelTypes = const [],
    this.status = MaintenanceStatus.healthy,
    this.lastServiced,
    this.nextDue,
    this.defaultAction = 'Inspect & Service',
  });
}
