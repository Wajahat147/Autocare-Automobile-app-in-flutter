import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';
import '../../models/checklist_item.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../service_records/add_service_record_screen.dart';

enum ChecklistType { routineBike, carTuning, cleaning, repair }

class ChecklistScreen extends StatefulWidget {
  final String vehicleId;
  final ChecklistType checklistType;
  final String? categoryFilter;

  const ChecklistScreen({
    super.key,
    required this.vehicleId,
    required this.checklistType,
    this.categoryFilter,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String _selectedStatusFilter = 'All';

  String get _title {
    switch (widget.checklistType) {
      case ChecklistType.routineBike:
        return 'Routine Motorcycle Service';
      case ChecklistType.carTuning:
        return 'Complete Car Tuning';
      case ChecklistType.cleaning:
        return 'Cleaning & Detailing';
      case ChecklistType.repair:
        return 'Inspection & Repair Checklist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final vehicle = state.vehicles.firstWhere(
      (v) => v.id == widget.vehicleId,
      orElse: () => state.vehicles.first,
    );

    final rawItems = widget.checklistType == ChecklistType.routineBike
        ? state.bikeChecklist
        : state.carChecklist;

    // Filter items if specified
    final items = rawItems.where((item) {
      if (widget.categoryFilter != null &&
          !item.category.toLowerCase().contains(widget.categoryFilter!.toLowerCase())) {
        return false;
      }
      if (_selectedStatusFilter == 'All') return true;
      return item.status == _selectedStatusFilter;
    }).toList();

    // Progress calculation
    final totalCount = rawItems.length;
    final completedCount = rawItems.where((i) => i.isCompleted).length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title, style: const TextStyle(fontSize: 16)),
            Text(
              vehicle.name,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Checklist',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (widget.checklistType == ChecklistType.routineBike) {
                state.resetBikeChecklist();
              } else {
                state.resetCarChecklist();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset checklist tasks')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Progress Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppTheme.surfaceWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Checklist Progress: $completedCount of $totalCount Done',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.statusHealthy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppTheme.cardBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.statusHealthy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.cardBorder),

          // Status Filter Tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _filterChip('All'),
                _filterChip('Not Started'),
                _filterChip('Done'),
                _filterChip('Needs Repair/Adjustment'),
                _filterChip('Needs Replacement'),
                _filterChip('Not Required'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.cardBorder),

          // Checklist items list
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks matching this filter.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildChecklistItemCard(context, state, item);
                    },
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceWhite,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progress saved in memory')),
                      );
                    },
                    child: const Text('Save Progress'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showCompleteDialog(context, vehicle);
                    },
                    child: const Text('Complete Service'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.primaryNavy,
        ),
        selectedColor: AppTheme.primaryNavy,
        backgroundColor: AppTheme.backgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryNavy : AppTheme.cardBorder,
          ),
        ),
        onSelected: (_) {
          setState(() => _selectedStatusFilter = label);
        },
      ),
    );
  }

  Widget _buildChecklistItemCard(
    BuildContext context,
    AppState state,
    ChecklistItem item,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              StatusBadge.fromChecklistStatus(item.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.3,
            ),
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sticky_note_2_outlined,
                      size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.notes!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF78350F)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.cardBorder),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => _showNotesDialog(context, state, item),
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: Text(item.notes == null ? 'Add Note' : 'Edit Note'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceWhite,
                  foregroundColor: AppTheme.primaryNavy,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showStatusSelector(context, state, item),
                icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                label: const Text('Update Status', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusSelector(
    BuildContext context,
    AppState state,
    ChecklistItem item,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Task Status',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                ...AppConstants.checklistStatuses.map((st) {
                  final isSelected = item.status == st;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: StatusBadge.fromChecklistStatus(st),
                    title: Text(
                      st,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppTheme.accentIndigo)
                        : null,
                    onTap: () {
                      if (widget.checklistType == ChecklistType.routineBike) {
                        state.updateBikeChecklistTask(item.id, st);
                      } else {
                        state.updateCarChecklistTask(item.id, st);
                      }
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotesDialog(
    BuildContext context,
    AppState state,
    ChecklistItem item,
  ) {
    final controller = TextEditingController(text: item.notes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Task Notes'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g. Chain slack is 30mm, cleaned spark plug with solvent...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (widget.checklistType == ChecklistType.routineBike) {
                state.updateBikeChecklistTask(
                  item.id,
                  item.status,
                  notes: text.isNotEmpty ? text : null,
                );
              } else {
                state.updateCarChecklistTask(
                  item.id,
                  item.status,
                  notes: text.isNotEmpty ? text : null,
                );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, dynamic vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Service?'),
        content: const Text(
          'Would you like to log this service record and add parts/labor costs to your maintenance history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Finish Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AddServiceRecordScreen(
                    defaultVehicleId: vehicle.id,
                    defaultServiceType: widget.checklistType == ChecklistType.routineBike
                        ? 'Routine Service'
                        : 'Complete Tuning',
                    defaultWorkPerformed: widget.checklistType == ChecklistType.routineBike
                        ? 'Completed full routine motorcycle service checklist.'
                        : 'Completed full multi-point car tuning checklist.',
                  ),
                ),
              );
            },
            child: const Text('Log Service Record'),
          ),
        ],
      ),
    );
  }
}
