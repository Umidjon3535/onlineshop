import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final orders = shop.myOrders;

    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmalarim')),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: "Hali buyurtma yo'q",
              subtitle: "Birinchi buyurtmangizni bering, u shu yerda ko'rinadi va holatini kuzatib borasiz.",
              actionLabel: 'Xarid qilishni boshlash',
              onAction: () {
                shop.setTab(0);
                Navigator.popUntil(context, (r) => r.isFirst);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => OrderCard(
                order: orders[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderNo: orders[i].no)),
                ),
              ),
            ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderNo});

  final String orderNo;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final o = shop.orderByNo(orderNo);
    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.receipt_long_outlined, title: 'Buyurtma topilmadi', subtitle: "Bu buyurtma o'chirilgan."),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Buyurtma #${o.no}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Holati', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    StatusChip(o.status),
                  ],
                ),
                const SizedBox(height: 14),
                OrderTrack(o),
              ],
            ),
          ),
          OrderDetails(o),
          const SizedBox(height: 20),
          if (o.status == 0) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (await confirmDialog(context,
                      title: 'Buyurtmani bekor qilasizmi?',
                      message: "Buyurtma hali yig'ilmagan, uni bekor qilish mumkin.",
                      confirm: 'Bekor qilish',
                      danger: true)) {
                    shop.cancelMyOrder(o);
                    if (context.mounted) showToast(context, 'Buyurtma bekor qilindi', icon: Icons.cancel_outlined);
                  }
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Buyurtmani bekor qilish'),
              ),
            ),
            const SizedBox(height: 10),
          ],
          PrimaryButton(
            label: 'Qayta buyurtma berish',
            icon: Icons.replay_rounded,
            onPressed: () {
              final added = shop.reorder(o);
              if (added == 0) {
                showToast(context, "Bu mahsulotlar hozir sotuvda yo'q", icon: Icons.info_outline_rounded);
                return;
              }
              shop.setTab(2);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
