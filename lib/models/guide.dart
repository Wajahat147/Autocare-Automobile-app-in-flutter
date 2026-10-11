import 'package:flutter/material.dart';

class MaintenanceGuide {
  final String id;
  final String title;
  final String category;
  final String vehicleType; // 'Car', 'Motorcycle', 'Both'
  final String purpose;
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  final String estimatedTime;
  final List<String> steps;
  final List<String> warningSigns;
  final String whenToConsultMechanic;
  final String? safetyWarning;
  final IconData icon;

  const MaintenanceGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.vehicleType,
    required this.purpose,
    required this.difficulty,
    required this.estimatedTime,
    required this.steps,
    required this.warningSigns,
    required this.whenToConsultMechanic,
    this.safetyWarning,
    required this.icon,
  });
}
