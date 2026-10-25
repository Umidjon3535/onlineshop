import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final u = shop.user;
    if (u == null) return const Scaffold(body: SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(title: const Text("To'lov usullari")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            "Tanlangan usul buyurtma berishda avtomatik belgilanadi. Uni rasmiylashtirish oynasida ham o'zgartirish mumkin.",
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < payMethods.length; i++) ...[
            SelectTile(
              icon: payMethods[i].$1,
              title: payMethods[i].$2,
              selected: i == u.pay,
              onTap: () {
                shop.setDefaultPay(i);
                showToast(context, "Asosiy to'lov usuli: ${payMethods[i].$2}", icon: payMethods[i].$1);
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          const Text(
            "Karta ma'lumotlari to'lov tizimining o'z ilovasida kiritiladi. Bozor ularni saqlamaydi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
