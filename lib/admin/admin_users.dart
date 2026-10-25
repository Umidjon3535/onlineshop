import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';
import 'admin_orders.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final q = _query.trim().toLowerCase();
    final users = shop.users.values
        .where((u) => q.isEmpty || u.name.toLowerCase().contains(q) || u.phone.contains(q))
        .toList()
      ..sort((a, b) => shop.spentBy(b.phone).compareTo(shop.spentBy(a.phone)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: "Ism yoki telefon bo'yicha qidirish",
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: "Hali mijoz yo'q",
                  subtitle: "Xaridorlar ilovada ro'yxatdan o'tganda ular shu yerda chiqadi.",
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    final orders = shop.ordersOf(u.phone);
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showUser(context, u.phone),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                                ),
                                child: Text(initials(u.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(fullPhone(u.phone), style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatPrice(shop.spentBy(u.phone)), style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text('${orders.length} ta buyurtma', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showUser(BuildContext context, String phone) {
    final shop = context.read<ShopState>();
    final u = shop.users[phone]!;
    final orders = shop.ordersOf(phone);
    showSheet(
      context,
      title: u.name,
      child: Builder(
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [fullPhone(u.phone), if (u.email.isNotEmpty) u.email, "Ro'yxatdan o'tgan: ${formatDate(u.created)}"].join('\n'),
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            if (u.addresses.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Manzillar', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              for (final a in u.addresses) Text('• ${a.kind}: ${a.full}', style: const TextStyle(height: 1.5)),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Buyurtmalar', value: '${orders.length}')),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(label: 'Xarid summasi', value: formatPrice(shop.spentBy(phone)))),
              ],
            ),
            const SizedBox(height: 14),
            for (final o in orders) ...[
              OrderCard(
                order: o,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderDetail(orderNo: o.no)));
                },
              ),
              const SizedBox(height: 10),
            ],
            if (orders.isEmpty) const Text("Bu mijoz hali buyurtma bermagan.", style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
