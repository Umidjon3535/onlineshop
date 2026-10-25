import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'addresses_screen.dart';
import 'orders_screen.dart';

/// [context] savat ekraniniki bo'lishi kerak: buyurtmadan keyin u ekranda qoladi.
Future<void> openCheckout(BuildContext context) async {
  final shop = context.read<ShopState>();
  if (shop.user == null) {
    shop.pendingCheckout = true;
    shop.setTab(3);
    showToast(context, 'Buyurtma berish uchun hisobingizga kiring', icon: Icons.person_rounded);
    return;
  }
  final order = await showModalBottomSheet<Order>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => const _CheckoutSheet(),
  );
  if (order == null || !context.mounted) return;

  final track = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 46, color: AppColors.success),
            ),
            const SizedBox(height: 20),
            const Text('Buyurtma qabul qilindi!', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "Buyurtma raqami #${order.no}, jami ${formatPrice(order.total)}.\nHolatini Profil → Buyurtmalarim bo'limida kuzatasiz.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Buyurtmani kuzatish', onPressed: () => Navigator.pop(ctx, true)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Asosiyga qaytish')),
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted) return;
  if (track == true) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderNo: order.no)));
  } else {
    shop.setTab(0);
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet();

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  String? _addressId;
  int? _pay;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final u = shop.user;
    if (u == null) return const SizedBox(height: 200);
    final t = shop.totals;
    final addresses = u.addresses;
    if (!addresses.any((a) => a.id == _addressId)) _addressId = u.defaultAddress?.id;
    final pay = _pay ?? u.pay;
    final address = addresses.where((a) => a.id == _addressId).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Buyurtmani rasmiylashtirish', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const Text('Yetkazib berish manzili', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final a in addresses) ...[
            SelectTile(
              icon: addressIcon(a.kind),
              title: a.kind,
              subtitle: a.full,
              selected: a.id == _addressId,
              onTap: () => setState(() => _addressId = a.id),
            ),
            const SizedBox(height: 10),
          ],
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Yangi manzil qo'shish"),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
          const SizedBox(height: 8),
          const Text("To'lov usuli", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (var i = 0; i < payMethods.length; i++) ...[
            SelectTile(
              icon: payMethods[i].$1,
              title: payMethods[i].$2,
              subtitle: i == 3 ? 'Oyiga ${formatPrice(monthly(t.total))}' : null,
              selected: i == pay,
              onTap: () => setState(() => _pay = i),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                SummaryRow('Mahsulotlar', formatPrice(t.subtotal)),
                if (t.discount > 0) SummaryRow('Chegirma (${t.promo!.code})', '−${formatPrice(t.discount)}', valueColor: AppColors.success),
                SummaryRow('Yetkazib berish', t.delivery == 0 ? 'Bepul' : formatPrice(t.delivery)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider()),
                SummaryRow('Jami', formatPrice(t.total), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Tasdiqlash',
            sub: formatPrice(t.total),
            onPressed: address == null || shop.cart.isEmpty
                ? null
                : () => Navigator.pop(context, shop.placeOrder(address: address, pay: pay)),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              address == null ? 'Davom etish uchun yetkazib berish manzilini qo\'shing.' : "Namuna do'kon: haqiqiy to'lov olinmaydi.",
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
