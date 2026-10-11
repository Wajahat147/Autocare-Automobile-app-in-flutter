import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../models/vehicle.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/metric_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../vehicles/add_edit_vehicle_screen.dart';
import '../vehicles/vehicle_detail_screen.dart';
import '../service_records/add_service_record_screen.dart';
import '../reminders/reminders_screen.dart';
import '../expenses/expenses_screen.dart';
import '../maintenance/checklist_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final vehicles = state.vehicles;
    final selectedVehicle = state.selectedVehicle;
    final upcomingReminders = state.upcomingReminders;
    final overdueReminders = state.overdueReminders;
    final recentRecords = state.serviceRecords.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AutoCare',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Garage Dashboard',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 13, color: AppTheme.accentIndigo),
                SizedBox(width: 4),
                Text(
                  'Demo Data',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentIndigo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: vehicles.isEmpty
          ? EmptyState(
              icon: Icons.garage_outlined,
              title: 'Your Garage is Empty',
              message:
                  'Add your first car or motorcycle to start tracking servicing, mileage, and maintenance checklists.',
              actionLabel: 'Add Your First Vehicle',
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
                );
              },
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Instant in-memory refresh feedback
                await Future.delayed(const Duration(milliseconds: 300));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  // Greeting & Status Bar
                  _buildGreetingHeader(context),
                  const SizedBox(height: 16),

                  // Overview Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: MetricTile(
                          title: 'My Vehicles',
                          value: '${vehicles.length}',
                          icon: Icons.garage_rounded,
                          color: AppTheme.primaryNavy,
                          onTap: () => onNavigateTab?.call(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricTile(
                          title: 'Upcoming',
                          value: '${upcomingReminders.length}',
                          subtitle: 'Due soon',
                          icon: Icons.schedule_rounded,
                          color: AppTheme.statusUpcoming,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RemindersScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricTile(
                          title: 'Overdue',
                          value: '${overdueReminders.length}',
                          subtitle: overdueReminders.isNotEmpty ? 'Action req.' : 'All clear',
                          icon: Icons.warning_amber_rounded,
                          color: overdueReminders.isNotEmpty
                              ? AppTheme.statusOverdue
                              : AppTheme.statusHealthy,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RemindersScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Quick Action Hub
                  _buildQuickActionHub(context),
                  const SizedBox(height: 24),

                  // Vehicle Carousel / Garage Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Garage',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => onNavigateTab?.call(1),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: const Text(
                          'View All',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicles.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        final isSelected = v.id == selectedVehicle?.id;
                        return _buildVehicleCard(context, state, v, isSelected);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selected Vehicle Health & Maintenance Summary
                  if (selectedVehicle != null) ...[
                    _buildVehicleHealthBanner(context, selectedVehicle),
                    const SizedBox(height: 24),
                  ],

                  // Upcoming Maintenance & Tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Maintenance',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RemindersScreen()),
                          );
                        },
                        child: const Text('All Tasks'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (upcomingReminders.isEmpty && overdueReminders.isEmpty)
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: AppTheme.statusHealthy, size: 28),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'All scheduled services are currently up to date.',
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    ...overdueReminders.map((r) => _buildReminderItem(context, state, r, true)),
                    ...upcomingReminders.take(2).map((r) => _buildReminderItem(context, state, r, false)),
                  ],
                  const SizedBox(height: 24),

                  // Recent Service History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Service History',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab?.call(3),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (recentRecords.isEmpty)
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: Text(
                          'No service records logged yet.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...recentRecords.map((record) => _buildHistoryItem(context, record)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assalam-o-Alaikum,',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Hamza Malik',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryNavy,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.primaryNavy,
          child: const Text(
            'HM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionHub(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context,
          icon: Icons.add_circle_outline_rounded,
          label: 'Add Vehicle',
          color: AppTheme.primaryNavy,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
            );
          },
        ),
        _buildActionItem(
          context,
          icon: Icons.post_add_rounded,
          label: 'Log Service',
          color: AppTheme.statusHealthy,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddServiceRecordScreen()),
            );
          },
        ),
        _buildActionItem(
          context,
          icon: Icons.notifications_active_outlined,
          label: 'Reminders',
          color: AppTheme.statusUpcoming,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            );
          },
        ),
        _buildActionItem(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Expenses',
          color: AppTheme.accentIndigo,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    AppState state,
    Vehicle v,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        state.selectVehicle(v.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : AppTheme.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      v.isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                      color: isSelected ? Colors.white : AppTheme.primaryNavy,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      v.isCar ? 'Car' : 'Bike',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white70 : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    v.registrationNumber ?? '${v.year}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${v.model} • ${v.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white60 : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    Formatters.formatMileage(v.odometer),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF67E8F9) : AppTheme.accentIndigo,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailScreen(vehicleId: v.id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : AppTheme.textMuted,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: isSelected ? Colors.white70 : AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHealthBanner(BuildContext context, Vehicle v) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    v.isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                    color: AppTheme.accentIndigo,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${v.name} Health Status',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VehicleDetailScreen(vehicleId: v.id),
                    ),
                  );
                },
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentIndigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Odometer',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatMileage(v.odometer),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: AppTheme.cardBorder),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Powertrain',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        v.fuelType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: AppTheme.cardBorder),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      const StatusBadge(
                        label: 'Good Condition',
                        backgroundColor: Color(0xFFDCFCE7),
                        textColor: AppTheme.statusHealthy,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChecklistScreen(
                          vehicleId: v.id,
                          checklistType: v.isCar
                              ? ChecklistType.carTuning
                              : ChecklistType.routineBike,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 16),
                  label: Text(v.isCar ? 'Car Tuning Checklist' : 'Routine Service'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    AppState state,
    dynamic reminder,
    bool isOverdue,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        border: isOverdue
            ? Border.all(color: AppTheme.statusOverdue.withValues(alpha: 0.4), width: 1.2)
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOverdue
                    ? AppTheme.statusOverdue.withValues(alpha: 0.1)
                    : AppTheme.statusUpcoming.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOverdue ? Icons.priority_high_rounded : Icons.schedule_rounded,
                color: isOverdue ? AppTheme.statusOverdue : AppTheme.statusUpcoming,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.taskTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: isOverdue ? 'Overdue' : 'Due Soon',
                        backgroundColor: isOverdue
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFFEF3C7),
                        textColor: isOverdue
                            ? AppTheme.statusOverdue
                            : AppTheme.statusUpcoming,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reminder.vehicleName} • ${reminder.notes ?? (reminder.dueMileage != null ? "At ${Formatters.formatMileage(reminder.dueMileage)}" : "")}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.build_circle_outlined,
                color: AppTheme.primaryNavy,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.serviceType,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${record.vehicleName} • ${Formatters.formatDate(record.serviceDate)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.formatPKR(record.totalCost),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
