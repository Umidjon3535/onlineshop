import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../screens/product_screen.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.heroPrefix});

  final Product product;

  /// Bir xil mahsulot bir nechta tabda turganda Hero teglari to'qnashmasligi uchun.
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final p = product;
    final heroTag = '$heroPrefix-${p.id}';
    final soldOut = p.stock <= 0;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductScreen(productId: p.id, heroTag: heroTag)),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: ImageTile(image: p.cover, category: p.category, padding: 12),
                    ),
                  ),
                  if (p.discount != null) Positioned(left: 8, top: 8, child: DiscountBadge(p.discount!)),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: FavButton(size: 34, active: shop.isFavorite(p.id), onTap: () => shop.toggleFavorite(p)),
                  ),
                  if (soldOut)
                    const Positioned(left: 8, bottom: 8, child: Pill('Tugagan', color: AppColors.danger))
                  else
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: CircleIconButton(
                        icon: Icons.add_rounded,
                        size: 34,
                        color: Colors.white,
                        background: AppColors.ink,
                        tooltip: "Savatga qo'shish",
                        onTap: () {
                          shop.addToCart(p, opt: p.option == null ? null : 0);
                          showToast(context, "${p.name} savatga qo'shildi");
                        },
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10.5, letterSpacing: 1, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                      const SizedBox(width: 2),
                      Text(p.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      Flexible(
                        child: Text(' (${group3(p.reviews)})',
                            overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 15,
                    child: p.oldPrice != null && p.discount != null
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(formatPrice(p.oldPrice!),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted, decoration: TextDecoration.lineThrough)),
                          )
                        : null,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(formatPrice(p.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                  Text("${formatPrice(monthly(p.price))} × 12 oy",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mahsulotlar to'ri uchun umumiy sozlama.
const productGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.53,
);
