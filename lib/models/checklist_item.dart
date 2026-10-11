class ChecklistItem {
  final String id;
  final String category;
  final String title;
  final String description;
  final String status; // Not Started, Done, Not Required, Needs Repair/Adjustment, Needs Replacement
  final String? notes;
  final bool isMandatory;

  const ChecklistItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.status = 'Not Started',
    this.notes,
    this.isMandatory = false,
  });

  bool get isCompleted => status == 'Done' || status == 'Not Required';
  bool get needsAttention => status == 'Needs Repair/Adjustment' || status == 'Needs Replacement';

  ChecklistItem copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    String? status,
    String? notes,
    bool? isMandatory,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isMandatory: isMandatory ?? this.isMandatory,
    );
  }
}
