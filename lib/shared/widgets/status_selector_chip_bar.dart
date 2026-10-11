import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Accessible, single-tap status selector designed to minimize interaction friction
/// during vehicle maintenance inspections. Replaces repetitive modal dialogs.
class StatusSelectorChipBar extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusSelected;

  const StatusSelectorChipBar({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.checklistStatuses.map((status) {
        final isSelected = currentStatus == status;
        final colorData = _getStatusVisuals(status);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onStatusSelected(status),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorData.backgroundColor
                    : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? colorData.borderColor
                      : AppTheme.cardBorder,
                  width: isSelected ? 1.6 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    colorData.icon,
                    size: 15,
                    color: isSelected ? colorData.textColor : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? colorData.textColor : AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  _StatusVisualData _getStatusVisuals(String status) {
    switch (status) {
      case 'Done':
        return _StatusVisualData(
          backgroundColor: const Color(0xFFDCFCE7),
          borderColor: AppTheme.statusHealthy,
          textColor: const Color(0xFF15803D),
          icon: Icons.check_circle_rounded,
        );
      case 'Needs Repair/Adjustment':
        return _StatusVisualData(
          backgroundColor: const Color(0xFFFEF3C7),
          borderColor: AppTheme.statusUpcoming,
          textColor: const Color(0xFFB45309),
          icon: Icons.build_circle_rounded,
        );
      case 'Needs Replacement':
        return _StatusVisualData(
          backgroundColor: const Color(0xFFFEE2E2),
          borderColor: AppTheme.statusOverdue,
          textColor: const Color(0xFFB91C1C),
          icon: Icons.change_circle_rounded,
        );
      case 'Not Required':
        return _StatusVisualData(
          backgroundColor: const Color(0xFFF1F5F9),
          borderColor: const Color(0xFF94A3B8),
          textColor: const Color(0xFF475569),
          icon: Icons.do_not_disturb_on_outlined,
        );
      default: // Not Started
        return _StatusVisualData(
          backgroundColor: const Color(0xFFE2E8F0),
          borderColor: const Color(0xFF64748B),
          textColor: const Color(0xFF334155),
          icon: Icons.radio_button_unchecked_rounded,
        );
    }
  }
}

class _StatusVisualData {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  const _StatusVisualData({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });
}
