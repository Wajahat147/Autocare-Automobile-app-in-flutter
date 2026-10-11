import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../models/vehicle.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';
import 'add_edit_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final vehicles = state.filteredVehicles;
    final currentFilter = state.vehicleFilter;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            tooltip: 'Add Vehicle',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            color: AppTheme.surfaceWhite,
            child: Row(
              children: [
                _buildFilterChip(context, state, 'All', currentFilter == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(context, state, 'Car', currentFilter == 'Car',
                    icon: Icons.directions_car_rounded),
                const SizedBox(width: 8),
                _buildFilterChip(context, state, 'Motorcycle', currentFilter == 'Motorcycle',
                    icon: Icons.two_wheeler_rounded),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.cardBorder),

          // Vehicle List
          Expanded(
            child: vehicles.isEmpty
                ? EmptyState(
                    icon: Icons.directions_car_filled_outlined,
                    title: 'No Vehicles Found',
                    message: currentFilter == 'All'
                        ? 'No vehicles added yet. Add your car or motorcycle to start tracking.'
                        : 'No $currentFilter vehicles registered in your garage.',
                    actionLabel: 'Add New Vehicle',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    itemCount: vehicles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final v = vehicles[index];
                      return _buildVehicleCard(context, state, v);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vehicle'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AppState state,
    String label,
    bool isSelected, {
    IconData? icon,
  }) {
    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: icon != null
          ? Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppTheme.primaryNavy,
            )
          : null,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.primaryNavy,
      ),
      backgroundColor: AppTheme.backgroundLight,
      selectedColor: AppTheme.primaryNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.cardBorder,
        ),
      ),
      onSelected: (_) => state.setVehicleFilter(label),
    );
  }

  Widget _buildVehicleCard(BuildContext context, AppState state, Vehicle v) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        state.selectVehicle(v.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehicleId: v.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Icon(
                  v.isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                  size: 28,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            v.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Text(
                            v.registrationNumber ?? '${v.year}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${v.brand} • ${v.model} (${v.year})',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const StatusBadge(
                          label: 'Healthy',
                          backgroundColor: Color(0xFFDCFCE7),
                          textColor: AppTheme.statusHealthy,
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          v.fuelType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.cardBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 16, color: AppTheme.accentIndigo),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.formatMileage(v.odometer),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textMuted),
                    tooltip: 'Edit Vehicle',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditVehicleScreen(vehicle: v),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppTheme.statusOverdue),
                    tooltip: 'Delete Vehicle',
                    onPressed: () => _confirmDelete(context, state, v),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, Vehicle v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle?'),
        content: Text(
          'Are you sure you want to remove "${v.name}" from your garage? Associated service history will also be removed in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdue,
            ),
            onPressed: () {
              state.deleteVehicle(v.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed ${v.name} from garage')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
