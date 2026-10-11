import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/service_record.dart';
import '../../shared/widgets/custom_card.dart';

class ServiceRecordDetailScreen extends StatelessWidget {
  final ServiceRecord record;

  const ServiceRecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Service Entry Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.serviceType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.formatDate(record.serviceDate),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  record.vehicleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Recorded at ${Formatters.formatMileage(record.odometer)}',
                  style: const TextStyle(
                    color: Color(0xFF67E8F9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Work Performed
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.handyman_outlined,
                        size: 18, color: AppTheme.primaryNavy),
                    SizedBox(width: 8),
                    Text(
                      'Work Performed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  record.workPerformed,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Parts & Fluids
          if (record.partsReplaced != null &&
              record.partsReplaced!.isNotEmpty) ...[
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 18, color: AppTheme.primaryNavy),
                      SizedBox(width: 8),
                      Text(
                        'Parts & Lubricants Replaced',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    record.partsReplaced!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Cost Breakdown
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_outlined,
                        size: 18, color: AppTheme.primaryNavy),
                    SizedBox(width: 8),
                    Text(
                      'Financial Cost Breakdown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _costRow('Parts Cost', Formatters.formatPKR(record.partsCost)),
                const SizedBox(height: 8),
                _costRow('Labor / Service Charge',
                    Formatters.formatPKR(record.laborCost)),
                const Divider(height: 20, color: AppTheme.cardBorder),
                _costRow(
                  'Total Invoice Amount',
                  Formatters.formatPKR(record.totalCost),
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Next Due Target
          if (record.nextServiceDate != null ||
              record.nextServiceMileage != null) ...[
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event_repeat_rounded,
                          size: 18, color: AppTheme.statusUpcoming),
                      SizedBox(width: 8),
                      Text(
                        'Next Service Recommendation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (record.nextServiceDate != null)
                    Text(
                      'Target Date: ${Formatters.formatDate(record.nextServiceDate!)}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  if (record.nextServiceMileage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Target Mileage: ${Formatters.formatMileage(record.nextServiceMileage!)}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Shop / Notes
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 18, color: AppTheme.textMuted),
                      SizedBox(width: 8),
                      Text(
                        'Additional Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.notes!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _costRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppTheme.primaryNavy : AppTheme.textMuted,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppTheme.primaryNavy : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
