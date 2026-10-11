import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../service_records/add_service_record_screen.dart';
import 'service_record_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final records = state.filteredHistoryRecords;
    final vehicles = state.vehicles;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Maintenance History'),
        actions: [
          IconButton(
            tooltip: 'Log Service',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddServiceRecordScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceWhite,
            child: Row(
              children: [
                // Vehicle Filter Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: state.historyVehicleFilter,
                        hint: const Text('Vehicle'),
                        items: [
                          const DropdownMenuItem(
                            value: 'All',
                            child: Text('All Vehicles', style: TextStyle(fontSize: 12)),
                          ),
                          ...vehicles.map(
                            (v) => DropdownMenuItem(
                              value: v.name,
                              child: Text(v.name,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) state.setHistoryVehicleFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Service Type Filter Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: state.historyServiceTypeFilter,
                        hint: const Text('Service Type'),
                        items: [
                          const DropdownMenuItem(
                            value: 'All',
                            child: Text('All Services', style: TextStyle(fontSize: 12)),
                          ),
                          ...AppConstants.allServiceTypes.map(
                            (st) => DropdownMenuItem(
                              value: st,
                              child: Text(st, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) state.setHistoryServiceTypeFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.cardBorder),

          // Total Filtered Expense Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${records.length} records found',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                Text(
                  'Total: ${Formatters.formatPKR(records.fold(0.0, (sum, r) => sum + r.totalCost))}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: records.isEmpty
                ? EmptyState(
                    icon: Icons.history_edu_outlined,
                    title: 'No History Records',
                    message:
                        'No service entries match the selected filters. Log your vehicle service to see maintenance records here.',
                    actionLabel: 'Log Service Entry',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddServiceRecordScreen(),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    itemCount: records.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = records[index];
                      return _buildRecordCard(context, r);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, dynamic r) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ServiceRecordDetailScreen(record: r),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.serviceType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
              Text(
                Formatters.formatDate(r.serviceDate),
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.vehicleName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryNavy,
                ),
              ),
              Text(
                Formatters.formatPKR(r.totalCost),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                Formatters.formatMileage(r.odometer),
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              if (r.partsReplaced != null && r.partsReplaced!.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.partsReplaced!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.workPerformed,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
