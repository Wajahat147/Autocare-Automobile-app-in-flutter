import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/maintenance_item.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.fromMaintenanceStatus(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.healthy:
        return const StatusBadge(
          label: 'Healthy',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: AppTheme.statusHealthy,
          icon: Icons.check_circle_outline,
        );
      case MaintenanceStatus.upcoming:
        return const StatusBadge(
          label: 'Upcoming',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: AppTheme.statusUpcoming,
          icon: Icons.access_time_rounded,
        );
      case MaintenanceStatus.overdue:
        return const StatusBadge(
          label: 'Overdue',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: AppTheme.statusOverdue,
          icon: Icons.error_outline_rounded,
        );
      case MaintenanceStatus.needsAttention:
        return const StatusBadge(
          label: 'Needs Attention',
          backgroundColor: Color(0xFFFFEDD5),
          textColor: Color(0xFFEA580C),
          icon: Icons.warning_amber_rounded,
        );
    }
  }

  factory StatusBadge.fromChecklistStatus(String status) {
    switch (status) {
      case 'Done':
        return const StatusBadge(
          label: 'Done',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: AppTheme.statusHealthy,
          icon: Icons.check_circle_rounded,
        );
      case 'Not Required':
        return const StatusBadge(
          label: 'Not Required',
          backgroundColor: Color(0xFFF1F5F9),
          textColor: AppTheme.textMuted,
          icon: Icons.remove_circle_outline,
        );
      case 'Needs Repair/Adjustment':
        return const StatusBadge(
          label: 'Needs Repair',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: AppTheme.statusUpcoming,
          icon: Icons.build_circle_outlined,
        );
      case 'Needs Replacement':
        return const StatusBadge(
          label: 'Needs Replacement',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: AppTheme.statusOverdue,
          icon: Icons.change_circle_outlined,
        );
      default:
        return const StatusBadge(
          label: 'Not Started',
          backgroundColor: Color(0xFFE2E8F0),
          textColor: Color(0xFF475569),
          icon: Icons.radio_button_unchecked,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
