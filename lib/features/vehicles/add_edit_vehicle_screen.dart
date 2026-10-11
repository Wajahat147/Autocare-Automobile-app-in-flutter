import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddEditVehicleScreen({super.key, this.vehicle});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late VehicleType _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _regController;
  late TextEditingController _odometerController;
  late String _selectedFuelType;
  DateTime? _purchaseDate;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _selectedType = v?.type ?? VehicleType.car;
    _nameController = TextEditingController(text: v?.name ?? '');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController =
        TextEditingController(text: v != null ? '${v.year}' : '2022');
    _regController =
        TextEditingController(text: v?.registrationNumber ?? '');
    _odometerController =
        TextEditingController(text: v != null ? '${v.odometer}' : '');
    _selectedFuelType = v?.fuelType ?? 'Petrol';
    _purchaseDate = v?.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  List<String> get _fuelOptions {
    return _selectedType == VehicleType.car
        ? AppConstants.fuelTypesCar
        : AppConstants.fuelTypesBike;
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final state = AppStateScope.of(context);
    final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
    final odometer = int.tryParse(_odometerController.text.trim()) ?? 0;
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : '${_brandController.text.trim()} ${_modelController.text.trim()}';

    if (isEditing) {
      final updated = widget.vehicle!.copyWith(
        name: name,
        type: _selectedType,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        registrationNumber: _regController.text.trim().isNotEmpty
            ? _regController.text.trim()
            : null,
        odometer: odometer,
        purchaseDate: _purchaseDate,
        fuelType: _selectedFuelType,
      );
      state.updateVehicle(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${updated.name} successfully')),
      );
    } else {
      final newVehicle = Vehicle(
        id: 'v_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: _selectedType,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        registrationNumber: _regController.text.trim().isNotEmpty
            ? _regController.text.trim()
            : null,
        odometer: odometer,
        purchaseDate: _purchaseDate,
        fuelType: _selectedFuelType,
      );
      state.addVehicle(newVehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${newVehicle.name} to garage')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        actions: [
          TextButton(
            onPressed: _saveVehicle,
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
            // Vehicle Type Segment Selector
            const Text(
              'Vehicle Category',
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
                  child: _typeCard(
                    title: 'Car / 4-Wheeler',
                    subtitle: 'Sedan, Hatchback, SUV',
                    icon: Icons.directions_car_rounded,
                    isSelected: _selectedType == VehicleType.car,
                    onTap: () {
                      setState(() {
                        _selectedType = VehicleType.car;
                        if (!_fuelOptions.contains(_selectedFuelType)) {
                          _selectedFuelType = _fuelOptions.first;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeCard(
                    title: 'Motorcycle',
                    subtitle: '70cc, 125cc, 150cc',
                    icon: Icons.two_wheeler_rounded,
                    isSelected: _selectedType == VehicleType.bike,
                    onTap: () {
                      setState(() {
                        _selectedType = VehicleType.bike;
                        if (!_fuelOptions.contains(_selectedFuelType)) {
                          _selectedFuelType = _fuelOptions.first;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Vehicle Nickname / Display Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Nickname (e.g. My Daily Ride)',
                hintText: 'e.g. White Alto or Red 70',
                prefixIcon: Icon(Icons.bookmark_border_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a name for your vehicle';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Brand & Model
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      labelText: 'Brand / Make',
                      hintText: _selectedType == VehicleType.car
                          ? 'Suzuki / Toyota'
                          : 'Honda / Yamaha',
                      prefixIcon: const Icon(Icons.branding_watermark_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter brand' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      labelText: 'Model Name',
                      hintText: _selectedType == VehicleType.car
                          ? 'Alto / Corolla'
                          : 'CD 70 / CG 125',
                      prefixIcon: const Icon(Icons.car_rental_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter model' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Year & Fuel Type
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Model Year',
                      hintText: '2023',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (v) {
                      final parsed = int.tryParse(v ?? '');
                      if (parsed == null || parsed < 1960 || parsed > 2030) {
                        return 'Valid year (1960-2030)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFuelType,
                    decoration: const InputDecoration(
                      labelText: 'Powertrain',
                      prefixIcon: Icon(Icons.local_gas_station_outlined),
                    ),
                    items: _fuelOptions.map((f) {
                      return DropdownMenuItem(value: f, child: Text(f));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedFuelType = val);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Mileage
            TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Odometer Reading (km)',
                hintText: 'e.g. 15400',
                suffixText: 'km',
                prefixIcon: Icon(Icons.speed_rounded),
              ),
              validator: (v) {
                final parsed = int.tryParse(v ?? '');
                if (parsed == null || parsed < 0) {
                  return 'Enter current mileage in km';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Optional Registration Number
            TextFormField(
              controller: _regController,
              decoration: const InputDecoration(
                labelText: 'Registration Number (Optional)',
                hintText: 'e.g. KHI-7821, LHE-5490, ISB-3312',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveVehicle,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  isEditing ? 'Save Changes' : 'Register Vehicle',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _typeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryNavy
              : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : AppTheme.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : AppTheme.primaryNavy,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
