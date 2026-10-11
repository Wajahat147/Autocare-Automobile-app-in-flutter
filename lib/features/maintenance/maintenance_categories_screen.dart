import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';
import 'checklist_screen.dart';

class MaintenanceCategoriesScreen extends StatelessWidget {
  const MaintenanceCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final vehicle = state.selectedVehicle;
    final vehicles = state.vehicles;
    final categories = state.categoriesForSelectedVehicle;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Maintenance Categories'),
      ),
      body: vehicles.isEmpty
          ? const EmptyState(
              icon: Icons.build_circle_outlined,
              title: 'No Vehicle Selected',
              message: 'Add a car or motorcycle to see tailored maintenance categories.',
            )
          : Column(
              children: [
                // Vehicle Switcher Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  color: AppTheme.surfaceWhite,
                  child: Row(
                    children: [
                      const Text(
                        'Active Vehicle:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: vehicle?.id,
                              items: vehicles.map((v) {
                                return DropdownMenuItem(
                                  value: v.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        v.isCar
                                            ? Icons.directions_car_rounded
                                            : Icons.two_wheeler_rounded,
                                        size: 16,
                                        color: AppTheme.primaryNavy,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${v.name} (${v.isCar ? "Car" : "Bike"})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (id) {
                                if (id != null) state.selectVehicle(id);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.cardBorder),

                // Category List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(cat.icon,
                                      size: 22, color: AppTheme.primaryNavy),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cat.title,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.primaryNavy,
                                              ),
                                            ),
                                          ),
                                          StatusBadge.fromMaintenanceStatus(cat.status),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cat.description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppTheme.cardBorder),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (cat.nextDue != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded,
                                          size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        cat.nextDue!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  const SizedBox.shrink(),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () {
                                    if (vehicle == null) return;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ChecklistScreen(
                                          vehicleId: vehicle.id,
                                          checklistType: vehicle.isCar
                                              ? ChecklistType.carTuning
                                              : ChecklistType.routineBike,
                                          categoryFilter: cat.title,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.checklist_rounded, size: 14),
                                  label: Text(
                                    cat.defaultAction,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
