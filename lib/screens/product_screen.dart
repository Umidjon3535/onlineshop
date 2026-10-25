import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.productId, this.heroTag});

  final String productId;
  final String? heroTag;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _pages = PageController();
  int _page = 0;
  int? _opt;
  int _qty = 1;
  bool _optInit = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final p = shop.byId(widget.productId);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Mahsulot topilmadi',
          subtitle: "Bu mahsulot do'kondan olib tashlangan.",
        ),
      );
    }
    if (!_optInit) {
      _opt = p.option == null ? null : 0;
      _optInit = true;
    }
    final price = p.unitPrice(_opt);
    final old = p.oldPrice == null ? null : p.oldPrice! + p.extra(_opt);
    final soldOut = p.stock <= 0;
    final qty = soldOut ? 1 : _qty.clamp(1, p.stock);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: tileColor(p.category),
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleIconButton(icon: Icons.arrow_back_ios_new_rounded, tooltip: 'Orqaga', onTap: () => Navigator.pop(context)),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FavButton(size: 40, active: shop.isFavorite(p.id), onTap: () => shop.toggleFavorite(p)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: p.images.isEmpty ? 1 : p.images.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) {
                        final image = Padding(
                          padding: const EdgeInsets.fromLTRB(36, 96, 36, 44),
                          child: ProductImage(p.images.isEmpty ? '' : p.images[i]),
                        );
                        return i == 0 && widget.heroTag != null ? Hero(tag: widget.heroTag!, child: image) : image;
                      },
                    ),
                  ),
                  if (p.images.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < p.images.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _page ? 22 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: i == _page ? AppColors.ink : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (p.images.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    for (var i = 0; i < p.images.length; i++) ...[
                      GestureDetector(
                        onTap: () => _pages.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: i == _page ? AppColors.ink : Colors.transparent, width: 2),
                          ),
                          child: ImageTile(image: p.images[i], category: p.category, size: 58, radius: 13, padding: 6),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.brand.toUpperCase(),
                            style: const TextStyle(color: AppColors.muted, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                      ),
                      if (soldOut)
                        const Pill("Sotuvda yo'q", color: AppColors.danger)
                      else if (p.stock < 10)
                        Pill('Tez tugayapti: ${p.stock} dona qoldi', color: AppColors.accent)
                      else
                        const Pill('Omborda bor', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Icon(i <= p.rating.round() ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: AppColors.star),
                      const SizedBox(width: 6),
                      Text(p.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('  ·  ${group3(p.reviews)} ta baho', style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(formatPrice(price), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                      if (old != null && p.discount != null) ...[
                        Text(formatPrice(old),
                            style: const TextStyle(color: AppColors.muted, decoration: TextDecoration.lineThrough)),
                        DiscountBadge(p.discount!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Panel(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(color: AppColors.muted, fontSize: 13),
                              children: [
                                const TextSpan(text: "12 oyga bo'lib to'lash: oyiga "),
                                TextSpan(
                                  text: formatPrice(monthly(price)),
                                  style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(text: ' dan'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (p.option != null) ...[
                    SectionTitle(p.option!.name),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var i = 0; i < p.option!.values.length; i++)
                          _VariantChip(
                            label: p.option!.values[i].label,
                            extra: p.option!.values[i].extra,
                            selected: i == _opt,
                            onTap: () => setState(() => _opt = i),
                          ),
                      ],
                    ),
                  ],
                  if (p.description.isNotEmpty) ...[
                    const SectionTitle('Tavsif'),
                    Text(p.description, style: const TextStyle(color: Color(0xFF5B5E6B), height: 1.55, fontSize: 15)),
                  ],
                  if (p.specs.isNotEmpty) ...[
                    const SectionTitle('Xususiyatlari'),
                    Panel(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        children: [
                          for (var i = 0; i < p.specs.length; i++) ...[
                            if (i > 0) const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(p.specs[i].key, style: const TextStyle(color: AppColors.muted))),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(p.specs[i].value,
                                        textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const _Perk(icon: Icons.local_shipping_outlined, label: 'Toshkentga\nertaga'),
                      const SizedBox(width: 10),
                      _Perk(icon: Icons.verified_user_outlined, label: p.warranty.isEmpty ? 'Kafolat' : p.warranty),
                      const SizedBox(width: 10),
                      const _Perk(icon: Icons.workspace_premium_outlined, label: 'Original\nmahsulot'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.line))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: soldOut
                ? const PrimaryButton(label: "Sotuvda yo'q")
                : Row(
                    children: [
                      QtyStepper(value: qty, min: 1, max: p.stock, onChanged: (v) => setState(() => _qty = v)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            shop.addToCart(p, opt: _opt, qty: qty);
                            showToast(context, "${p.name} savatga qo'shildi");
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Savatga qo'shish"),
                              Text(formatPrice(price * qty),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.label, required this.extra, required this.selected, required this.onTap});

  final String label;
  final int extra;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 54, minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: selected ? AppColors.ink : Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.ink)),
            if (extra > 0)
              Text('+${group3(extra)}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white70 : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
