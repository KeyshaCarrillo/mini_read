import 'package:flutter/material.dart';

import '../../../shared/components/premium_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/extensions/context_extensions.dart';

class OpsHealthPanel extends StatelessWidget {
  const OpsHealthPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final items = {'API latency': .72, 'Auth success': .98, 'Sync jobs': .86, 'Report SLA': .91};
    return PremiumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'System status', subtitle: 'Live operational health signals'),
          const SizedBox(height: 22),
          ...items.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(entry.key, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                    Text('${(entry.value * 100).toStringAsFixed(0)}%', style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                  ]),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: entry.value, minHeight: 6, borderRadius: BorderRadius.circular(999), backgroundColor: context.colors.onSurface.withValues(alpha: .08)),
                ]),
              )),
        ],
      ),
    );
  }
}
