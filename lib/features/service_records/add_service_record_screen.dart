import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/service_record.dart';
import '../../state/app_state.dart';

class AddServiceRecordScreen extends StatefulWidget {
  final String? defaultVehicleId;
  final String? defaultServiceType;
  final String? defaultWorkPerformed;

  const AddServiceRecordScreen({
    super.key,
    this.defaultVehicleId,
    this.defaultServiceType,
    this.defaultWorkPerformed,
  });

  @override
  State<AddServiceRecordScreen> createState() => _AddServiceRecordScreenState();
}

class _AddServiceRecordScreenState extends State<AddServiceRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedVehicleId;
  late String _selectedServiceType;
  DateTime _serviceDate = DateTime.now();
  late TextEditingController _odometerController;
  late TextEditingController _workController;
  late TextEditingController _partsController;
  late TextEditingController _notesController;
  late TextEditingController _partsCostController;
  late TextEditingController _laborCostController;
  late TextEditingController _nextMileageController;
  DateTime? _nextServiceDate;

  double _partsCost = 0.0;
  double _laborCost = 0.0;

  double get _totalCost => _partsCost + _laborCost;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.defaultVehicleId ?? '';
    _selectedServiceType =
        widget.defaultServiceType ?? AppConstants.allServiceTypes.first;
    _odometerController = TextEditingController();
    _workController =
        TextEditingController(text: widget.defaultWorkPerformed ?? '');
    _partsController = TextEditingController();
    _notesController = TextEditingController();
    _partsCostController = TextEditingController(text: '0');
    _laborCostController = TextEditingController(text: '0');
    _nextMileageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (_selectedVehicleId.isEmpty && state.vehicles.isNotEmpty) {
      _selectedVehicleId = state.selectedVehicle?.id ?? state.vehicles.first.id;
      final selectedV = state.vehicles.firstWhere((v) => v.id == _selectedVehicleId);
      if (_odometerController.text.isEmpty) {
        _odometerController.text = '${selectedV.odometer}';
      }
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _workController.dispose();
    _partsController.dispose();
    _notesController.dispose();
    _partsCostController.dispose();
    _laborCostController.dispose();
    _nextMileageController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {
      _partsCost = double.tryParse(_partsCostController.text.trim()) ?? 0.0;
      _laborCost = double.tryParse(_laborCostController.text.trim()) ?? 0.0;
    });
  }

  void _saveRecord() {
    if (!_formKey.currentState!.validate()) return;

    final state = AppStateScope.of(context);
    final vehicle = state.vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => state.vehicles.first,
    );

    final odo = int.tryParse(_odometerController.text.trim()) ?? vehicle.odometer;
    final nextMileage = int.tryParse(_nextMileageController.text.trim());

    final record = ServiceRecord(
      id: 'sr_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicle.id,
      vehicleName: vehicle.name,
      serviceType: _selectedServiceType,
      serviceDate: _serviceDate,
      odometer: odo,
      workPerformed: _workController.text.trim(),
      partsReplaced: _partsController.text.trim().isNotEmpty
          ? _partsController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      partsCost: _partsCost,
      laborCost: _laborCost,
      totalCost: _totalCost,
      nextServiceDate: _nextServiceDate,
      nextServiceMileage: nextMileage,
    );

    state.addServiceRecord(record);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved service record: ${Formatters.formatPKR(_totalCost)} logged',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final vehicles = state.vehicles;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Add Service Record'),
        actions: [
          TextButton(
            onPressed: _saveRecord,
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
                labelText: 'Select Vehicle',
                prefixIcon: Icon(Icons.directions_car_rounded),
              ),
              items: vehicles.map((v) {
                return DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.name} (${v.registrationNumber ?? v.model})'),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) {
                  setState(() {
                    _selectedVehicleId = id;
                    final v = vehicles.firstWhere((veh) => veh.id == id);
                    _odometerController.text = '${v.odometer}';
                  });
                }
              },
              validator: (v) => v == null ? 'Please select a vehicle' : null,
            ),
            const SizedBox(height: 16),

            // Service Type
            DropdownButtonFormField<String>(
              initialValue: _selectedServiceType,
              decoration: const InputDecoration(
                labelText: 'Service Category',
                prefixIcon: Icon(Icons.build_rounded),
              ),
              items: AppConstants.allServiceTypes.map((st) {
                return DropdownMenuItem(value: st, child: Text(st));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedServiceType = val);
              },
            ),
            const SizedBox(height: 16),

            // Date & Odometer
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _serviceDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => _serviceDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Service Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        Formatters.formatDate(_serviceDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Odometer (km)',
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.speed_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter km';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Work Performed
            TextFormField(
              controller: _workController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Work Performed *',
                hintText: 'e.g. Engine oil replaced, air filter cleaned, brakes inspected...',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter work performed' : null,
            ),
            const SizedBox(height: 16),

            // Parts Replaced
            TextFormField(
              controller: _partsController,
              decoration: const InputDecoration(
                labelText: 'Parts / Fluids Replaced (Optional)',
                hintText: 'e.g. 20W-50 Oil 0.7L, NGK Spark Plug, Oil Filter',
                prefixIcon: Icon(Icons.change_circle_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Cost Calculations Card (PKR)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Cost Breakdown (Pakistani Rupees - PKR)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _partsCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Parts Cost',
                            prefixText: 'Rs. ',
                          ),
                          onChanged: (_) => _updateCalculations(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _laborCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Labor / Ustad Cost',
                            prefixText: 'Rs. ',
                          ),
                          onChanged: (_) => _updateCalculations(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Service Cost:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          Formatters.formatPKR(_totalCost),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Next Due Planning
            const Text(
              'Next Service Target (Optional)',
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
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 60)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) {
                        setState(() => _nextServiceDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Next Date',
                        prefixIcon: Icon(Icons.event_outlined),
                      ),
                      child: Text(
                        _nextServiceDate != null
                            ? Formatters.formatDate(_nextServiceDate!)
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 13,
                          color: _nextServiceDate != null
                              ? AppTheme.primaryNavy
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nextMileageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Next Mileage',
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.add_road_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mechanic / Shop Notes',
                hintText: 'e.g. Serviced at Tariq Autos, Tariq Road, Karachi...',
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveRecord,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Record Maintenance Entry',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
