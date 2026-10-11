import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/reminder.dart';
import '../../state/app_state.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedVehicleId;
  late TextEditingController _titleController;
  late TextEditingController _mileageController;
  late TextEditingController _notesController;
  late ReminderType _type;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  bool get isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _selectedVehicleId = r?.vehicleId ?? '';
    _titleController = TextEditingController(text: r?.taskTitle ?? '');
    _mileageController =
        TextEditingController(text: r?.dueMileage != null ? '${r!.dueMileage}' : '');
    _notesController = TextEditingController(text: r?.notes ?? '');
    _type = r?.type ?? ReminderType.dateBased;
    if (r?.dueDate != null) _dueDate = r!.dueDate!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (_selectedVehicleId.isEmpty && state.vehicles.isNotEmpty) {
      _selectedVehicleId = state.selectedVehicle?.id ?? state.vehicles.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    final state = AppStateScope.of(context);
    final vehicle = state.vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => state.vehicles.first,
    );

    final dueKm = int.tryParse(_mileageController.text.trim());

    if (isEditing) {
      final updated = widget.reminder!.copyWith(
        vehicleId: vehicle.id,
        vehicleName: vehicle.name,
        taskTitle: _titleController.text.trim(),
        type: _type,
        dueDate: _type == ReminderType.dateBased ? _dueDate : null,
        dueMileage: _type == ReminderType.mileageBased ? dueKm : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      state.deleteReminder(widget.reminder!.id);
      state.addReminder(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated reminder')),
      );
    } else {
      final newReminder = Reminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicle.id,
        vehicleName: vehicle.name,
        taskTitle: _titleController.text.trim(),
        type: _type,
        dueDate: _type == ReminderType.dateBased ? _dueDate : null,
        dueMileage: _type == ReminderType.mileageBased ? dueKm : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      state.addReminder(newReminder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added new maintenance reminder')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final vehicles = state.vehicles;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'Set Reminder'),
        actions: [
          TextButton(
            onPressed: _saveReminder,
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.accentIndigo,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Vehicle Selection
            DropdownButtonFormField<String>(
              initialValue: _selectedVehicleId.isNotEmpty ? _selectedVehicleId : null,
              decoration: const InputDecoration(
                labelText: 'Vehicle',
                prefixIcon: Icon(Icons.directions_car_rounded),
              ),
              items: vehicles.map((v) {
                return DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.name} (${Formatters.formatMileage(v.odometer)})'),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) setState(() => _selectedVehicleId = id);
              },
              validator: (v) => v == null ? 'Please select a vehicle' : null,
            ),
            const SizedBox(height: 16),

            // Task Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Maintenance Task *',
                hintText: 'e.g. Engine Oil Change, Brake Fluid Flush, Chain Lube',
                prefixIcon: Icon(Icons.alarm_on_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter reminder task' : null,
            ),
            const SizedBox(height: 20),

            // Reminder Trigger Type
            const Text(
              'Reminder Trigger Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    selected: _type == ReminderType.dateBased,
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('By Date'),
                      ],
                    ),
                    onSelected: (_) =>
                        setState(() => _type = ReminderType.dateBased),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    selected: _type == ReminderType.mileageBased,
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.speed_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('By Odometer'),
                      ],
                    ),
                    onSelected: (_) =>
                        setState(() => _type = ReminderType.mileageBased),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic condition field
            if (_type == ReminderType.dateBased)
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target Due Date',
                    prefixIcon: Icon(Icons.event_available_rounded),
                  ),
                  child: Text(
                    Formatters.formatDate(_dueDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
            else
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Odometer Mileage',
                  hintText: 'e.g. 15000',
                  suffixText: 'km',
                  prefixIcon: Icon(Icons.add_road_rounded),
                ),
                validator: (v) {
                  if (_type == ReminderType.mileageBased) {
                    final parsed = int.tryParse(v ?? '');
                    if (parsed == null || parsed <= 0) return 'Enter target km';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g. Check Havoline or ZIC synthetic oil prices before buying',
              ),
            ),
            const SizedBox(height: 16),

            // Note on GUI prototype
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prototype Notice: Reminders are tracked locally in-memory. Push notifications and automated background odometer tracking will be enabled in future releases.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveReminder,
                icon: const Icon(Icons.add_alarm_rounded),
                label: Text(
                  isEditing ? 'Save Changes' : 'Create Reminder',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
