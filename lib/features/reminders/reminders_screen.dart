import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../models/reminder.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final upcoming = state.upcomingReminders;
    final overdue = state.overdueReminders;
    final completed = state.completedReminders;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Maintenance Reminders'),
          actions: [
            IconButton(
              tooltip: 'New Reminder',
              icon: const Icon(Icons.add_alert_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            labelColor: AppTheme.primaryNavy,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.accentIndigo,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Upcoming (${upcoming.length})'),
              Tab(text: 'Overdue (${overdue.length})'),
              Tab(text: 'Completed (${completed.length})'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Local GUI Phase: Reminders are tracked via in-memory mileage and target dates.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(context, state, upcoming, isOverdue: false),
                  _buildList(context, state, overdue, isOverdue: true),
                  _buildList(context, state, completed, isCompleted: true),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryNavy,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Reminder'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddReminderScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AppState state,
    List<Reminder> list, {
    bool isOverdue = false,
    bool isCompleted = false,
  }) {
    if (list.isEmpty) {
      return EmptyState(
        icon: isCompleted
            ? Icons.done_all_rounded
            : (isOverdue
                ? Icons.check_circle_outline_rounded
                : Icons.alarm_off_rounded),
        title: isCompleted
            ? 'No Completed Reminders'
            : (isOverdue ? 'No Overdue Maintenance!' : 'No Upcoming Reminders'),
        message: isCompleted
            ? 'Tasks marked done will appear in this archive.'
            : (isOverdue
                ? 'Great job! All vehicle maintenance tasks are currently within schedule.'
                : 'Create reminders for your next oil change, tuning, or tire rotation.'),
        actionLabel: isCompleted || isOverdue ? null : 'Set Reminder',
        onAction: isCompleted || isOverdue
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                );
              },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = list[index];
        return _buildReminderCard(context, state, r, isOverdue, isCompleted);
      },
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    AppState state,
    Reminder r,
    bool isOverdue,
    bool isCompleted,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      border: isOverdue
          ? Border.all(
              color: AppTheme.statusOverdue.withValues(alpha: 0.5), width: 1.2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: r.isCompleted,
                activeColor: AppTheme.statusHealthy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (_) => state.toggleReminder(r.id),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            r.taskTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? AppTheme.textMuted
                                  : AppTheme.primaryNavy,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isOverdue)
                          const StatusBadge(
                            label: 'Overdue',
                            backgroundColor: Color(0xFFFEE2E2),
                            textColor: AppTheme.statusOverdue,
                            icon: Icons.priority_high_rounded,
                          )
                        else if (!isCompleted)
                          const StatusBadge(
                            label: 'Upcoming',
                            backgroundColor: Color(0xFFFEF3C7),
                            textColor: AppTheme.statusUpcoming,
                            icon: Icons.schedule_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.vehicleName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentIndigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  r.type == ReminderType.dateBased
                      ? Icons.calendar_today_rounded
                      : Icons.speed_rounded,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  r.type == ReminderType.dateBased
                      ? (r.dueDate != null
                          ? 'Due Date: ${Formatters.formatDate(r.dueDate!)} (${Formatters.formatDueRelative(r.dueDate!)})'
                          : 'Date not set')
                      : 'Due Mileage: ${Formatters.formatMileage(r.dueMileage ?? 0)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryNavy),
                ),
              ],
            ),
          ),
          if (r.notes != null && r.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r.notes!,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppTheme.cardBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textMuted),
                tooltip: 'Edit Reminder',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddReminderScreen(reminder: r),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppTheme.statusOverdue),
                tooltip: 'Delete Reminder',
                onPressed: () {
                  state.deleteReminder(r.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed reminder')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
