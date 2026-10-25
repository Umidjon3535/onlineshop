import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _phone = '+998 71 000 00 00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yordam markazi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (var i = 0; i < faq.length; i++) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    ExpansionTile(
                      initiallyExpanded: i == 0,
                      title: Text(faq[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      iconColor: AppColors.accent,
                      children: [Text(faq[i].$2, style: const TextStyle(color: AppColors.muted, height: 1.5))],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.support_agent_rounded, color: AppColors.accent),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Qo'llab-quvvatlash (namuna raqam)", style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          SizedBox(height: 2),
                          SelectableText(_phone, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                      onPressed: () async {
                        await Clipboard.setData(const ClipboardData(text: _phone));
                        if (context.mounted) showToast(context, 'Raqamdan nusxa olindi', icon: Icons.copy_rounded);
                      },
                      child: const Text('Nusxa'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: AppColors.muted),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ish vaqti', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          SizedBox(height: 2),
                          Text('Har kuni, 09:00–21:00', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
