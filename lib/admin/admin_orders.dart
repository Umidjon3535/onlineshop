import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/order_widgets.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  /// null — hammasi, aks holda holat raqami.
  int? _status;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final q = _query.trim().toLowerCase();
    final orders = shop.orders.where((o) {
      final byStatus = _status == null || o.status == _status;
      final byQuery = q.isEmpty || o.no.contains(q) || o.customer.toLowerCase().contains(q) || o.phone.contains(q);
      return byStatus && byQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: "Raqam, mijoz yoki telefon bo'yicha qidirish",
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _filter(null, 'Hammasi', shop.orders.length),
              for (var s = 0; s < orderStatuses.length; s++) _filter(s, orderStatuses[s], shop.orders.where((o) => o.status == s).length),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: orders.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Buyurtma topilmadi',
                  subtitle: "Boshqa holatni tanlang yoki qidiruvni o'zgartiring.",
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => OrderCard(
                    order: orders[i],
                    showCustomer: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminOrderDetail(orderNo: orders[i].no)),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _filter(int? status, String label, int count) {
    final selected = _status == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label · $count'),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600),
        onSelected: (_) => setState(() => _status = status),
      ),
    );
  }
}

class AdminOrderDetail extends StatelessWidget {
  const AdminOrderDetail({super.key, required this.orderNo});

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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Panel(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                  ),
                  child: Text(initials(o.customer), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.customer, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('${fullPhone(o.phone)} · ${formatDate(o.created)}', style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Telefon raqamdan nusxa olish',
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: fullPhone(o.phone)));
                    if (context.mounted) showToast(context, 'Raqamdan nusxa olindi', icon: Icons.copy_rounded);
                  },
                ),
              ],
            ),
          ),
          const SectionTitle('Holatni o\'zgartirish'),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderTrack(o),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var s = 0; s < orderStatuses.length; s++)
                      ChoiceChip(
                        label: Text(orderStatuses[s]),
                        selected: o.status == s,
                        showCheckmark: false,
                        backgroundColor: AppColors.surface2,
                        selectedColor: statusColor(s),
                        labelStyle: TextStyle(color: o.status == s ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600),
                        onSelected: (_) => _setStatus(context, shop, o, s),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bekor qilinganda mahsulotlar omborga qaytadi. Xaridor yangi holatni o'z ilovasida ko'radi.",
                  style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          OrderDetails(o),
        ],
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, ShopState shop, Order o, int status) async {
    if (status == o.status) return;
    if (status == Order.cancelled &&
        !await confirmDialog(context,
            title: 'Buyurtmani bekor qilasizmi?',
            message: 'Mahsulotlar omborga qaytariladi.',
            confirm: 'Bekor qilish',
            danger: true)) {
      return;
    }
    shop.setOrderStatus(o, status);
    if (context.mounted) showToast(context, 'Holat: ${orderStatuses[status]}', icon: Icons.sync_rounded);
  }
}
