import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'checkout_sheet.dart';
import 'product_screen.dart';
import 'promos_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _applyPromo(ShopState shop) {
    final error = shop.applyPromo(_promo.text);
    if (error != null) {
      showToast(context, error, icon: Icons.local_offer_outlined);
    } else {
      _promo.clear();
      FocusScope.of(context).unfocus();
      showToast(context, "Promokod qo'llandi", icon: Icons.local_offer_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final items = shop.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savat'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Savatni tozalash',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                if (await confirmDialog(context,
                    title: 'Savatni tozalaysizmi?', message: "Barcha mahsulotlar savatdan o'chiriladi.", confirm: 'Tozalash', danger: true)) {
                  shop.clearCart();
                }
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: "Savatingiz bo'sh",
              subtitle: "Hali hech narsa qo'shmadingiz. Asosiy sahifadan yoqqan mahsulotni tanlang.",
              actionLabel: 'Xarid qilishni boshlash',
              onAction: () => shop.setTab(0),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                for (final item in items) ...[_CartLine(item: item), const SizedBox(height: 12)],
                _DeliveryHint(totals: shop.totals, freeFrom: shop.settings.freeFrom),
                const SizedBox(height: 12),
                _promoBox(shop),
                const SizedBox(height: 12),
                _summary(shop),
              ],
            ),
    );
  }

  Widget _promoBox(ShopState shop) {
    final t = shop.totals;
    if (t.promo != null) {
      final ok = t.promoValid;
      final color = ok ? AppColors.success : AppColors.accent;
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.promo!.code, style: TextStyle(color: color, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                  Text(
                    ok ? t.promo!.title : 'Bu promokod uchun kamida ${formatPrice(t.promo!.min)} xarid kerak',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            IconButton(tooltip: 'Promokodni olib tashlash', onPressed: shop.removePromo, icon: const Icon(Icons.close_rounded)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promo,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _applyPromo(shop),
                decoration: const InputDecoration(
                  hintText: 'Promokod',
                  prefixIcon: Icon(Icons.local_offer_outlined, color: AppColors.muted),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(onPressed: () => _applyPromo(shop), child: const Text("Qo'llash")),
          ],
        ),
        TextButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromosScreen())),
          icon: const Icon(Icons.local_offer_outlined, size: 18),
          label: const Text('Mavjud promokodlar'),
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
        ),
      ],
    );
  }

  Widget _summary(ShopState shop) {
    final t = shop.totals;
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SummaryRow('Mahsulotlar (${shop.cartCount})', formatPrice(t.subtotal)),
          if (t.discount > 0) SummaryRow('Chegirma', '−${formatPrice(t.discount)}', valueColor: AppColors.success),
          SummaryRow('Yetkazib berish', t.delivery == 0 ? 'Bepul' : formatPrice(t.delivery)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          SummaryRow('Jami', formatPrice(t.total), bold: true),
          SummaryRow("Bo'lib to'lash", '${formatPrice(monthly(t.total))} × 12 oy'),
          const SizedBox(height: 14),
          // CartScreen konteksti ishlatiladi: savat bo'shaganda ham u ekranda qoladi.
          PrimaryButton(label: 'Rasmiylashtirish', onPressed: () => openCheckout(context)),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopState>();
    final p = shop.byId(item.productId)!;
    final meta = [p.brand, if (p.optionLabel(item.opt).isNotEmpty) p.optionLabel(item.opt)].join(' · ');

    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => shop.removeFromCart(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(productId: p.id))),
              child: ImageTile(image: p.cover, category: p.category, size: 86, padding: 8),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => shop.removeFromCart(item),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  Text(meta, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(formatPrice(p.unitPrice(item.opt) * item.qty),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                      ),
                      QtyStepper(compact: true, value: item.qty, max: p.stock, onChanged: (v) => shop.setQty(item, v)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryHint extends StatelessWidget {
  const _DeliveryHint({required this.totals, required this.freeFrom});

  final Totals totals;
  final int freeFrom;

  @override
  Widget build(BuildContext context) {
    final free = totals.delivery == 0;
    final left = freeFrom - totals.subtotal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  free ? 'Yetkazib berish bepul' : 'Bepul yetkazish uchun yana ${formatPrice(left)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: free ? 1.0 : (totals.subtotal / freeFrom).clamp(0.0, 1.0),
              minHeight: 7,
              color: AppColors.accent,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
