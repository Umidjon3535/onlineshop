import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'orders_screen.dart';

Future<void> showNotifications(BuildContext context) {
  final shop = context.read<ShopState>();
  final orders = shop.myOrders.take(5).toList();
  final promos = shop.promos.where((c) => c.active).toList();
  shop.markNotificationsSeen();

  return showSheet(
    context,
    title: 'Bildirishnomalar',
    child: Builder(
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!shop.notifications)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Bildirishnomalar o'chirilgan. Ularni Profil sahifasida yoqishingiz mumkin.",
                  style: TextStyle(color: AppColors.muted)),
            ),
          for (final o in orders)
            _NoteRow(
              icon: Icons.local_shipping_outlined,
              title: 'Buyurtma #${o.no}: ${orderStatuses[o.status].toLowerCase()}',
              subtitle: formatDate(o.updated),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderNo: o.no)));
              },
            ),
          for (final c in promos)
            _NoteRow(
              icon: c.kind == PromoKind.shipping ? Icons.local_shipping_outlined : Icons.local_offer_outlined,
              title: '${c.code}: ${c.title}',
              subtitle: 'Profil → Promokodlar',
            ),
          _NoteRow(
            icon: Icons.schedule_rounded,
            title: "${formatPrice(shop.settings.freeFrom)} dan ortiq xaridlarga yetkazib berish bepul",
            subtitle: 'Doimiy aksiya',
          ),
          if (shop.user == null)
            const _NoteRow(
              icon: Icons.person_outline_rounded,
              title: "Ro'yxatdan o'ting va buyurtmalaringizni kuzatib boring",
              subtitle: "Profil bo'limi",
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yopish')),
          ),
        ],
      ),
    ),
  );
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
