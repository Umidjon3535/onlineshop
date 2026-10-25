import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';
import 'admin_orders.dart';
import 'product_editor.dart';

const _weekdays = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final days = shop.revenueByDay();
    final low = shop.lowStock;
    final recent = shop.orders.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _StatCard(icon: Icons.payments_outlined, label: 'Jami tushum', value: formatPrice(shop.revenue), color: AppColors.success),
            _StatCard(
              icon: Icons.receipt_long_outlined,
              label: 'Buyurtmalar',
              value: '${shop.orders.length}',
              hint: shop.newOrdersCount > 0 ? '${shop.newOrdersCount} ta yangi' : null,
              color: AppColors.accent,
              onTap: () => onOpenTab(1),
            ),
            _StatCard(icon: Icons.shopping_cart_checkout_rounded, label: "O'rtacha chek", value: formatPrice(shop.averageCheck), color: AppColors.info),
            _StatCard(
              icon: Icons.people_outline_rounded,
              label: 'Mijozlar',
              value: '${shop.users.length}',
              hint: '${shop.products.length} ta mahsulot',
              color: AppColors.ink,
              onTap: () => onOpenTab(3),
            ),
          ],
        ),
        const SectionTitle("So'nggi 7 kun tushumi"),
        Panel(child: SizedBox(height: 170, child: _BarChart(days: days))),
        if (shop.orders.isEmpty) ...[
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Hali buyurtma yo\'q', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                const Text(
                  "Panel qanday ishlashini ko'rish uchun so'nggi 7 kunga namuna buyurtmalar qo'shishingiz mumkin. Ularni Sozlamalardan o'chirib tashlaysiz.",
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    final n = shop.addSampleOrders();
                    showToast(context, "$n ta namuna buyurtma qo'shildi", icon: Icons.receipt_long_rounded);
                  },
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text("Namuna buyurtmalar qo'shish"),
                ),
              ],
            ),
          ),
        ],
        if (low.isNotEmpty) ...[
          SectionTitle('Kam qolgan mahsulotlar', trailing: Text('${low.length} ta', style: const TextStyle(color: AppColors.muted))),
          Panel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < low.length && i < 6; i++) ...[
                  if (i > 0) const Divider(),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductEditor(product: low[i]))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          ImageTile(image: low[i].cover, category: low[i].category, size: 46, radius: 12, padding: 5),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(low[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Pill(low[i].stock == 0 ? 'Tugagan' : '${low[i].stock} dona',
                              color: low[i].stock == 0 ? AppColors.danger : AppColors.accent),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (recent.isNotEmpty) ...[
          SectionTitle(
            "So'nggi buyurtmalar",
            trailing: TextButton(onPressed: () => onOpenTab(1), child: const Text('Hammasi')),
          ),
          for (final o in recent) ...[
            OrderCard(
              order: o,
              showCustomer: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderDetail(orderNo: o.no))),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color, this.hint, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 19),
                  ),
                  const Spacer(),
                  if (hint != null)
                    Flexible(
                      child: Text(hint!,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.days});

  final List<(DateTime, int)> days;

  @override
  Widget build(BuildContext context) {
    final maxValue = days.fold(0, (m, d) => d.$2 > m ? d.$2 : m);
    return LayoutBuilder(
      builder: (context, box) {
        final barArea = box.maxHeight - 40;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        days[i].$2 == 0 ? '' : compactPrice(days[i].$2),
                        style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: maxValue == 0 ? 4 : (barArea * days[i].$2 / maxValue).clamp(4.0, barArea),
                      decoration: BoxDecoration(
                        color: i == days.length - 1 ? AppColors.accent : AppColors.accent.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i == days.length - 1 ? 'Bugun' : _weekdays[days[i].$1.weekday - 1],
                      style: TextStyle(
                        fontSize: 11,
                        color: i == days.length - 1 ? AppColors.ink : AppColors.muted,
                        fontWeight: i == days.length - 1 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
