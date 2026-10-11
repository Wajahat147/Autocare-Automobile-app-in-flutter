enum ReminderType { dateBased, mileageBased }

class Reminder {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String taskTitle;
  final ReminderType type;
  final DateTime? dueDate;
  final int? dueMileage;
  final bool isCompleted;
  final String? notes;

  const Reminder({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.taskTitle,
    required this.type,
    this.dueDate,
    this.dueMileage,
    this.isCompleted = false,
    this.notes,
  });

  bool isOverdue(int currentMileage) {
    if (isCompleted) return false;
    if (type == ReminderType.dateBased && dueDate != null) {
      return dueDate!.isBefore(DateTime.now());
    }
    if (type == ReminderType.mileageBased && dueMileage != null) {
      return currentMileage >= dueMileage!;
    }
    return false;
  }

  Reminder copyWith({
    String? id,
    String? vehicleId,
    String? vehicleName,
    String? taskTitle,
    ReminderType? type,
    DateTime? dueDate,
    int? dueMileage,
    bool? isCompleted,
    String? notes,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      taskTitle: taskTitle ?? this.taskTitle,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
