import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PromosScreen extends StatelessWidget {
  const PromosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final codes = shop.promos.where((c) => c.active).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Promokodlar')),
      body: codes.isEmpty
          ? const EmptyState(
              icon: Icons.local_offer_outlined,
              title: "Hozircha promokod yo'q",
              subtitle: "Yangi aksiyalar boshlanganda ular shu yerda chiqadi.",
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const Text(
                  "Promokod savatdagi jami summaga qo'llanadi. Bir vaqtda bitta promokod ishlaydi.",
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                for (final c in codes) ...[
                  _Coupon(code: c, applied: shop.appliedPromo == c.code),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _Coupon extends StatelessWidget {
  const _Coupon({required this.code, required this.applied});

  final PromoCode code;
  final bool applied;

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopState>();
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
            child: code.kind == PromoKind.shipping
                ? const Icon(Icons.local_shipping_outlined, color: AppColors.accent)
                : Text(code.badge, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code.code, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(code.title, style: const TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              backgroundColor: applied ? AppColors.surface2 : AppColors.ink,
              foregroundColor: applied ? AppColors.muted : Colors.white,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            onPressed: applied
                ? null
                : () {
                    shop.applyPromo(code.code);
                    showToast(context, "${code.code} promokodi qo'llandi", icon: Icons.local_offer_outlined);
                  },
            child: Text(applied ? "Qo'llangan" : "Qo'llash"),
          ),
        ],
      ),
    );
  }
}
