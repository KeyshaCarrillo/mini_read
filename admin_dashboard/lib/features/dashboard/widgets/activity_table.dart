import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../shared/components/premium_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../models/admin_models.dart';

class ActivityTable extends StatelessWidget {
  const ActivityTable({super.key, required this.activities});
  final List<ActivityRecord> activities;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SectionHeader(
              title: 'Platform activity',
              subtitle: 'Operational events requiring observability and auditability',
              trailing: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 17), label: const Text('Export')),
            ),
          ),
          SizedBox(
            height: 360,
            child: DataTable2(
              headingRowHeight: 44,
              dataRowHeight: 62,
              fixedTopRows: 1,
              columnSpacing: 20,
              horizontalMargin: 24,
              headingTextStyle: context.text.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: context.colors.onSurfaceVariant, letterSpacing: .5),
              border: TableBorder(top: BorderSide(color: context.theme.dividerColor), horizontalInside: BorderSide(color: context.theme.dividerColor)),
              columns: const [
                DataColumn2(label: Text('USER'), size: ColumnSize.L),
                DataColumn2(label: Text('ACTION'), size: ColumnSize.L),
                DataColumn2(label: Text('PLAN'), size: ColumnSize.S),
                DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
                DataColumn2(label: Text('TIME'), size: ColumnSize.S),
                DataColumn2(label: Text(''), fixedWidth: 48),
              ],
              rows: activities.map((activity) => DataRow2(
                    onTap: () {},
                    cells: [
                      DataCell(Row(children: [
                        CircleAvatar(radius: 16, backgroundColor: context.colors.primary.withValues(alpha: .10), child: Text(activity.initials, style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w800, fontSize: 11))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(activity.user, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
                          Text(activity.email, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                        ])),
                      ])),
                      DataCell(Text(activity.action, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelMedium)),
                      DataCell(Text(activity.plan, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                      DataCell(StatusBadge(label: activity.status)),
                      DataCell(Text(activity.time, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant))),
                      DataCell(IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded, size: 18))),
                    ],
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
